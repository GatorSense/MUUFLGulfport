function [ace_out] = ace_ss_detector(hsi_img,tgt_sigs,mask)
%
%function [ace_out] = ace_ss_detector(hsi_img,tgt_sigs,mask)
%
% Adaptive Cosine/Coherence Estimator - Subspace Formulation
%
% inputs:
%  hsi_image - n_row x n_col x n_band hyperspectral image
%  tgt_sigs - target signatures (n_band x M - column vector)
%  mask - binary image limiting detector operation to pixels where mask is true
%         if not present or empty, no mask restrictions are used
%
% outputs:
%  ace_out - detector image
%
% 8/8/2012 - Taylor C. Glenn - tcg@cise.ufl.edu
%

if ~exist('mask','var'); mask = []; end

ace_out = img_det(@ace_ss_det,hsi_img,tgt_sigs,mask);

end

function ace_data = ace_ss_det(hsi_data,tgt_sigs)

n_pix = size(hsi_data,2);
n_sigs = size(tgt_sigs,2);
    
mu = mean(hsi_data,2);
siginv = pinv(cov(hsi_data'));

S = tgt_sigs - repmat(mu,[1,n_sigs]);
z = bsxfun(@minus,hsi_data,mu);

G = siginv*S*pinv(S'*siginv*S)*S'*siginv;

A = sum(z.*(G*z),1);
B = sum(z.*(siginv*z),1);

ace_data = A./B;

% ace_data = zeros(1,n_pix);
% for i=1:n_pix
%     ace_data(i) = (z(:,i)'*G*z(:,i)) / (z(:,i)'*siginv*z(:,i));
% end

end



