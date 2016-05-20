function [train_data,inds] = select_training_set(hsi_data,cos_angle_thresh,mask)
%function [train_data,inds] = select_training_set(hsi_data,cos_angle_thresh,mask)
%
% subsample the input data by adding data points to the training set only if
% they are have a cosine magnitude of less than cos_angle_thresh from all other
% points in the training set
% scans once through input data starting at 1st data point
%
% method idea from:
% Greer J.B., Sparse Demixing of Hyperspectral Images,
%  IEEE Transactions on Image Processing, vol 21, no 1, jan 2012
%
% inputs:
%  hsi_data - m_band x n_pixel - input hyperspectral data
%  cos_angle_thresh - threshold above which points are accepted
%  mask - binary mask indicating valid pixels
%
% outputs:
%  train_data - the reduced set suitable for training
%  inds - the indices of the train_data points in the input hsi_data
%
% 12/11/2012 - Taylor C. Glenn - tcg@cise.ufl.edu

[n_band,n_pix] = size(hsi_data);

Z = hsi_data./repmat(sqrt(sum(hsi_data.^2)),n_band,1);

inds = zeros(1,n_pix);

if ~exist('mask','var') || isempty(mask), mask = true(1,n_pix); end

first_val = find(mask,1,'first');

sel_set = zeros(n_band,n_pix);
sel_set(:,1) = Z(:,first_val);
inds(1) = first_val;

n_train = 1;

for i=(first_val+1):n_pix
    if ~mask(i), continue; end
    
    z = Z(:,i);
    ang = sel_set(:,1:n_train)'*z;
    if all(ang < cos_angle_thresh)
        n_train = n_train+1;
        sel_set(:,n_train) = z;
        inds(n_train) = i;
    end
    if mod(i,1000) == 0
        fprintf('.');
    end
end
fprintf('\n');

inds = inds(1:n_train);
train_data = hsi_data(:,inds);