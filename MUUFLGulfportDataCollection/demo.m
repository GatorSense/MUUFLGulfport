
USE_IMAGE_SPECTRA = false;

% setup paths
addpath('util');
addpath('Bullwinkle');
addpath('signature_detectors');

% load one of the campus images
load muufl_gulfport_campus_w_lidar_1;

if USE_IMAGE_SPECTRA

    % load the target signatures
    load tgt_img_spectra; % order: brown, dark green, faux vineyard green, pea green
    
    % setup some target filters for scoring (see Bullwinkle/BullwinkleParameters.m for more info)
    filt_pg_3 = { {'pea green',3,[],[]} };
    filt_all = { {{'brown','pea green','dark green','faux vineyard green'},[],[],[]} };
    
    target_sigs = tgt_img_spectra.spectra;
else    
    % load lab spectra, resample to image bands
    load tgt_lab_spectra;
    lab_tgt_inds = [4 2 3 5]; %br,dg,vg,pg
    
    img_wvl = hsi.info.wavelength;
    n_band = numel(img_wvl);
    
    lab_wvl = spectralSignatures(1).wavelengths;
    img_lab_inds = zeros(n_band,1);
    for i=1:numel(img_wvl)
        [~,img_lab_inds(i)] = min(abs(lab_wvl - img_wvl(i)));
    end
    
    target_sigs = zeros(n_band,numel(lab_tgt_inds));
    for i=1:numel(lab_tgt_inds)
        target_sigs(:,i) = spectralSignatures(lab_tgt_inds(i)).reflectance(img_lab_inds);
    end
    
    filt_pg_3 = { {'pea green',3,[],[]} };
    filt_all = { {{'brown','pea green','dark green','vineyard green'},[],[],[]} };
      % note this uses vineyard green instead of faux vineyard green      
end

% pull out the hyperspectral image data, ensure it is double precision
hsi_img = double(hsi.Data);

%----------------------------------------------------------------
% run some detectors on just pea green targets
ace_out_pg = ace_detector(hsi_img,target_sigs(:,4),hsi.valid_mask);
smf_out_pg = smf_detector(hsi_img,target_sigs(:,4),hsi.valid_mask);

% score the detectors
ace_score = score_hylid_perpixel(hsi,ace_out_pg,filt_pg_3,'ACE','det_fig',10,'roc_fig',11);
smf_score = score_hylid_perpixel(hsi,smf_out_pg,filt_pg_3,'SMF','det_fig',15,'clims',[0 10],'roc_fig',16);

%----------------------------------------------------------------

%----------------------------------------------------------------
% run some detectors on all of the targets
out{1} = ace_ss_detector(hsi_img,target_sigs,hsi.valid_mask);
out{2} = smf_max_detector(hsi_img,target_sigs,hsi.valid_mask);

score{1} = score_hylid_perpixel(hsi,out{1},filt_all,'ACE','det_fig',100);
score{2} = score_hylid_perpixel(hsi,out{2},filt_all,'SMF','det_fig',101,'clims',[0 10]);

figure(103);
PlotBullwinkleRoc(score,'detectors','xlim',[-1e-5 1e-3]);

figure(104);
PlotBullwinkleRoc(score,'detectors','scale','log');

%----------------------------------------------------------------
