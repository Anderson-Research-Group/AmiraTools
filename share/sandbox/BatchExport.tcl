# Amira Script 
# Surface Generation for Amira 5.6, 6.0.1, and 6.2.0
# L. Schuring, 10/2024

# ESTABLISH USER VARIABLES
remove -all
# EDIT BELOW LINE: to reflect the file type you'd like to import

set importList [glob -directory $SCRIPTDIR -tails *.ply]
file mkdir "$SCRIPTDIR/Export/"
echo $importList

# Set units if not already set
if {[_units isUnitsManagementActivated] == 1} {
    _units setDisplayCoordinatesUnit mm
    _units setWorkingCoordinatesUnit mm}

# For loop to open each file and export as different file type
foreach fileName $importList {
	# Load File
	set hideNewModules 1
	[load -unit mm $SCRIPTDIR/$fileName] setLabel $fileName
	
	# EDIT BELOW LINE: to reflect the file type you'd like your export to be in
	$fileName exportData "STL ascii" "$SCRIPTDIR/Export/$fileName.stl"
	
	remove $fileName
}