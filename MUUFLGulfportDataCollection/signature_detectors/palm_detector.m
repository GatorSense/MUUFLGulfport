function [palm_out] = palm_detector(hsi_img,tgt_sig,mask,n_comp)
%
%function [palm_out] = palm_detector(hsi_img,tgt_sig,mask,n_comp)
%
% Pairwise Adaptive Linear Matched Filter
%
% inputs:
%  hsi_image - n_row x n_col x n_band hyperspectral image
%  tgt_sig - target signature (n_band x 1 - column vector)
%  mask - binary image limiting detector operation to pixels where mask is true
%         if not present or empty, no mask restrictions are used
%  n_comp - number of Gaussian components to use
%
% outputs:
%  palm_out - detector image
%
% 8/8/2012 - Taylor C. Glenn - tcg@cise.ufl.edu
%

if ~exist('mask','var'); mask = []; end
if ~exist('n_comp','var'); n_comp = 5; end

palm_out = img_det(@palm_det,hsi_img,tgt_sig,mask,n_comp);

end

function palm_data = palm_det(hsi_data,tgt_sig,n_comp)

[n_band,n_pix] = size(hsi_data);

% fit the model
gmm = gmdistribution.fit(hsi_data',n_comp,'Replicates',1,'Regularize',1e-6);

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

% run against all filter, choose the smallest output
palm_data = zeros(1,n_pix);

for i=1:n_pix
    
    dists = zeros(1,n_comp);
    for j=1:n_comp
        dists(j) = (filt{j}*(hsi_data(:,i) - mu{j}))^2;
    end
    palm_data(i) = min(dists);
end

end
