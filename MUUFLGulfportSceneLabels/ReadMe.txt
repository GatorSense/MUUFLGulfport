# 
This folder contains:

The MUUFL Gulfport Campus 1 ground truth scene labels

***************************************************************

***NOTE: If this data is used in any publication or presentation the following reference must be cited:

[1] P. Gader, A. Zare, R. Close, J. Aitken, G. Tuell, “MUUFL Gulfport Hyperspectral and LiDAR Airborne Data Set,” University of Florida, Gainesville, FL, Tech. Rep. REP-2013-570, Oct. 2013.

[2] X. Du and A. Zare, “Technical Report: Scene Label Ground Truth Map for MUUFL Gulfport Data Set,” University of Florida, Gainesville, FL, Tech. Rep. 20170417, Apr. 2017. Available: http://ufdc.ufl.edu/IR00009711/00001.

***************************************************************

This directory includes the MATLAB data files for the MUUFL Gulfport Campus 1 images and ground truth label maps.

————- Included files:

muufl_gulfport_campus_1_hsi_220_label.mat
matlab (structure) file containing the data set and scene label ground truth information, for campus subimage #1 (3500ft elev)

README.md
this file

MUUFL_GulfportTechReport_SceneLabelingGroundTruth.pdf
Technical Report describing the groundtruth scene labeling process and detailed information regarding each labels in the scene

————- About "muufl_gulfport_campus_1_hsi_220_label.mat"

The .mat files contain the ground truth locations and information about the emplaced targets as well as the materials in the scene. Here is an overview of the fields:

info: information regarding the MUUFL Gulfport Campus 1 data set, including elevation information, sensor type, wavelengths of the hyperspectral data, etc. 

Data: hyperspectral data set. Notice that the original MUUFL Gulfport data set campus 1 scene from [1] contains 325*337 pixels across 72 bands. Due to noise, the first four and last four bands were removed, resulting in a new hyperspectral image of 64 bands. The lower right corner of the original image contains invalid area, thus only the first 220 columns were used for the ground truth mapping. The size of the new cropped hyperspectral imagery is 325*220*64.

Northing: Northing of the data set

Easting: Easting of the data set

Lat: Latitude of the data set

Lon: Longitude of the data set

Lidar: Lidar data from two flights, from the original data collection.

groundTruth: contains ground truth information for the targets (cloth panels) placed in the scene. Details can be seen in the section below "About groundTruth".

sceneLabels: contains ground truth labeling information for all the materials in the scene. Details can be seen in the section below "About sceneLabels".

RGB: RGB image of the croppde hyperspectral campus 1 data set.

————- About groundTruth 

This section provides detailed information regarding the "groundTruth" field in the hsi structure. The "groundTruth" here refers to the (cloth) targets ground truth information.

Targets_UTMx: UTM Easting Targets_UTMy: UTM Northing Targets_Lat: Degrees Latitude Targets_Lon: Degrees Longitude Targets_ID: numerical identifier for the target (1 to 50). Notice that in the original data collection there were sixty-four targets [1] but due to cropping fifty targets remain.

Targets_Type: cloth color, one of {faux vineyard green, pea green, dark green, brown, vineyard green} for the regular targets, or one of {red,black,blue,green} for the large calibration cloths

Targets_Elevated: one of {0,1} indicating if the target was on an elevated platform

Targets_Size: one of {0.5, 1, 3, 6} indicating target size. The 0.5, 1, and 3, are square targets of that dimension (ie 3m by 3m), the size 6 are the large 6m by 10m calibration cloths in the center of the campus

Targets_HumanConf: one of {1,2,3,4} indicating target visibility. That is, whether the human truthers felt they could identify the target in the data. Scale of: 1 visible, 2 probably visible, 3 possibly visible, 4 not visible

Targets_HumanCat: one of {0,1,2} indicating occlusion category. 0 unoccluded, 1 part or fully in shadow but no tree occlusion, 2 part or full occlusion by tree

id: string indicating revision number, date, and author of the truth file

————- About sceneLabels

This section provides detailed information regarding the "sceneLabels" field in the hsi structure.  The "sceneLabels" are the ground truth for every pixel in the scene.

Materials_Type: The material types (classes for labeling), including trees, mostly-grass ground surface, mixed ground surface, dirt and sand, road, water, buildings, shadow of buildings, sidewalk, yellow curb, cloth panels (targets). All the pixels in the data set were labeled either into one of the eleven classes, or remained as "unlabeled points". 

Materials_rowIndices: Row indices for all the pixels labeled in each material type.

Materials_colIndices: Column indices for all the pixels labeled in each material type.

Materials_Indices: Pixel indices (in the 325*220 image) for all the pixels labeled in each material type.

subLabels_description: This field provides name descriptions for sub-class labels for the following classes: buildings, mixed ground surface, dirt and sand, road, and shadows. These classes are visually identifiable to contain mixed materials and are therefore provided with more detailed sub-class labels. Materials from one sub-class usually have distinct spectral signature from another sub-class material. Each cell includes the names of such sub-class.

subLabels_labels: The field contains sub-class labels. For material types that do not have sub-class, the value is set to "1"; for material types that do have sub-class labels, all the pixels in that specific class are labeled further into labels 1,...m, -1 where m is the number of sub-classes labeled and -1 is the unlabeled sub-class points. Each sub-class label corresponds to "subLabels_description".

labels:  The 325*220 image of the high-level labels for each of the following twelve class in the scene: trees (label ``1''), mostly-grass ground surface (label ``2''), mixed ground surface (label ``3''), dirt and sand (label ``4''), road (label ``5''), water (label ``6''), buildings (label ``7''), shadow of buildings (label ``8''), sidewalk (label ``9''), yellow curb (label ``10''), cloth panels (targets) (label ``11''), and unlabeled points (label ``-1'').

***********************************************************************

 Authors: Xiaoxiao Du, Alina Zare  
 University of Missouri, Department of Electrical and Computer Engineering;
 University of Florida, Department of Electrical and Computer Engineering 

 Email Address: xdy74@mail.missouri.edu; azare@ece.ufl.edu  
 Latest Revision: March 4, 2017  

The groundtruth label file can be opened using Matlab. 


