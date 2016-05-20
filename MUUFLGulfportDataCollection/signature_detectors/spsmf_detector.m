function [spsmf_out] = spsmf_detector(hsi_img,tgt_sig,mask)
%
%function [spsmf_out] = spsmf_detector(hsi_img,tgt_sig,mask)
%
% Subpixel Spectral Matched Filter
%  matched filter derived from a subpixel mixing model
%  H0: x = b
%  H1: x = alpha*s + beta*b 
%
% inputs:
%  hsi_image - n_row x n_col x n_band hyperspectral image
%  tgt_sig - target signature (n_band x 1 - column vector)
%  mask - binary image limiting detector operation to pixels where mask is true
%         if not present or empty, no mask restrictions are used
%
% outputs:
%  spsmf_out - detector image
%
% 8/8/2012 - Taylor C. Glenn - tcg@cise.ufl.edu
%

if ~exist('mask','var'); mask = []; end

spsmf_out = img_det(@spsmf_det,hsi_img,tgt_sig,mask);

end

function spsmf_data = spsmf_det(hsi_data,tgt_sig)

% formulation from Eismann's book, pp 664

[n_band,n_pix] = size(hsi_data);

mu = mean(hsi_data,2);
siginv = pinv(cov(hsi_data'));

s = tgt_sig;
st_siginv = s'*siginv;
st_siginv_s = s'*siginv*s;
K = n_band;

spsmf_data = zeros(1,n_pix);

for i=1:n_pix
    
    x = hsi_data(:,i);
    st_siginv_x = st_siginv*x;
    
    a0 = (x'*siginv*x)*st_siginv_s - (st_siginv_x)^2;
    a1 = st_siginv_x*(s'*siginv*mu) - st_siginv_s * (mu'*siginv*x);
    a2 = -K*st_siginv_s;
    
    beta = (-a1 + sqrt(a1^2 - 4*a2*a0)) / (2*a2);
    alpha = st_siginv*(x - beta*mu) / st_siginv_s;
    
    z1 = x - mu;
    z2 = x-alpha*s-beta*mu;
    spsmf_data(i) = z1'*siginv*z1 - (1/beta^2) *(z2'*siginv*z2) - 2*K*log(abs(beta));

end

end


