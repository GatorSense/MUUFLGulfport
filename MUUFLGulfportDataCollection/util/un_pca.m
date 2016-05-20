function x = un_pca(y,vecs,mu)
%
%function x = un_pca(y,vecs,mu)
%
% Undo Principal Component Analysis transform
%
% inputs:
%  y - input data n_dim x n_samples
%  vecs - pca vectors n_dim x n_dim_orig (or n_dim_orig x n_dim_orig)
%  mu - mean of original space data n_dim_orig x 1
%
% outputs:
%  x - y transformed back to original space
%
% 8/17/2012 - Taylor C. Glenn - tcg@cise.ufl.edu

x = (vecs(:,1:size(y,1))*y) + repmat(mu,[1 size(y,2)]);