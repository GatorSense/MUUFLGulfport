function [rocky_out,blobber_out,detector_out] = score_hylid(hylid_struct,detector_img,blob_thresh,targ_filt,title_str,blob_figh,roc_figh)

if ~exist('blob_figh','var')
    blob_figh = figure();
end
if ~exist('roc_figh','var')
    roc_figh = figure();
end

detector_out = hylid_struct;
detector_out.Data = detector_img;
detector_out.info.description = {detector_out.info.description, title_str};

% run the blobber
blobber_params = BlobberParameters();
blobber_params.savePrevious = false;
blobber_params.saveResult = false;
blobber_params.writeELE = false;

%blobber_params.Threshold = 0.4;
blobber_params.Threshold = blob_thresh;
blobber_params.SERadius = 0;

blobber_out = Blobber(detector_out,blobber_params);

figure(blob_figh);
clf;
s1 = subplot(1,2,1);
PlotBlobber(blobber_out,targ_filt);
title({title_str,sprintf('(threshold: %.3f)',blob_thresh)});
s2 = subplot(1,2,2);
imagesc(detector_img);
colorbar;
plot_hylid_gt(detector_out.groundTruth,targ_filt);
linkaxes([s1 s2],'xy');

% run the roc'er
rocky_params = CreateROCKYParameters();
rocky_params.savePrevious = false;
rocky_params.saveResult = false;

rocky_params.Halo = 2;
rocky_params.targetFilter = targ_filt;

rocky_out = CreateROCKY(blobber_out,rocky_params);

% plot the ROC
figure(roc_figh);
clf;
PlotROCKY(rocky_out,title_str);

end