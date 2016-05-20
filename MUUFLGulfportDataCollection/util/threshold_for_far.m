function th = threshold_for_far(target_far,hsi,det_img,filt,params)
% th = threshold_for_far(target_far,hsi,det_img,filt,params)
%
%  finds the threshold for a given false alarm rate in the detector output image (det_img)
%
% 2/9/2013 - Taylor Glenn - tcg@cise.ufl.edu 

if ~exist('params','var') || isempty(params)
    params = BullwinkleParameters();
end

gt = hsi.groundTruth;

n_targets_orig = numel(gt.Targets_ID);

score_list = false(1,n_targets_orig);
for i=1:n_targets_orig
    score_list(i) = matches_filter(filt,gt.Targets_Type{i},gt.Targets_Size(i),gt.Targets_HumanConf(i),gt.Targets_HumanCat(i));           
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

[n_row,n_col] = size(det_img);

se1 = strel('square',2*params.Halo+1); %small region for .5m,1m targets
se3 = strel('square',2*params.Halo+3); %larger region for 3m targets
se6 = strel('rectangle',[2*params.Halo+13,2*params.Halo+11]); % rediculous region to mask out cal cloths 

if params.ignore_clutter
    
    null_mask = false(n_row,n_col);
    for i=1:n_targets_orig
        
        if score_list(i), continue; end
        base = false(n_row,n_col);
        gto = hsi.groundTruth; %original ground truth
        
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
if isfield(hsi.info,'map_info')
    dx = hsi.info.map_info.dx;
    dy = hsi.info.map_info.dy;
else
    dx = 1;
    dy = 1;
end

area = abs(((hsi.Easting(end) - hsi.Easting(1))*dx) ...
    *((hsi.Northing(end) - hsi.Northing(1))*dy)) ...
    - sum(sum(isnan(det_img)))*dx*dy;

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

% find the target number of false alarms, then get the confidence
%  of the sorted false alarm at that index
target_fas = ceil(target_far*area);

fa_vals = det_img(bg_mask);
sfa_vals = sort(fa_vals(~isnan(fa_vals)),'descend');

if target_fas ~= 0
    th = sfa_vals(min(end,target_fas));
else
    th = max(det_img(:));
end

end