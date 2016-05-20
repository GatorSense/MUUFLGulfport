function hsi_nr = remove_hylid_noise_bands(hsi)

hsi_nr = hsi;

[nb,nb_inds] = hylid_noise_bands();

hsi_nr.info.wavelength = hsi.info.wavelength(~nb_inds);
hsi_nr.Data = hsi.Data(:,:,~nb_inds);


end