function [qmf_out] = qmf_detector(hsi_img,tgt_sig,tgt_cov)
%
%function [qmf_out] = qmf_detector(hsi_img,tgt_sig,tgt_cov)
%
% Quadratic Spectral Matched Filter
%
% inputs:
%  hsi_image - n_row x n_col x n_band hyperspectral image
%  tgt_sig - mean target signature (n_band x 1 - column vector)
%  tgt_cov - covariance matrix for target
%
% outputs:
%  qmf_out - detector image
%
% 8/9/2012 - Taylor C. Glenn - tcg@cise.ufl.edu
%


[n_row,n_col,n_band] = size(hsi_img);
n_pix = n_row*n_col;

hsi_data = reshape(hsi_img,[n_pix,n_band])';

% get an estimate of the noise covariance of the image
running_cov = zeros(n_band,n_band);
for i=1:n_col - 1
    for j=1:n_row - 1
        
        diff1 = squeeze(hsi_img(j,i+1,:) - hsi_img(j,i,:));
        diff2 = squeeze(hsi_img(j+1,i,:) - hsi_img(j,i,:));
        
        running_cov = running_cov + diff1*diff1' + diff2*diff2';                
        
    end
end
noise_cov = 1/((2*n_pix-1)) * running_cov;

% precompute other statistics
mu = mean(hsi_data,2);
sigma = cov(hsi_data');

siginv_bn = pinv(sigma + noise_cov);
siginv_sn = pinv(tgt_cov + noise_cov);

z = hsi_data - repmat(mu,[1 n_pix]);
w = hsi_data - repmat(tgt_sig,[1 n_pix]);

% run the filter
qmf_data = zeros(1,n_pix);

for i=1:n_pix
    qmf_data(i) = z(:,i)'*siginv_bn*z(:,i) - w(:,i)'*siginv_sn*w(:,i) + log(det(sigma+noise_cov)/det(tgt_cov+noise_cov));
end

qmf_out = reshape(qmf_data,[n_row,n_col]);