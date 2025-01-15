# Surface Generation for Amira 5.6, 6.0.1, and 6.2.0
# L. Schuring, 10/2024
# Updates:
# - S. Kussow, 12/4/2024: removed 1 slice enlargement after crop, revised STL file path

# ESTABLISH USER VARIABLES

# Scan Surface To Volume
create HxScanConvertSurface "Scan Surface To Volume"
"Scan Surface To Volume" setVar "CustomHelp" {HxScanConvertSurface}
"Scan Surface To Volume" data connect "$surfFile"
"Scan Surface To Volume" field connect "$Dataset"
"Scan Surface To Volume" fire
[ {Scan Surface To Volume} create result ] setLabel "$surfFile.scanConverted"

# CONVERT IMAGE TYPE TO 8-BIT UNSIGNED
	# "CastField1" outputType setIndex 0 0 is the command for 8-bit unsigned.  If the order of the list ever changes, where 8-bit unsigned is 3rd on the drop-down menu (index=2_ , then the command would be: "CastField1" outputType setIndex 0 0
create HxCastField "CastField1"
"CastField1" setVar "CustomHelp" {HxCastField}
"CastField1" data connect "$Dataset" 
"CastField1" outputType setIndex 0 0
"CastField1" scaling setValue 0 0.0625
"CastField1" scaling setValue 1 1024
"CastField1" voxelGridOptions setValue 0 1
"CastField1" fire
[ {CastField1} create result ] setLabel "dicom_1x.to-byte"

# ARITHMETIC
create HxArithmetic "Arithmetic"
"Arithmetic" setVar "CustomHelp" {HxArithmetic}
"Arithmetic" inputA connect "dicom_1x.to-byte"
"Arithmetic" inputB connect "$surfFile.scanConverted"
"Arithmetic" inputC disconnect
"Arithmetic" fire
"Arithmetic" resultChannels setIndex 0 0
"Arithmetic" expr0 setState {A*(B>0)}
"Arithmetic" resultType setValue 1
"Arithmetic" resultLocation setValue 0
# get resolution from DICOM image stack
set dicomDims ["$Dataset" getDims]
"Arithmetic" resolution setValue 0 [lindex $dicomDims 0]
"Arithmetic" resolution setValue 1 [lindex $dicomDims 1]
"Arithmetic" resolution setValue 2 [lindex $dicomDims 2]
"Arithmetic" fire
[ {Arithmetic} create result ] setLabel "Result"

# AUTO-CROPPING cropping with threshold set to 1 (anything smaller than 1 will be outside of crop bounds), ie cropping to last slice WITH data
set "cropBounds" ["Result" crop -auto 1]

# Attach bounding box so that it's easier to get bounding box values to write to file
create HxBoundingBox "BoundingBox"
"BoundingBox" data connect "Result"
"BoundingBox" select
set lowerBound ["BoundingBox" LowerLeft getValue]
set upperBound ["BoundingBox" UpperRight getValue]
"Result" select
set voxelSize ["Result" Voxelsize getValue]

# Conver to 16-bit
create HxCastField "CastField2"
"CastField2" setVar "CustomHelp" {HxCastField}
"CastField2" data connect "Result" 
"CastField2" outputType setIndex 0 2
"CastField2" scaling setValue 0 1
"CastField2" scaling setValue 1 0
"CastField2" fire
[ {CastField2} create result ] setLabel "finalDRR"

# If output directory given, export surface as stl file, save in script directory
if {[info exist outputDir] & [llength $outputDir]> 0} {
	file mkdir "$outputDir/for_mtwtesla/"
	set outputFileName [file rootname [file tail $surfFile]]
	"finalDRR" exportData "3D Tiff" "$outputDir/for_mtwtesla/$outputFileName.tiff"
	
	# Save cropping info to txt file
	set fileId [open "$outputDir/for_mtwtesla/$outputFileName.txt" "w"]
	puts $fileId " Cropping Bounds (xmin,xmax,ymin,ymax,zmin,zmax): $cropBounds \n Bounding Box (xmin,ymin,zmin,xmax,ymax,zmax): $lowerBound $upperBound \n Voxel size (x,y,z): $voxelSize"
	close $fileId
}
