function [y,n_dim,vecs,vals,mu] = pca(x,frac,mask)
%
%function [y,n_dim,vecs,vals,mu] = pca(x,frac,mask)
%
% principal components analysis
%  transforms input data x using PCA, reduces dimensionality 
%  to capture fraction of magnitude of eigenvalues
%
% inputs:
%  x - input data M dimensions by N samples
%  frac - [0-1] fractional amount of total eigenvalue magnitude to retain, 1 = no dimensionality reduction
%  mask - binary mask of samples to include in covariance computation (use to mask off invalid pixels)
%          leave off the argument or use [] for no mask
%
% outputs:
%  y - PCA transformed dimensionality reduced data
%  n_dim - number of dimensions in the output data
%  vecs - full set of eigenvectors of covariance matrix (column vectors)
%  vals - eigenvalues of covariance matrix
%  mu - mean of input data, subtracted before rotating
%
%  8/7/2012 - Taylor C. Glenn - tcg@cise.ufl.edu

[n_dim,n_sample] = size(x);
if n_dim > 100
    fprintf('thats a lot of dimensions, this will probably crash\n');
    keyboard;
end

if ~exist('mask','var'), mask = []; end

if isempty(mask)
    mask = true(n_sample,1);
end

mu = mean(x(:,mask),2);
sigma = cov(x(:,mask)');

z = x - repmat(mu,[1 n_sample]);

[U,S,V] = svd(sigma);

vecs = U;
vals = diag(S);

mag = sum(vals);

ind = find(cumsum(vals)/mag >= frac,1,'first');
n_dim = ind;

y = vecs(:,1:ind)'*z;
