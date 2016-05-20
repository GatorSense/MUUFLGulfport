function [cem_out,w] = cem_detector(hsi_img,tgt_sigs,mask)
%
%function [cem_out,w] = cem_detector(hsi_img,tgt_sigs,mask)
%
% Constrained Energy Minimization Detector
%  solution to filter with minimum energy projected into background space
%
% inputs:
%  hsi_image - n_row x n_col x n_band hyperspectral image
%  tgt_sigs - target signatures (n_band x n_sigs)
%  mask - binary image limiting detector operation to pixels where mask is true
%         if not present or empty, no mask restrictions are used
%
% outputs:
%  cem_out - detector image
%  w - cem filter
%
% 8/8/2012 - Taylor C. Glenn - tcg@cise.ufl.edu
%

if ~exist('mask','var'); mask = []; end

[cem_out,w] = img_det(@cem_det,hsi_img,tgt_sigs,mask);

end

function [cem_data,w] = cem_det(hsi_data,tgt_sigs)

[n_band,n_pix] = size(hsi_data);
n_sigs = size(tgt_sigs,2);

%R = zeros(n_band,n_band);
% for i=1:n_pix
%    R = R + hsi_data(:,i)*hsi_data(:,i)'; 
% end
% R = R/n_pix;

%R = 1/n_pix* hsi_data*hsi_data';
R = cov(hsi_data');
mu = mean(hsi_data,2);
z = hsi_data - repmat(mu,[1,n_pix]);

Rinv = pinv(R);

%M = tgt_sigs;
M = tgt_sigs - repmat(mu,[1,n_sigs]);

w = Rinv*M * pinv(M'*Rinv*M) * ones(n_sigs,1);

%cem_data = w'*hsi_data;
cem_data = w'*z;

end


