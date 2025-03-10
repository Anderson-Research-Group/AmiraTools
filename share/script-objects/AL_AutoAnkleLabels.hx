# Auto Ankle Label Generation. Tested on Amira 6.0.1
# Purpose: convert Seg3D/Corview growcut export (specific to the Ankle Project) into Amira Labels 
# Assumptions: assumes Seg3D export is a tif, and Tibia = 1, Calcaneus = 2, Talus = 3
# Author: L. Schuring, 3/2025
	
# set dataTif "Subj01.tiff"	
# set dataDicom "Subj01"

# replace Tif bbox info with Dicom bbox info
set bboxDicom [$dataDicom getBoundingBox]
$dataTif setBoundingBox {*}$bboxDicom 
	#For troubleshooting: 
	#set bboxTif [$dataTif getBoundingBox]

# Create a multi-thresholding tool to auto segment Tif stack 
set labelGen [create HxLabelVoxel]
$labelGen data connect $dataTif
$labelGen regions setValue "Exterior Tibia Calcaneus Talus"
$labelGen fire
$labelGen boundary01 setValue 0
$labelGen boundary12 setValue 1
$labelGen boundary23 setValue 2
$labelGen applyTransformToResult 1
set labelTib [[$labelGen create] setLabel "$dataDicom-Tibia"]
set labelCal [[$labelTib duplicate] setLabel "$dataDicom-Calcaneus"]
set labelTal [[$labelTib duplicate] setLabel "$dataDicom-Talus"]

# remove materials from each label so only the material of interest is in the label
$labelTib removeMaterial "Calcaneus"
$labelTib removeMaterial "Talus"
$labelCal removeMaterial "Tibia"
$labelCal removeMaterial "Talus"
$labelTal removeMaterial "Calcaneus"
$labelTal removeMaterial "Tibia"

# show final label files
$labelTib showIcon
$labelCal showIcon
$labelTal showIcon

