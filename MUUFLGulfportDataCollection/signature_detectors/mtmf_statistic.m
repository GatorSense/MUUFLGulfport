function [mtmf_out,alpha_out] = mtmf_statistic(hsi_img,tgt_sig,mask)
%
%function [mtmf_out,alpha_out] = mtmf_statistic(hsi_img,tgt_sig,mask)
%
% Mixture Tuned Matched Filter Infeasibility Statistic 
%
% inputs:
%  hsi_image - n_row x n_col x n_band hyperspectral image
%  tgt_sig - target signature (n_band x 1 - column vector)
%  mask - binary image limiting detector operation to pixels where mask is true
%         if not present or empty, no mask restrictions are used
%
% outputs:
%  mtmf_out - MTMF infeasibility statistic
%  alpha_out - matched filter output
%
% 8/12/2012 - Taylor C. Glenn - tcg@cise.ufl.edu
%

if ~exist('mask','var'); mask = []; end

% mnf transform the image
[mnf_img,n_dim,mnf_vecs,mnf_eigvals,mnf_mu] = mnf(hsi_img,1);

s = mnf_vecs*(tgt_sig - mnf_mu);


[mtmf_out,alpha_out] = img_det(@mtmf_stat,mnf_img,s,mask,mnf_eigvals);

end

function [mtmf_data,alpha] = mtmf_stat(hsi_data,tgt_sig,mnf_eigvals)

[n_band,n_pix] = size(hsi_data);

z = hsi_data;
s = tgt_sig;
sts = s'*s;

alpha = zeros(1,n_pix);
mtmf_data = zeros(1,n_pix);

ev = sqrt(mnf_eigvals);
one = ones(n_band,1);

for i=1:n_pix
    a = s'*z(:,i) / sts;
    alpha(i) = max(0,min(1, a ));
    
    siginv = diag(1./((ev*(1-alpha(i)) - one).^2));
    
    mtmf_data(i) = z(:,i)'*siginv*z(:,i);
end

end
