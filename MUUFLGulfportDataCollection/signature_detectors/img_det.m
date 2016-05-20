function [det_out,varargout] = img_det(detector_fn,hsi_img,tgt_sig,mask,varargin)
%
%function [det_out,varargout] = img_det(detector_fn,hsi_img,tgt_sig,mask,varargin)
%
% wrapper to use array based detector as a image based detector with the given mask
%
% Taylor C. Glenn - tcg@cise.ufl.edu

if ~exist('mask','var'); mask = []; end

[n_row,n_col,n_band] = size(hsi_img);
n_pix = n_row*n_col;

if isempty(mask)
    mask = true(n_row,n_col);
end

hsi_data = double(reshape(hsi_img,[n_pix,n_band])');

% check for image like inputs, linearize them
% check for linearized n x n_pixel arguments, mask them

argin = varargin;
for i=1:numel(argin)
    arg = argin{i};
    if isnumeric(arg)
        sz = size(arg);
        if numel(sz) == 2 && all(sz == [n_row,n_col])
            arg = reshape(arg,1,n_pix);
            arg = arg(mask(:));
            argin{i} = arg;
            
        elseif numel(sz) == 2 && sz(2) == n_pix
            argin{i} = arg(:,mask(:));
            
        elseif numel(sz) == 3 && sz(1) == n_row && sz(2) == n_col
            arg = reshape(arg,n_pix,sz(3))';
            arg = arg(:,mask(:));
            argin{i} = arg;            
        end
    end    
            
end

det_data = NaN(1,n_pix);

n_out = nargout(detector_fn);
if n_out > 1
    argout = cell(1,n_out-1);
    varargout = cell(1,n_out-1);
    
    [det_data(mask(:)),argout{:}] = detector_fn(hsi_data(:,mask(:)),tgt_sig,argin{:});
        
    for i=1:numel(argout)
        %check for linearized-image like outputs, reshape them into images
        if isvector(argout{i}) && numel(argout{i}) == sum(mask(:))
            out = NaN(1,n_pix);
            out(mask(:)) = argout{i};
            varargout{i} = reshape(out,[n_row,n_col]);
        else
            varargout{i} = argout{i};
        end
    end
    
else
    det_data(mask(:)) = detector_fn(hsi_data(:,mask(:)),tgt_sig,argin{:});
end

det_out = reshape(det_data,[n_row,n_col]);

end