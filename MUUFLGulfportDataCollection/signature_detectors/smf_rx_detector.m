function [out] = smf_rx_detector(hsi_img,tgt_sig,mask,guard_win,bg_win)
%
%function [out] = smf_rx_detector(hsi_img,tgt_sig,mask)
%
% Spectral Matched Filter with RX style local background estimation
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

if ~exist('bg_win','var'), bg_win = 4; end
if ~exist('guard_win','var'), guard_win = 2; end

[n_row,n_col,n_band] = size(hsi_img);
n_pix = n_row*n_col;

if ~exist('mask','var') || isempty(mask), mask = true(n_row,n_col); end


% create the mask
mask_width = 1 + 2*guard_win + 2*bg_win;
half_width = guard_win + bg_win;
mask_rg = (1:mask_width)-1;

b_mask = true(mask_width,mask_width);
b_mask(bg_win+1:end-bg_win,bg_win+1:end-bg_win) = false;

hsi_data = reshape(hsi_img,[n_pix,n_band])';

% get global image/segment statistics in case we need to fall back on them
global_mu = mean(hsi_data(:,mask(:)),2);
global_siginv = pinv(cov(hsi_data(:,mask(:))'));

% run the detector
%  (only on fully valid points)

out = nan(n_row,n_col);

for i=1:n_col-mask_width+1
    for j=1:n_row-mask_width+1

        row = j+half_width;
        col = i+half_width;
        
        if ~mask(row,col), continue; end            
        
        b_mask_img = false(n_row, n_col);
        b_mask_img(mask_rg+j, mask_rg+i) = b_mask;
        b_mask_img = and(b_mask_img,mask);  % remove pixels not in the valid pixel mask
        b_mask_list = b_mask_img(:);
        
        %pull out background points        
        bg = hsi_data(:,b_mask_list);
        
        %compute detection statistic
        if ~isempty(bg)
            siginv = pinv(cov(bg'));
            mu = mean(bg,2);
        else
            siginv = global_siginv;
            mu = global_mu;
        end
        z = squeeze(hsi_img(row,col,:)) - mu;
        s = tgt_sig - mu;
        
        f = s'*siginv / sqrt(s'*siginv*s);
        
        out(row,col) = f*z;
                
    end
end


end
 



