function [fam_out] = fam_statistic(hsi_img,tgt_sig)
%
%function [fam_out] = fam_statistic(hsi_img,tgt_sig)
%
% False Alarm Mitigation Statistic from Subpixel Replacement Model
%
% inputs:
%  hsi_image - n_row x n_col x n_band hyperspectral image
%  tgt_sig - target signature (n_band x 1 - column vector)
%
% outputs:
%  fam_out - false alarm mitigation statistic
%
% 8/8/2012 - Taylor C. Glenn - tcg@cise.ufl.edu
%

% assume target variance same as background variance

[n_row,n_col,n_band] = size(hsi_img);
n_pix = n_row*n_col;

hsi_data = reshape(hsi_img,[n_pix,n_band])';

mu = mean(hsi_data,2);
siginv = pinv(cov(hsi_data'));

s = tgt_sig;
sts = s'*s;
s_mu = s - mu;

z = hsi_data - repmat(mu,[1 n_pix]);

fam_data = zeros(1,n_pix);

for i=1:n_pix
    alpha = s'*hsi_data(:,i) / sts;
    w = z(:,i) - alpha*s_mu;
    
    fam_data(i) = w'*siginv*w;
end

fam_out = reshape(fam_data,[n_row,n_col]);