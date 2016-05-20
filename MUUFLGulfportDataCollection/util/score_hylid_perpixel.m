function [bw_out] = score_hylid_perpixel(hylid_struct,detector_img,targ_filt,title_str,varargin)
%
%function [bw_out] = score_hylid_perpixel(hylid_struct,detector_img,targ_filt,title_str,varargin)
%
%  scores the detection performance of the given detector output image using Bullwinkle
%  optionally plots an annotated detector image and roc curve
%
% 8/2012 - Taylor Glenn - tcg@cise.ufl.edu
%

p = inputParser();
p.addParamValue('det_fig',[],@(x)isnumeric(x));
p.addParamValue('roc_fig',[],@(x)isnumeric(x));
p.addParamValue('bw_params',[],@(x)isstruct(x));
p.addParamValue('clims',[],@(x)isnumeric(x)&&numel(x)==2);
p.parse(varargin{:});
args = p.Results;

if isempty(args.bw_params)
    bw_params = BullwinkleParameters();
    bw_params.Halo = 2;
else
    bw_params = args.bw_params;
end
    

detector_out = hylid_struct;
detector_out.Data = detector_img;
detector_out.info.description = {detector_out.info.description, title_str};
detector_out.name = title_str;

if ~isempty(args.det_fig)
    figure(args.det_fig);
    clf;
    if ~isempty(args.clims)
        imagesc(detector_img,args.clims);
    else
        imagesc(detector_img);
    end
    colorbar;
    plot_hylid_gt(detector_out.groundTruth,targ_filt);
    title(title_str);
end

% run the perpixel scoring
bw_params.targetFilter = targ_filt;

bw_out = Bullwinkle(detector_out,bw_params);

% plot the ROC
if ~isempty(args.roc_fig)
    figure(args.roc_fig);
    clf;
    PlotBullwinkleRoc(bw_out,title_str);
end

end