function [out,varargout] = rx_det(det_fun,hsi_img,tgt_sigs,mask,guard_win,bg_win,varargin)
%
%function [out,varargout] = rx_det(det_fun,hsi_img,tgt_sigs,mask,guard_win,bg_win,varargin)
%
% wrapper to make an RX style sliding window detector given the local detection function
%
% inputs:
%  det_fun - detection function
%  hsi_image - n_row x n_col x n_band hyperspectral image
%  tgt_sigs - target signature (n_band x 1 - column vector)
%  mask - binary image limiting detector operation to pixels where mask is true
%         if not present or empty, no mask restrictions are used
%  guard_win - guard window radius (square,symmetric about pixel of interest) 
%  bg_win - background window radius
%
% outputs:
%  out - detector image
%
% 1/27/2013 - Taylor C. Glenn - tcg@cise.ufl.edu
%

[n_row,n_col,n_band] = size(hsi_img);
n_pix = n_row*n_col;

if ~exist('mask','var') || isempty(mask), mask = true(n_row,n_col); end
if ~exist('bg_win','var'), bg_win = 4; end
if ~exist('guard_win','var'), guard_win = 2; end

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


args = struct();
args.hsi_data = hsi_data;
args.global_mu = global_mu;
args.global_siginv = global_siginv;
args.tgt_sigs = tgt_sigs;
args.n_sig = size(tgt_sigs,2);

n_out = nargout(det_fun);

% run the detector
%  (only on fully valid points)
ind_img = reshape(1:n_pix,n_row,n_col);
out = nan(n_row,n_col);

if n_out > 1
    varargout = cell(1,n_out-1);
    argout = cell(1,n_out-1);
    for i=1:n_out-1
       varargout{i} = nan(n_row,n_col); 
    end
end

for i=1:n_col-mask_width+1
    for j=1:n_row-mask_width+1

        row = j+half_width;
        col = i+half_width;
        
        if ~mask(row,col), continue; end            
        
        b_mask_img = false(n_row, n_col);
        b_mask_img(mask_rg+j, mask_rg+i) = b_mask;
        b_mask_img = and(b_mask_img,mask);  % remove pixels not in the valid pixel mask
        b_mask_list = b_mask_img(:);
        
        %pull out background and foreground points        
        bg = hsi_data(:,b_mask_list);
        ind = ind_img(row,col);
        x = hsi_data(:,ind);
        
        %compute detection statistic
        if n_out == 1
            out(row,col) = det_fun(x,ind,bg,b_mask_list,args,varargin{:});
        else
           [out(row,col),argout{:}] = det_fun(x,ind,bg,b_mask_list,args,varargin{:});
           for a=1:n_out-1
              varargout{a}(row,col) = argout{a}; 
           end
        end
    end
end


end
 




