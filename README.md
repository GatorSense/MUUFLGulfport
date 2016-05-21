This repository contains: 
* The MUUFL Gulfport Hyperspectral and LiDAR Data Collection Files  
* Geo-tagged Photographs and Ground-truth locations of this scene tagged in a GoogleEarth KML
* Bullwinkle Target Detection Scoring Code

****\\
Note:  If this data is used in any publication or presentation the following reference must be cited:
P. Gader, A. Zare, R. Close, J. Aitken, G. Tuell, “MUUFL Gulfport Hyperspectral and LiDAR Airborne Data Set,”  University of Florida, Gainesville, FL, Tech. Rep. REP-2013-570, Oct. 2013.\\

If any of this scoring or detection code is used in any publication or presentation, the following reference must be cited:
T. Glenn, A. Zare, P. Gader, D. Dranishnikov. (2016). Bullwinkle: Scoring Code for Sub-pixel Targets (Version 1.0) [Software]. Available from https://github.com/TigerSense/MUUFLGulfport/.\\
****\\

This directory includes the data files for the MUUFL Gulfport Campus images,
scoring and utility code, target detection algorithms, and a short demonstration script.\\

————-\\
Included files:\\

* Bullwinkle/                                          
  Directory containing the Bullwinkle scoring code

* signature_detectors/                                 
  Directory containing many known-target-signature detection algorithms

* util/                                               
  Directory containing utility functions including the main scoring functions

* MUUFL_TruthForSubImage.mat                          
  matlab file containing target ground truth information (only really useful if making new subimages)

* MUUFL_Gulfport_GroundTruth.csv                      
  csv with truth information from the mat file

* README.md                                           
  this file

* demo.m                                              
  demonstration code – run this!

* muufl_gulfport_campus_w_lidar_1.mat                 
  campus subimage #1 (3500ft elev), includes coregistered LiDAR DEMs, includes image registered truth info

* muufl_gulfport_campus_w_lidar_2.mat                 
  campus subimage #2 (3500ft elev), includes coregistered LiDAR DEMs, includes image registered truth info

* muufl_gulfport_campus_3.mat                         
  campus subimage #3 (3500ft elev), includes image registered truth info

* muufl_gulfport_campus_4.mat                         
  campus subimage #4 (6700ft elev), includes image registered truth info

* muufl_gulfport_campus_5.mat                         
 campus subimage #5 (6700ft elev), includes image registered truth info

* tgt_img_spectra.mat                                 
 matlab file containing hand selected target signatures for the 4 relevant target colors,selected from unoccluded target pixels of subimage #1, These spectra were manually selected from the imagery.

* tgt_lab_spectra.mat                                 
 matlab file with lab spectrometer measurements of target cloths (not including faux vineyard green)

* ASD_Spectra/                                        
 Directory containing ground-spectra measuring using an ASD spectrometer
* MUUFL_GulfportTechReport.pdf                        
 Technical Report describing data collection

* Geo-tagged Photographs and Ground-truth locations of this scene tagged in a GoogleEarth KML are in the folder /MUUFLGulfport_Photographs/. \\

————-\\
About the Bullwinkle scoring:

Bullwinkle is a blobless (mostly) per-pixel scoring routine. It has many features, but the salient points are listed here.
Due to the uncertainties in image registration and ground truth, not all target pixels can be explicitly labeled.
Bullwinkle manages this uncertainty by counting the maximum value within a halo of the truth location as the target’s confidence.
All pixels outside of the target halos are counted as individual false alarm opportunities.
Target halos extend from the edge of the target, and thus target regions for the bigger targets are larger overall.\\

————-\\
About demo.m:

This demo adds the needed directories to the Matlab path and then proceeds to demonstrate how to use some of the target detection algorithms and scoring utilities.\\

It first runs 2 detection algorithms which look only for pea green target. These outputs are then scored against only the 3m sized pea green targets. This is just done to demonstrate the target filtering steps.\\

Next multi-target versions of ACE and the Spectral Matched Filter are run to find all of the targets. ROC curves are then plotted for multiple algorithms simultaneously, and the demo shows a few options for the ROC plotter.\\

————-\\
About the ground truth:\\

The .mat and .csv files contain the ground truth locations and information about the emplaced targets.\\

Here is an overview of the fields:\\

Targets_UTMx:  UTM Easting\\
Targets_UTMy:  UTM Northing\\
Targets_Lat:   Degrees Latitude\\
Targets_Lon:   Degrees Longitude\\
Targets_ID:    numerical identifier for the target (1 to 64)\\

Targets_Type:  cloth color, one of {faux vineyard green, pea green, dark green, brown, vineyard green} for the regular targets, or one of {red,black,blue,green} for the large calibration cloths\\

Targets_Elevated:  one of {0,1} indicating if the target was on an elevated platform\\

Targets_Size:  one of {0.5, 1, 3, 6} indicating target size. The 0.5, 1, and 3, are square targets of that dimension (ie 3m by 3m), the size 6 are the large 6m by 10m calibration cloths in the center of the campus\\

Targets_HumanConf: one of {1,2,3,4} indicating target visibility. That is, whether the human truthers felt they could identify the target in the data. Scale of: 1 visible, 2 probably visible, 3 possibly visible, 4 not visible\\

Targets_HumanCat: one of {0,1,2} indicating occlusion category. 0 unoccluded, 1 part or fully in shadow but no tree occlusion, 2 part or full occlusion by tree\\

id: string indicating revision number, date, and author of the truth file\\

** Geo-tagged Photographs and Ground-truth locations of this scene tagged in a GoogleEarth KML can be downloaded here:  https://www.dropbox.com/s/v8eoay763bpn92s/MUUFLGulfport_Photographs.zip\\

————-

There are many more utility functions and detection routines included than are used in the demo. So, feel free to nose around and read the source…\\
-Taylor Glenn – tcg [at] cise.ufl.edu – 10/25/2013\\
