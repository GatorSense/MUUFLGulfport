function [rhmf_out] = rhmf_detector(hsi_img,tgt_sig,mask)
%
%function [rhmf_out] = rhmf_detector(hsi_img,tgt_sig,mask)
%
% Robust High Order Matched Filter
%  linear filter with minimized high order statistics
%
% ref: Robust high-order matched filter for hyperspectral target detection
%  Shi, Z. and Yang, S., Electronics Letters, 2010
%
% inputs:
%  hsi_image - n_row x n_col x n_band hyperspectral image
%  tgt_sig - target signature (n_band x 1 - column vector)
%  mask - binary image limiting detector operation to pixels where mask is true
%         if not present or empty, no mask restrictions are used
%
% outputs:
%  rhmf_out - detector image
%
% 10/31/2012 - Taylor C. Glenn - tcg@cise.ufl.edu
%

if ~exist('mask','var'); mask = []; end

rhmf_out = img_det(@rhmf_det,hsi_img,tgt_sig,mask);

end

function rhmf_data = rhmf_det(hsi_data,tgt_sig)

[n_band,n_pix] = size(hsi_data);

% first whiten the data
mu = mean(hsi_data,2);

siginv = pinv(cov(hsi_data'));
V = chol(siginv);

z = V*(hsi_data - repmat(mu,[1,n_pix]));
s = V*(tgt_sig - mu);

% learn the filter via gradient descent algorithm
w = randn(n_band,1);
w = w/norm(w);

epsilon = 0.1;
rate = 1e-4;

max_iter = 1000;
stop_thresh = 1e-6;

for i=1:max_iter
    w_old = w;
    lambda = sum((w-s).^2) - epsilon;

    Eg = mean(z .* repmat(4*(w'*z).^3,[n_band,1]),2);
    
    w = w - rate*(Eg + 2*lambda*(w-s));
    w = w./norm(w);
    if norm(w-w_old) < stop_thresh
        fprintf('RHMF training converged in %d iters\n',i);
        break;
    end
end
    

% apply the filter
rhmf_data = zeros(1,n_pix);

for i=1:n_pix
    rhmf_data(i) = w'*hsi_data(:,i);
end

end