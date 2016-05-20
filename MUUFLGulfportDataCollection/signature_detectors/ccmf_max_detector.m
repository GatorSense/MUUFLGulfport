function [ccmf_out] = ccmf_max_detector(hsi_img,tgt_sigs,mask,n_comp)
%
%function [ccmf_out] = ccmf_max_detector(hsi_img,tgt_sigs,mask,n_comp)
%
% Class Conditional Matched Filters, max over targets
%
% inputs:
%  hsi_image - n_row x n_col x n_band hyperspectral image
%  tgt_sig - target signature (n_band x 1 - column vector)
%  mask - binary image limiting detector operation to pixels where mask is true
%         if not present or empty, no mask restrictions are used
%  n_comp - number of Gaussian components to use
%
% outputs:
%  ccmf_out - detector image
%
% 7/16/2012 - Taylor C. Glenn - tcg@cise.ufl.edu
%

if ~exist('mask','var'); mask = []; end
if ~exist('n_comp','var'); n_comp = 5; end

ccmf_out = img_det(@ccmf_max_det,hsi_img,tgt_sigs,mask,n_comp);

end

function ccmf_max_data = ccmf_max_det(hsi_data,tgt_sigs,n_comp)

[n_band,n_pix] = size(hsi_data);
n_sigs = size(tgt_sigs,2);

% fit the model
gmm = gmdistribution.fit(hsi_data',n_comp,'Replicates',1,'Regularize',1e-6);

% make a matched filter for each background class
means = gmm.mu;
sigmas = gmm.Sigma;

mu = cell(1,n_comp);
siginv = cell(1,n_comp);
filt = cell(n_comp,n_sigs);
for i=1:n_comp
   mu{i} = means(i,:)';
   siginv{i} = pinv(squeeze(sigmas(:,:,i)));
   
   for j=1:n_sigs
       s = tgt_sigs(:,j) - mu{i};
       filt{i,j} = s'*siginv{i} / sqrt(s'*siginv{i}*s);
   end
end

% run appropriate filter for class of each pixel
idx = gmm.cluster(hsi_data');

ccmf_data = zeros(n_sigs,n_pix);

for i=1:n_pix
    for j=1:n_sigs
        ccmf_data(j,i) = filt{idx(i),j}*(hsi_data(:,i) - mu{idx(i)});
    end
end
ccmf_max_data = max(ccmf_data,[],1);

end
