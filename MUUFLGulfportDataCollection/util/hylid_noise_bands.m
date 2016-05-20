function [nb,nb_inds] = hylid_noise_bands()

n_band = 72;
nb = 1:4;

nb_inds = false(1,n_band);
nb_inds(nb) = true;

end