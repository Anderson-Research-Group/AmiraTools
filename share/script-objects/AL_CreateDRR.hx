# Surface Generation for Amira 5.6, 6.0.1, and 6.2.0
# L. Schuring, 10/2024
# Required Variables for script to run. These variables are defined in the AL_SurfGen.scro compute procedure:
	# AMIRA_LOCAL
	# surfFile (can be surf or segmentation file)
	# imageStack
	# outputDir 
	
# Ensure that image stack transform is set to identity matrix prior to running
$imageStack setTransform identity

if { [$surfFile getTypeId] eq "HxSurface"} {
	# Scan Surface To Volume
	set AL_ss2v [create HxScanConvertSurface "Scan Surface To Volume"]
	$AL_ss2v setVar "CustomHelp" {HxScanConvertSurface}
	$AL_ss2v data connect "$surfFile"
	$AL_ss2v field connect "$imageStack"
	$AL_ss2v fire
	set labelFile [ $AL_ss2v create result ] 
} else {
	# This assumes the label file is the same size as the imageStack
	# May want to add error if provided file is not the same size as imageStack
	set labelFile $surfFile
}


# CONVERT IMAGE TYPE TO 8-BIT UNSIGNED
	# "CastField1" outputType setIndex 0 0 is the command for 8-bit unsigned.  If the order of the list ever changes, where 8-bit unsigned is 3rd on the drop-down menu (index=2_ , then the command would be: "CastField1" outputType setIndex 0 0
set AL_castfield [create HxCastField "CastField1"]
$AL_castfield setVar "CustomHelp" {HxCastField}
$AL_castfield data connect "$imageStack" 
$AL_castfield outputType setIndex 0 0
$AL_castfield scaling setValue 0 0.0625
$AL_castfield scaling setValue 1 1024
$AL_castfield voxelGridOptions setValue 0 1
$AL_castfield fire
set data1x_tobyte [ $AL_castfield create result ] 

# ARITHMETIC - defining what gets zeroed out from image data based on whether or not it is in or out of label 
set AL_arithmetic [create HxArithmetic "Arithmetic"]
$AL_arithmetic setVar "CustomHelp" {HxArithmetic}
$AL_arithmetic inputA connect $data1x_tobyte
$AL_arithmetic inputB connect $labelFile
$AL_arithmetic inputC disconnect
$AL_arithmetic fire
$AL_arithmetic resultChannels setIndex 0 0
$AL_arithmetic expr0 setState {A*(B>0)}
$AL_arithmetic resultType setValue 1
$AL_arithmetic resultLocation setValue 0

# get resolution from DICOM image stack
set dicomDims ["$imageStack" getDims]
$AL_arithmetic resolution setValue 0 [lindex $dicomDims 0]
$AL_arithmetic resolution setValue 1 [lindex $dicomDims 1]
$AL_arithmetic resolution setValue 2 [lindex $dicomDims 2]
$AL_arithmetic fire
set AL_arithmeticResult [$AL_arithmetic create result ]

# AUTO-CROPPING cropping with threshold set to 1 (anything smaller than 1 will be outside of crop bounds), ie cropping to last slice WITH data
set "cropBounds" [$AL_arithmeticResult crop -auto 1]

# Attach bounding box so that it's easier to get bounding box values to write to file
set AL_boundingbox [create HxBoundingBox "BoundingBox"]
$AL_boundingbox data connect $AL_arithmeticResult
$AL_boundingbox select
set lowerBound [$AL_boundingbox LowerLeft getValue]
set upperBound [$AL_boundingbox UpperRight getValue]
$AL_arithmeticResult select
set voxelSize [$AL_arithmeticResult Voxelsize getValue]

# Conver to 16-bit
set AL_castfield2 [create HxCastField "CastField2"]
$AL_castfield2 setVar "CustomHelp" {HxCastField}
$AL_castfield2 data connect $AL_arithmeticResult 
$AL_castfield2 outputType setIndex 0 2
$AL_castfield2 scaling setValue 0 1
$AL_castfield2 scaling setValue 1 0
$AL_castfield2 fire
set DRRname "[file rootname [file tail $surfFile]]_DRR"
[$AL_castfield2 create result ] setLabel "$DRRname"
"$DRRname" showIcon

# If output directory given, export surface as stl file, save in script directory
if {[info exist outputDir] & [llength $outputDir]> 0} {
	# create an output file name based on surfFile 
	set outputFileName [file rootname [file tail $surfFile]]
	
	#create directory to save output files 'for_mtwtesla'
	file mkdir "$outputDir/for_mtwtesla/"

	# export tiff file and txt file with cropping info
	"$DRRname" exportData "3D Tiff" "$outputDir/for_mtwtesla/$outputFileName.tiff"
	set fileId [open "$outputDir/for_mtwtesla/$outputFileName.txt" "w"]
	puts $fileId " Cropping Bounds (xmin,xmax,ymin,ymax,zmin,zmax): $cropBounds \n Bounding Box (xmin,ymin,zmin,xmax,ymax,zmax): $lowerBound $upperBound \n Voxel size (x,y,z): $voxelSize"
	close $fileId
}
