function mask = generate_target_mask(hsi,filt,halo)
%function mask = generate_target_mask(hsi,filt,halo)
%
% generates a binary image mask with halo of pixels around each target
%  that matches the filter
%
% 10/30/2012 - Taylor C. Glenn - tcg@cise.ufl.edu


% determine which alarms to score
gt = hsi.groundTruth;

n_targets_orig = numel(gt.Targets_ID);

score_list = false(1,n_targets_orig);
for i=1:n_targets_orig
    score_list(i) = matches_filter(filt,gt.Targets_Type{i},gt.Targets_Size(i),gt.Targets_HumanConf(i),gt.Targets_HumanCat(i));           
end

% remove unscored targets from the truth
fields = fieldnames(gt);
for i=1:numel(fields)
    gt.(fields{i})(~score_list) = [];
end

n_targets = numel(gt.Targets_ID);
[n_row,n_col,n_band] = size(hsi.Data);

se = strel('square',2*halo+1);
targ_val = zeros(n_targets,1);

base = false(n_row,n_col);
for i=1:n_targets
    
    base(gt.Targets_rowIndices(i),gt.Targets_colIndices(i)) = true;    
end
mask = imdilate(base,se);

end