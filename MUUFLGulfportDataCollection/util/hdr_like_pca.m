function [y,n_dim,vecs,vals,mu,dr_hsi] = hdr_like_pca(hsi,n_dim)
%
%function [y,n_dim,vecs,vals,mu,dr_hsi] = hdr_like_pca(hsi,n_dim)
%
% Hierarchical Dimensionality Reduction
%  wrapper over the HierarchicalDimReduction hsitoolkit code
%  transforms input image using hierarchical clustering for dimensionality reduction
%  gives results in a similar format to the pca utility code for easy interchangeability
%
% inputs:
%  hsi - hyperspectral image input in hylid structure format
%  n_dim - number of desired output dimensions
%
% outputs:
%  y - dimensionality reduced data
%  n_dim - number of dimensions in the output data
%  vecs - a set of column vectors that perform equivalent averaging to the HDR process
%  vals - identity matrix M x M
%  mu - zeros M x 1
%  dr_hsi - output hylid struct from dimReduction() call
%
%  8/17/2012 - Taylor C. Glenn - tcg@cise.ufl.edu

[n_row,n_col,n_band] = size(hsi.Data);
n_pix = n_row*n_col;

mu = zeros(n_band,1);
vals = eye(n_band);

params = dimReductionParameters();
params.savePrevResuts = 0;
params.numBands = n_dim;
params.showH = 0;

dr_hsi = dimReduction(hsi, params);

y = double(reshape(dr_hsi.Data,[n_pix,n_dim])');

% renumber the band clusters
orig_bc = dr_hsi.band_clusters;
bc = zeros(size(orig_bc));

ind = 0;
last_c = 0;

for i=1:numel(bc)
    if orig_bc(i) ~= last_c
        last_c = orig_bc(i);
        ind = ind+1;        
    end        
    bc(i) = ind;
end

% make equivalent transform for each cluster
%  (average the constituent bands)
vecs = zeros(n_band,n_band);
for i=1:n_dim   
    vecs(bc == i,i) = 1/(sum(bc == i));    
end


