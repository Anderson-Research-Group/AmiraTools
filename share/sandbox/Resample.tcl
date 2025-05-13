# Amira Script 
# Surface Generation for Amira 5.6, 6.0.1, and 6.2.0
# L. Schuring, 10/2024

# ESTABLISH USER VARIABLES
set mainDir "C:/Users/Ontario/Box/Grace's Project/Grace's Data"
set csvFile "$mainDir/voxel_sizes.csv"
set inputDir "$mainDir/tiff_output"
set importList [glob -directory $inputDir -tails *.tif]
set importList "159165_10f.tif"
file mkdir "$mainDir/Resampled"
echo $importList

# Open the CSV file
set fp [open $csvFile r]

# For loop to open each file and export as different file type
foreach fileName $importList {
	# Load File
	#set hideNewModules 1
	[load -tif +box 0 511 0 511 0 1 +mode 100 $inputDir/$fileName] setLabel $fileName
	
	# Loop through each line of the file
	while {[gets $fp line] >= 0} {
		# You can either search the whole line...
		if {[string match "*$fileName*" $line]} {
		}
		}
		
		# Split the line into fields
        set fields [split $line ","]
        
        # Assign values from fields (assuming consistent format)
	set xscale [lindex $fields 1]
	set yscale [lindex $fields 2]
	set zscale [lindex $fields 3]
	$fileName setTransform $xscale 0 0 0 0 $yscale 0 0 0 0 $zscale 0 0 0 0 1
	$fileName applyTransform
	#remove $fileName
}
close $fp