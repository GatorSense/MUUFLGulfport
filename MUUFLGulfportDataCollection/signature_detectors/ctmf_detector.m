function [ctmf_out,cluster_img] = ctmf_detector(hsi_img,tgt_sig,n_cluster)
%
%function [ctmf_out,cluster_img] = ctmf_detector(hsi_img,tgt_sig,n_cluster)
%
% Clutter Tuned Matched Filter (ctmf)
%  k-means cluster all spectra, make a matched filter for each cluster
%
% inputs:
%  hsi_image - n_row x n_col x n_band hyperspectral image
%  tgt_sig - target signature (n_band x 1 - column vector)
%  n_cluster - number of clusters to use
%
% outputs:
%  ctmf_out - detector output image
%  cluster_img - cluster label image
%
% 8/15/2012 - Taylor C. Glenn - tcg@cise.ufl.edu
%


[n_row,n_col,n_band] = size(hsi_img);
n_pix = n_row*n_col;

hsi_data = reshape(hsi_img,[n_pix,n_band])';

% cluster the data
[idx,C] = kmeans(hsi_data',n_cluster,'emptyaction','singleton');

cluster_img = reshape(idx,[n_row,n_col]);

% get cluster statistics, create matched filters

mu = cell(1,n_cluster);
siginv = cell(1,n_cluster);
f = cell(1,n_cluster);
for i=1:n_cluster
    
    z = hsi_data(:,idx == i);
    
    mu{i} = mean(z,2);
    
    siginv{i} = pinv(cov(z'));

    s = tgt_sig - mu{i};    
    f{i} = s'*siginv{i} / sqrt(s'*siginv{i}*s);
end

% compute matched filter output of each point
ctmf_data = zeros(1,n_pix);

for i=1:n_pix
    z = hsi_data(:,i) - mu{idx(i)};
    
    ctmf_data(i) = f{idx(i)}*z;
end

ctmf_out = reshape(ctmf_data,[n_row,n_col]);

