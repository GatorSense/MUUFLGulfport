function ndvi_img = ndvi_hsi(hsi)
%function ndvi_img = ndvi_hsi(hsi)
%
% compute the Normalized Difference Vegetation Index
%  from the hyperspectral image
%
%
% 10/31/2012 - Taylor C. Glenn - tcg@cise.ufl.edu

% NDVI = NIR-VIS / (NIR+VIS)

%fixme: I am pulling these wavelengths out of thin air
%  to roughly be something red and something NIR

vis_wvl = 640:660; 
nir_wvl = 900:920;

wvl = hsi.info.wavelength;

vis_bands = find(wvl >= vis_wvl(1),1,'first'):find(wvl <= vis_wvl(end),1,'last');
nir_bands = find(wvl >= nir_wvl(1),1,'first'):find(wvl <= nir_wvl(end),1,'last');

[n_row,n_col,n_band] = size(hsi.Data);
n_pix = n_row*n_col;

hsi_data = reshape(hsi.Data,[n_pix,n_band]);

vis = mean(hsi_data(:,vis_bands),2);
nir = mean(hsi_data(:,nir_bands),2);

ndvi = (nir-vis)./(nir+vis);

ndvi_img = reshape(ndvi,[n_row,n_col]);


end