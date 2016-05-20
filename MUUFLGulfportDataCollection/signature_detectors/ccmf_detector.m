function [ccmf_out,gmm] = ccmf_detector(hsi_img,tgt_sig,mask,n_comp,gmm)
%
%function [ccmf_out,gmm] = ccmf_detector(hsi_img,tgt_sig,mask,n_comp,gmm)
%
% Class Conditional Matched Filters
%
% inputs:
%  hsi_image - n_row x n_col x n_band hyperspectral image
%  tgt_sig - target signature (n_band x 1 - column vector)
%  mask - binary image limiting detector operation to pixels where mask is true
%         if not present or empty, no mask restrictions are used
%  n_comp - number of Gaussian components to use
%  gmm - optional mixture model structure from previous training data
%
% outputs:
%  ccmf_out - detector image
%  gmm - mixture model learned from input image
%
% 8/8/2012 - Taylor C. Glenn - tcg@cise.ufl.edu
%

if ~exist('mask','var'); mask = []; end
if ~exist('n_comp','var'); n_comp = 5; end
if ~exist('gmm','var'); gmm = []; end

[ccmf_out,gmm] = img_det(@ccmf_det,hsi_img,tgt_sig,mask,n_comp,gmm);

end

function [ccmf_data,gmm] = ccmf_det(hsi_data,tgt_sig,n_comp,gmm)

[n_band,n_pix] = size(hsi_data);

if isempty(gmm)
    % fit the model
    gmm = gmdistribution.fit(hsi_data',n_comp,'Replicates',1,'Regularize',1e-6);
end

% make a matched filter for each background class
means = gmm.mu;
sigmas = gmm.Sigma;

mu = cell(1,n_comp);
siginv = cell(1,n_comp);
filt = cell(1,n_comp);
for i=1:n_comp
   mu{i} = means(i,:)';
   siginv{i} = pinv(squeeze(sigmas(:,:,i)));
   
   s = tgt_sig - mu{i};
   filt{i} = s'*siginv{i} / sqrt(s'*siginv{i}*s);
end

% run appropriate filter for class of each pixel
idx = gmm.cluster(hsi_data');

ccmf_data = zeros(1,n_pix);

for i=1:n_pix
    ccmf_data(i) = filt{idx(i)}*(hsi_data(:,i) - mu{idx(i)});
end

end
