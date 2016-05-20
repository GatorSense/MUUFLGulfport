function dvh = detector_vs_human_confs(hsi,det_out,filt,halo)
%function dvh = detector_vs_human_confs(hsi,det_out,filt,halo)
% 
% Gets detector confidence for each target, put it in a matrix vs human conf and human cat
%  for easy comparison
%
% outputs:
%  dvh - n_targets x 3, [detector_output | human_conf | human_cat]
%
%
% 10/29/2012 - Taylor C. Glenn - tcg@cise.ufl.edu


[dvt,~] = detector_vs_truth(hsi,det_out,filt,halo);

dvh = dvt(:,[1 5 6]);

end