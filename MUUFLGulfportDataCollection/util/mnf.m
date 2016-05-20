function [out_img,n_dim,vecs,vals,mu] = mnf(in_img,frac)
%
%function [y,n_dim,vecs,vals,mu] = mnf(x,frac)
%
% Maximum Noise Fraction transform for hyperspectral images
%  (actually a more useful minimum noise variant,
%   returns bands ordered by minimum noise fraction/max SNR)
%  transforms input image using MNF, reduces dimensionality 
%  to capture fraction of magnitude of total SNR eigenvalues
%
% inputs:
%  in_img - - n_row x n_col x n_band hyperspectral image
%  frac - [0-1] fractional amount of total eigenvalue magnitude to retain, 1 = no dimensionality reduction
%
% outputs:
%  out_img - MNF transformed dimensionality reduced data
%  n_dim - number of dimensions in the output data
%  vecs - full set of eigenvectors of mnf covariance matrix (column vectors)
%  vals - eigenvalues of covariance matrix
%  mu - mean of input data, subtracted before rotating
%
%  8/15/2012 - Taylor C. Glenn - tcg@cise.ufl.edu


% get the noise covariance

% assumes neighbor pixels are essentially the same except for noise
%   use a simple mask of neighbor pixels to the right and below
[n_row,n_col,n_band] = size(in_img);
n_pix = n_row*n_col;

hsi_data = double(reshape(in_img,[n_pix,n_band])');

mu = mean(hsi_data,2);

z = hsi_data - repmat(mu,[1 n_pix]);
z_img = reshape(z',[n_row,n_col,n_band]);

running_cov = zeros(n_band,n_band);

for i=1:n_col - 1
    for j=1:n_row - 1
        
        diff1 = squeeze(z_img(j,i+1,:) - z_img(j,i,:));
        diff2 = squeeze(z_img(j+1,i,:) - z_img(j,i,:));
        
        running_cov = running_cov + diff1*diff1' + diff2*diff2';                
        
    end
end

noise_cov = 1/(2*(n_row-1)*(n_col-1)-1) * running_cov;

[noiseU,noiseS,noiseV] = svd(noise_cov);

% align and whiten noise
hsi_prime = pinv(sqrt(noiseS)) * noiseU * z; 

% PCA the noise whitened data
[U,S,V] = svd(cov(hsi_prime')); % svd returns eigs in decreasing order

hsi_mnf = U*hsi_prime;

out_img = reshape(hsi_mnf',[n_row,n_col,n_band]);

vecs = U * pinv(sqrt(noiseS)) * noiseU;
vals = diag(S);

mag = sum(vals);
ind = find(cumsum(vals)/mag >= frac,1,'first');
n_dim = ind;
   
out_img = out_img(:,:,1:ind);

end


