function [smf_out] = smf_max_detector(hsi_img,tgt_sigs,mask)
%
%function [smf_out] = smf_max_detector(hsi_img,tgt_sigs,mask)
%
% Spectral Matched Filter, Max over targets
%
% inputs:
%  hsi_image - n_row x n_col x n_band hyperspectral image
%  tgt_sigs - target signatures (n_band x n_signatures)
%  mask - binary image limiting detector operation to pixels where mask is true
%         if not present or empty, no mask restrictions are used
%
% outputs:
%  smf_out - detector image
%
% 8/8/2012 - Taylor C. Glenn - tcg@cise.ufl.edu
%

if ~exist('mask','var'); mask = []; end

n_sig = size(tgt_sigs,2);
[n_row,n_col,n_dim] = size(hsi_img);

sig_out = zeros(n_row,n_col,n_sig);

for i=1:n_sig
    sig_out(:,:,i) = img_det(@smf_detector_array,hsi_img,tgt_sigs(:,i),mask);
end
smf_out = max(sig_out,[],3);
