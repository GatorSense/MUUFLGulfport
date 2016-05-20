function [out,sig_ind] = ace_rx_detector(hsi_img,tgt_sig,mask,guard_win,bg_win,beta)
%
%function [out,sig_ind] = ace_rx_detector(hsi_img,tgt_sig,mask)
%
% Adaptive Cosine/Coherence Estimator with RX style local background estimation
%
% inputs:
%  hsi_image - n_row x n_col x n_band hyperspectral image
%  tgt_sig - target signature (n_band x 1 - column vector)
%  mask - binary image limiting detector operation to pixels where mask is true
%         if not present or empty, no mask restrictions are used
%  guard_win - guard window radius (square,symmetric about pixel of interest) 
%  bg_win - background window radius
%
% outputs:
%  out - detector image
%
% 10/25/2012 - Taylor C. Glenn - tcg@cise.ufl.edu
%

[n_row,n_col,n_band] = size(hsi_img);

if ~exist('mask','var') || isempty(mask), mask = true(n_row,n_col); end
if ~exist('bg_win','var'), bg_win = 4; end
if ~exist('guard_win','var'), guard_win = 2; end
if ~exist('beta','var'), beta = 0; end

reg = beta*eye(n_band);

[out,sig_ind] = rx_det(@ace_rx_pt,hsi_img,tgt_sig,mask,guard_win,bg_win,reg);

end

function [r,sig_ind] = ace_rx_pt(x,ind,bg,b_mask,args,reg)

if ~isempty(bg)
    siginv = pinv(cov(bg') + reg);
    mu = mean(bg,2);
else
    siginv = args.global_siginv;
    mu = args.global_mu;
end
z = x - mu;
s = args.tgt_sigs - repmat(mu,1,args.n_sig);
sigout = zeros(1,args.n_sig);
for k=1:args.n_sig
    st_siginv = s(:,k)'*siginv;
    st_siginv_s = s(:,k)'*siginv*s(:,k);
    
    sigout(k) = (st_siginv*z)^2 / (st_siginv_s * z'*siginv*z);
end
[r,sig_ind] = max(sigout);

end

