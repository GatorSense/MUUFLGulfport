function [smf_data,mu,siginv] = smf_detector_array(hsi_data,tgt_sig,mu,siginv)
%
%function [smf_data,mu,siginv] = smf_detector_array(hsi_data,tgt_sig,mu,siginv)
%
% Spectral Matched Filter for array (not image) data
%
% inputs:
%  hsi_data - n_spectra x n_band array of hyperspectral data
%  tgt_sig - target signature (n_band x 1 - column vector)
%  mu - (optional) mean for filter
%  siginv - (optional) inverse covariance for filter
%
% outputs:
%  smf_out - detector output per spectra
%  mu - mean of filter
%  siginv - inverse covariance of filter
%
% 8/19/2012 - Taylor C. Glenn - tcg@cise.ufl.edu
%

% alternative formulation from Eismann's book, pp 653
%  subtract mean from target to reduce effect of additive model
%  on hyperspectral (non additive) data
%  also take positive square root of filter

if ~exist('mu','var') || isempty(mu)
    mu = mean(hsi_data,2);
end
if ~exist('siginv','var') || isempty(siginv)
    siginv = pinv(cov(hsi_data'));
end

s = tgt_sig - mu;
z = hsi_data - repmat(mu,[1 size(hsi_data,2)]);
f = s'*siginv / sqrt(s'*siginv*s);

smf_data = f*z;