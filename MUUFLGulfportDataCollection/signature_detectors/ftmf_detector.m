function [ftmf_out] = ftmf_detector(hsi_img,tgt_sig,gamma)
%
%function [ftmf_out] = ftmf_detector(hsi_img,tgt_sig,gamma)
%
% Finite Target Matched Filter
%
% inputs:
%  hsi_image - n_row x n_col x n_band hyperspectral image
%  tgt_sig - target signature (n_band x 1 - column vector)
%  gamma - scale factor of background variance to model target variance (V_t = gamma^2*V_bg)
%
% outputs:
%  ftmf_out - detector image
%
% 8/12/2012 - Taylor C. Glenn - tcg@cise.ufl.edu
%

% makes the simplifying assumption that target variance
%  is a scaled version of bg variance
% Eismann pp 681

[n_row,n_col,n_band] = size(hsi_img);
n_pix = n_row*n_col;

hsi_data = reshape(hsi_img,[n_pix,n_band])';

mu = mean(hsi_data,2);
sigma = cov(hsi_data');
siginv = pinv(sigma);

s = tgt_sig - mu;
z = hsi_data - repmat(mu,[1 n_pix]);
f = s'*siginv;

scr = s'*siginv*s; %signal to cluter ratio

ftmf_data = zeros(1,n_pix);
g2p1 = gamma^2 +1;

for i=1:n_pix
    
    md = z(:,i)'*siginv*z(:,i); % mahalanobis dist
    mf = f*z(:,i);              % matched filter
    
    A = n_band*g2p1^2;
    B = (mf - 3*n_band)*g2p1^2 - scr;
    C = -md*g2p1 + n_band*gamma^2 + 3*n_band + scr;
    D = -n_band - mf + md;
    
    r = roots([A B C D]);
    
    r_ind = find(and(r >=0,r <= 1),1,'first');
    if isempty(r_ind)
        alpha = 1;
    else
        alpha = r(r_ind);
    end
    
    mu_a = alpha*s + (1-alpha)*mu;
    sigma_a = (alpha^2*gamma^2 + (1-alpha)^2)*sigma;
    siginv_a = pinv(sigma_a);
    
    x_mu_a = hsi_data(:,i) - mu_a;
    
    ftmf_data(i) = md - x_mu_a'*siginv_a*x_mu_a - log(det(sigma_a));
end

ftmf_out = reshape(ftmf_data,[n_row,n_col]);

