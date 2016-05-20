function [osp_out] = osp_detector(hsi_img,tgt_sig,mask,n_dim_ss)
%
%function [osp_out] = osp_detector(hsi_img,tgt_sig,mask,n_dim_ss)
%
% Orthogonal Subspace Projection Detector
%
% inputs:
%  hsi_image - n_row x n_col x n_band hyperspectral image
%  tgt_sig - target signature (n_band x 1 - column vector)
%  mask - binary image limiting detector operation to pixels where mask is true
%         if not present or empty, no mask restrictions are used
%  n_dim_ss - number of dimensions to use in the background subspace
%
% outputs:
%  osp_out - detector image
%
% 8/8/2012 - Taylor C. Glenn - tcg@cise.ufl.edu
%

if ~exist('mask','var'); mask = []; end
if ~exist('n_dim_ss','var'); n_dim_ss = 2; end

osp_out = img_det(@osp_det,hsi_img,tgt_sig,mask,n_dim_ss);

end

function osp_data = osp_det(hsi_data,tgt_sig,n_dim_ss)

% see Eismann, pp670
[n_band,n_pix] = size(hsi_data);

mu = mean(hsi_data,2);
x = hsi_data - repmat(mu,[1, n_pix]);

% get pca rotation, no dim reduction
[pca_data,~,vecs,vals] = pca(hsi_data,1);

s = (tgt_sig - mu);

% get a subspace that theoretically encompasses the background
B = vecs(:,1:n_dim_ss);

PB = B*pinv(B'*B)*B';
PperpB = eye(n_band) - PB;

f = s'*PperpB;

osp_data = zeros(1,n_pix);

for i=1:n_pix
    osp_data(i) = f*x(:,i);
end

end
