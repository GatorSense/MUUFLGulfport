function [smf_out,mu,siginv] = smf_detector(hsi_img,tgt_sig,mask,mu,siginv)
%
%function [smf_out,mu,siginv] = smf_detector(hsi_img,tgt_sig,mask,mu,siginv)
%
% Spectral Matched Filter
%
% inputs:
%  hsi_image - n_row x n_col x n_band hyperspectral image
%  tgt_sig - target signature (n_band x 1 - column vector)
%  mask - binary image limiting detector operation to pixels where mask is true
%         if not present or empty, no mask restrictions are used
%  mu - (optional) mean for filter
%  siginv - (optional) inverse covariance for filter
%
% outputs:
%  smf_out - detector image
%  mu - mean of filter
%  siginv - inverse covariance of filter
%
% 8/8/2012 - Taylor C. Glenn - tcg@cise.ufl.edu
%

if ~exist('mask','var'); mask = []; end
if ~exist('mu','var'), mu = []; end
if ~exist('siginv','var'), siginv = []; end

[smf_out,mu,siginv] = img_det(@smf_detector_array,hsi_img,tgt_sig,mask,mu,siginv);

