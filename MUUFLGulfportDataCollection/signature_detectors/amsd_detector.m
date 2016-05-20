function [amsd_out] = amsd_detector(hsi_img,tgt_sigs,mask,n_dim_tgt,n_dim_bg)
%
%function [amsd_out] = amsd_detector(hsi_img,tgt_sigs,mask,n_dim_tgt,n_dim_bg)
%
% Adaptive Matched Subspace Detector
%
%  ref:
%  Hyperspectral subpixel target detection using the linear mixing model (article)
%  Manolakis, D. and Siracusa, C. and Shaw, G.
%  Geoscience and Remote Sensing, IEEE Transactions on
%  2001 Volume 39 Number 7 Pages 1392 -1409 Month jul
%
% inputs:
%  hsi_image - n_row x n_col x n_band hyperspectral image
%  tgt_sigs - target signature(s) (n_band x n_sig - column vectors)
%  mask - binary image limiting detector operation to pixels where mask is true
%         if not present or empty, no mask restrictions are used
%  n_dim_tgt - number of dimensions to use for target subspace, 
%              if argument is 0, use the target sigs themselves
%  n_dim_bg - number of dimensions to use for background subspace
%
% outputs:
%  amsd_out - detector image
%
% 8/22/2012 - Taylor C. Glenn - tcg@cise.ufl.edu
%

if ~exist('mask','var'); mask = []; end
if ~exist('n_dim_tgt','var'); n_dim_tgt = 1; end
if ~exist('n_dim_bg','var'); n_dim_bg = 5; end

amsd_out = img_det(@amsd_det,hsi_img,tgt_sigs,mask,n_dim_tgt,n_dim_bg);

end

function amsd_data = amsd_det(hsi_data,tgt_sigs,n_dim_tgt,n_dim_bg)

[n_band,n_pix] = size(hsi_data);
n_sigs = size(tgt_sigs,2);

% find the target and background subspaces

corr_bg = zeros(n_band,n_band);
for i=1:n_pix
    corr_bg = corr_bg + hsi_data(:,i)*hsi_data(:,i)';
end
corr_bg = corr_bg/n_pix;

[Ubg,Sbg,Vbg] = svd(corr_bg,0);

S_bg = Ubg(:,1:n_dim_bg);


if n_dim_tgt > 0
    corr_tgt = zeros(n_band,n_band);
    for i=1:n_sigs
        corr_tgt = corr_tgt+tgt_sigs(:,i)*tgt_sigs(:,i)';
    end
    corr_tgt = corr_tgt/n_sigs;
    
    
    [Ut,St,Vt] = svd(corr_tgt,0);
    S_t = Ut(:,1:n_dim_tgt);
else
    S_t = tgt_sigs;
end

% find the projection matrices
S = [S_t S_bg];
P_S = S*pinv(S'*S)*S';

P_b = S_bg*pinv(S_bg'*S_bg)*S_bg';

% find the perpendicular subspaces
P_perp_S = eye(n_band) - P_S;
P_perp_b = eye(n_band) - P_b;

PZ = P_perp_b - P_perp_S;

amsd_data = zeros(1,n_pix);

for i=1:n_pix
    x = hsi_data(:,i);
    amsd_data(i) = (x'*PZ*x) / (x'*P_perp_S*x);
end

end