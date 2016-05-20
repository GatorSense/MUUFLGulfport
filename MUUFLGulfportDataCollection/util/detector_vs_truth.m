function [dvt,types,ids] = detector_vs_truth(hsi,det_out,filt,halo)
%function [dvt,types,ids] = detector_vs_truth(hsi,det_out,filt,halo)
% 
% Gets detector confidence for each target, put it in a matrix vs ground truth fields
%  for easy comparison
%
% outputs:
%  dvt - n_targets x 6 - [detector_output | id | size | type_idx | human_conf | human_cat]
%  types - cell array of target type names which type_idx indexes into
%  ids - cell array of target id names which id indexes into
%
%
% 12/9/2012 - Taylor C. Glenn - tcg@cise.ufl.edu

% determine which alarms to score
gt = hsi.groundTruth;

n_targets_orig = numel(gt.Targets_ID);

score_list = false(1,n_targets_orig);
for i=1:n_targets_orig
    score_list(i) = matches_filter(filt,gt.Targets_Type{i},gt.Targets_Size(i),gt.Targets_HumanConf(i),gt.Targets_HumanCat(i));           
end

types = unique(gt.Targets_Type);
ids = gt.Targets_ID;

% remove unscored targets from the truth
fields = fieldnames(gt);
for i=1:numel(fields)
    gt.(fields{i})(~score_list) = [];
end

n_targets = numel(gt.Targets_ID);
[n_row,n_col] = size(det_out);

se = strel('square',2*halo+1);
targ_val = zeros(n_targets,1);
targ_type = zeros(n_targets,1);
targ_id = zeros(n_targets,1);

for i=1:n_targets
    base = false(n_row,n_col);
    base(gt.Targets_rowIndices(i),gt.Targets_colIndices(i)) = true;
    
    targ_mask = imdilate(base,se);
    
    % for each target, detemine the highest confidence within its halo
    targ_val(i) = max(max(det_out(targ_mask)));
    
    targ_type(i) = find(strcmp(types,gt.Targets_Type{i}));
    targ_id(i) = find(strcmp(ids,gt.Targets_ID{i}));
end

dvt = [targ_val targ_id gt.Targets_Size' targ_type gt.Targets_HumanConf' gt.Targets_HumanCat'];

end