function [lar_out] = lar_statistic(hsi_img,tgt_sig,bin_img,bg_ems)
%
%function [lar_out] = lar_statistic(hsi_img,tgt_sig,bin_img,bg_ems)
%
% Least Angle Regression Statistic 
%
% inputs:
%  hsi_image - n_row x n_col x n_band hyperspectral image
%  tgt_sig - target signature (n_band x 1 - column vector)
%  bin_img - binary detector output image, used for selecting targets and background
%  bg_ems - background endmembers
%
% outputs:
%  lar_out - LAR decision statistic
%
% 8/12/2012 - Taylor C. Glenn - tcg@cise.ufl.edu
%

% not technically LAR, but same ideas using full LMM constraints with SPICE

[n_row,n_col,n_band] = size(hsi_img);
n_pix = n_row*n_col;

hsi_data = double(reshape(hsi_img,[n_pix,n_band])');

bin_data = reshape(bin_img,[n_row, n_col]);

% find the endmembers of the background 

% unmix with and without the target signature
n_em = size(bg_ems,2);

params = SPICEParameters();
[bg_P] = unmix_qpas_correct(hsi_data, bg_ems, params.gamma, 1/(n_em)*ones(n_band,n_em), params);


targ_ems = [bg_ems tgt_sig];
[targ_P] = unmix_qpas_correct(hsi_data, targ_ems, params.gamma, 1/(n_em+1)*ones(n_band,n_em+1), params);

% compare the errors
err_bg = sum((hsi_data - bg_ems*bg_P').^2,1);

err_targ = sum((hsi_data - targ_ems*targ_P').^2,1);

lar_data = (n_em+1)/n_em * err_bg./err_targ;

lar_out = reshape(lar_data,[n_row,n_col]);