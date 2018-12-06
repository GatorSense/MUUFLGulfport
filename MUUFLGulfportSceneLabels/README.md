# MUUFL Gulfport Scene Labels:
_Xiaoxiao Du and Alina Zare_

In this folder, we provide the technical report and MATLAB data file `(.mat)` for the MUUFL Gulfport dataset scene annotations.

![alt text](https://github.com/GatorSense/MUUFLGulfport/blob/master/MUUFLGulfportSceneLabels/muufl_scene_labels_screenshot.png "MUUFL Gulfport Scene Labels")

## Technical Report
` X. Du and A. Zare, “Technical Report: Scene Label Ground Truth Map for MUUFL Gulfport Data Set,” University of Florida, Gainesville, FL, Tech. Rep. 20170417, Apr. 2017. Available: http://ufdc.ufl.edu/IR00009711/00001.`
[[`PDF`](http://ufdc.ufl.edu/IR00009711/00001)] 
[[`BibTeX`](#CitingMUUFLSceneLabels)]

This technical report describes the groundtruth scene annotation process and provides detailed information regarding each material type in the scene.

## MATLAB data file

The `muufl_gulfport_campus_1_hsi_220_label.mat` file contains the ground truth information about the emplaced targets as well as the materials in the scene. Here is an overview of all the fields in the data structure:
```
muufl_gulfport_campus_1_hsi_220_label.mat

└── hsi
    ├── info  
        ├── description //description of the data collection
        ├── samples // ==220, equals to number of columns in the data
        ├── lines   // ==325, equals to number of rows in the data
        ├── bands   //==64, number of spectral bands in the data
        ├── sensor_type //=='HSI' for hyperspectral imaging
        ├── map_info 
            ├── projection //=='UTM'
            ├── dx  //=='1', 1 meter ground sample distance in x direction
            ├── dy  //=='1', 1 meter ground sample distance in y direction
            ├── zone //==16, UTM zone
            ├── hemi //=='North', north hemisphere
            ├── datum //=='WGS-84'
            ├── units //=='Meters'
        ├── wavelength_units //=='Nanometers'
        ├── wavelength   //wavelength information for each band
        ├── original_file_name   //file name for original data collection
        └──remove_band_index //remove first four and last four bands due to noise
    ├── Data  //HSI data cube: 325x220x64
    ├── Northing
    ├── Easting
    ├── Lat
    ├── Lon
    ├── Lidar // LiDAR from two returns, rasterized
        ├── x
        ├── y
        ├── z 
        └──info
    ├── sceneLabels     //scene annotations
        ├── Materials_Type  //11 materials in the scene 
        ├── Materials_rowIndices   // row indices of each material 
        ├── Materials_colIndices   // column indices of each material 
        ├── Materials_Indices     // RGB image indices of each material 
        ├── subLabels_description   //each cell contains material types of sub-labels for each class
        ├── subLabels_labels    // sub-labels for each class. Note that this label correspond to the ordering in 'subLabels_description'.
        └── labels //overall labels for all 12 classes (labels -1 'un-labeled' plus 11 materials) of materials in the scene
    ├── groundTruth  //ground truth information of targets in the scene
        ├── Targets_UTMx  //UTM Easting for all targets
        ├── Targets_UTMy  //UTM Northing for all targets
        ├── Targets_Lat   //Latitude (Degrees) for all targets
        ├── Targets_Lon   //Longitude (Degrees) for all targets
        ├── Targets_ID    //numerical identifier for the target
        ├── Targets_Size  //size of all targets. one of {0.5, 1, 3, 6} indicating target size. The 0.5, 1, and 3, are square targets of that dimension (ie 3m by 3m), the size 6 are the large 6m by 10m calibration cloths in the center of the campus
        ├── Targets_Type  //cloth color, one of {faux vineyard green, pea green, dark green, brown, vineyard green} for the regular targets, or one of {red,black,blue,green} for the large calibration cloths
        ├── Targets_Elevated  //one of {0,1} indicating if the target was on an elevated platform
        ├── Targets_HumanCat  //one of {0,1,2} indicating occlusion category. 0 unoccluded, 1 part or fully in shadow but no tree occlusion, 2 part or full occlusion by tree
        ├── Targets_HumanConf  //one of {1,2,3,4} indicating target visibility. That is, whether the human truthers felt they could identify the target in the data. Scale of: 1 visible, 2 probably visible, 3 possibly visible, 4 not visible
        ├── Targets_rowIndices  //target row indices (as in the RGB imagery)
        ├── Targets_colIndices  //target column indices (as in the RGB imagery)
        └── id   //version and contact
    └── RGB    //RGB imagery, 325x220x3
```


## <a name="CitingMUUFLSceneLabels"></a>Citing MUUFL Gulfport Scene Labels

If you use the MUUFL Gulfport scene labels in your work, please cite the following references using the following BibTeX entries.
```
@TechReport{gader2013muufl,
  author =      {P. Gader and A. Zare and R. Close and J. Aitken and G. Tuell},
  title =       {MUUFL Gulfport Hyperspectral and LiDAR Airborne Data Set},
  institution = {University of Florida},
  year =        {2013},
  number =      {Rep. REP-2013-570},
  address =     {Gainesville, FL},
  month =       {Oct.}
}

@TECHREPORT{du2017technical,
  title={Technical report: scene label ground truth map for MUUFL Gulfport Data Set},
  author={Du, X and Zare, A},
  institution={University of Florida}, 
  address={Gainesville, FL.},
  year={2017},
  number ={Tech. Rep. 20170417},
  month = {April}
  url ={http://ufdc.ufl.edu/IR00009711/00001}
}
```
