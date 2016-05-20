function [bw] = Bullwinkle(detector_out, params)
%function [bw] = Bullwinkle(detector_out, params)
%
% Score a detector image with Bullwinkle
%
% Bullwinkle is a per-pixel scoring method, made to complement
%  the blob-based scoring method ROCKY
%
%  to complain about the bad pun, email bjm@wossamotta.edu
%
% 8/14/2012 - Taylor C. Glenn - tcg@cise.ufl.edu


% determine which alarms to score
gt = detector_out.groundTruth;

filt = params.targetFilter;
n_targets_orig = numel(gt.Targets_ID);

score_list = false(1,n_targets_orig);
for i=1:n_targets_orig
    score_list(i) = matches_filter(filt,gt.Targets_Type{i},gt.Targets_Size(i),gt.Targets_HumanConf(i),gt.Targets_HumanCat(i));           
end

if all(~score_list)
    error('bullwinkle:notargets','No targets match the filter criterion');
end

% remove unscored targets from the truth
fields = fieldnames(gt);
for i=1:numel(fields)
    if strfind(fields{i},'Targets_')
        gt.(fields{i})(~score_list) = [];
    end
end

n_targets = numel(gt.Targets_ID);

% if we are ignoring clutter, 
%  null out the unscored targets

det_img = detector_out.Data;
[n_row,n_col] = size(det_img);

se1 = strel('square',2*params.Halo+1); %small region for .5m,1m targets
se3 = strel('square',2*params.Halo+3); %larger region for 3m targets
se6 = strel('rectangle',[2*params.Halo+13,2*params.Halo+11]); % rediculous region to mask out cal cloths 

if params.ignore_clutter
    
    null_mask = false(n_row,n_col);
    for i=1:n_targets_orig
        
        if score_list(i), continue; end
        base = false(n_row,n_col);
        gto = detector_out.groundTruth; %original ground truth
        
        base(gto.Targets_rowIndices(i),gto.Targets_colIndices(i)) = true;
        if gto.Targets_Size(i) <= 1
            dl = imdilate(base,se1);
        elseif gto.Targets_Size(i) == 3
            dl = imdilate(base,se3);
        else
            dl = imdilate(base,se6);
        end
        null_mask(dl) = true;
    end
    
    det_img(null_mask) = nan;
end


%Determine Area
if isfield(detector_out.info,'map_info')
    dx = detector_out.info.map_info.dx;
    dy = detector_out.info.map_info.dy;
else
    dx = 1;
    dy = 1;
end

area = abs(((detector_out.Easting(end) - detector_out.Easting(1))*dx) ...
    *((detector_out.Northing(end) - detector_out.Northing(1))*dy)) ...
    - sum(sum(isnan(detector_out.Data)))*dx*dy;

% sort the confidences in the detector output
bw = detector_out;

bw.fa_area = area;

bw.filteredTruth = gt;
bw.targetFilter = params.targetFilter;

bw.Bullwinkle = [];


%Get Target UTMs
TargetRC(:,1) = gt.Targets_UTMx;
TargetRC(:,2) = gt.Targets_UTMy;

% make masks for intersection with target halo areas

bg_mask = true(n_row,n_col);
targ_mask = cell(1,n_targets);

for i=1:n_targets
    base = false(n_row,n_col);
    base(gt.Targets_rowIndices(i),gt.Targets_colIndices(i)) = true;
    
    if gt.Targets_Size(i) <= 1
        targ_mask{i} = imdilate(base,se1);
    elseif gt.Targets_Size(i) == 3
        targ_mask{i} = imdilate(base,se3);
    else
        targ_mask{i} = imdilate(base,se6);        
    end
    
    bg_mask(targ_mask{i}) = false;
end
bw.n_fa = sum(sum(and(bg_mask,~isnan(det_img))));

targ_val = inf(n_targets,1);
for i = 1:n_targets
    
     % for each target, determine the highest confidence within its halo
     targ_val(i) = max(max(det_img(targ_mask{i})));
end

found_inds = ~isnan(targ_val);

% cull out not found (NaN valued) targets
for i=1:numel(fields)
    if strcmp(fields{i},'id'), continue; end
    gt.(fields{i})(~found_inds) = [];
end

n_found = sum(found_inds);
targ_val(~found_inds) = [];
[svals,conf_sort] = sort(targ_val,'descend');

bw.ordered_tgt_ids = gt.Targets_ID(conf_sort);

k = 1;
i = 1;
while i <= n_found

    % determine number of alarms at this confidence
    n_at = 1;
    for j=(i+1):n_found
        if svals(j) == svals(i)
            n_at = n_at+1;
        else
            break;
        end
    end
   
    
    bin_img = det_img > svals(i);    
    n_fa_before = sum(sum(bin_img(bg_mask)));
    
    conf_bg = det_img(and(bin_img,bg_mask));
    if i > 1
        conf_before = min([svals(i-1); conf_bg(:)]);
    else
        conf_before = min([inf; conf_bg(:)]);    
    end
    
    bin_img = det_img == svals(i);    
    n_fa_at = sum(sum(bin_img(bg_mask)));
    
    
    tgt_ind = conf_sort(i);        
    
    bw.Bullwinkle{k,1} = conf_before; %svals(i);    
    bw.Bullwinkle{k,2} = (i-1)/n_targets; %PD
    bw.Bullwinkle{k,3} = n_fa_before/area;    % FAR
    bw.Bullwinkle{k,4} = 'FAR point';
    bw.Bullwinkle{k,5} = [];
    bw.Bullwinkle{k,6} = [];
    bw.Bullwinkle{k,7} = 'nan';
    bw.Bullwinkle{k,8} = 'nan';
    
    k = k + 1;
    
    bw.Bullwinkle{k,1} = svals(i);    
    bw.Bullwinkle{k,2} = (i-1+n_at)/n_targets; %PD    
    bw.Bullwinkle{k,3} = (n_fa_before+n_fa_at)/area;    % FAR
    tt = strcat(gt.Targets_Type(tgt_ind), '_', num2str(gt.Targets_Elevated(tgt_ind)), '_', num2str(gt.Targets_Size(tgt_ind)), '_', gt.Targets_ID(tgt_ind));
    bw.Bullwinkle{k,4} = tt;
    bw.Bullwinkle{k,5} = TargetRC(tgt_ind,2);
    bw.Bullwinkle{k,6} = TargetRC(tgt_ind,1);
    bw.Bullwinkle{k,7} = 'tbfi';
    bw.Bullwinkle{k,8} = 'tbfi';    
    
    k = k + 1;
    
    i = i+n_at;
end

% add an entry for terminal FAR

bw.Bullwinkle{k,1} = min(det_img(:));
bw.Bullwinkle{k,2} = 1; %PD
bw.Bullwinkle{k,3} = sum(sum(bg_mask))/area;    % FAR
bw.Bullwinkle{k,4} = 'Minimum Confidence';
bw.Bullwinkle{k,5} = [];
bw.Bullwinkle{k,6} = [];
bw.Bullwinkle{k,7} = 'nan';
bw.Bullwinkle{k,8} = 'nan';

bw.Bullwinkle_params = params;

if(iscell(bw.info.description))
        bw.info.description{end+1}.BW = ['Bullwinkle Output ',  datestr(clock)];
        bw.info.description{end}.BW_parameters = params;
else
        temp = bw.info.description;
        bw.info.description = [];
        bw.info.description{1} = temp;
        bw.info.description{2}.BW = ['Bullwinkle Output ',  datestr(clock)];
        bw.info.description{2}.BW_parameters = params;
end


end
