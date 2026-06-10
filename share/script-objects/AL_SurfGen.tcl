# Amira Script 
# Surface Generation for Amira 5.6, 6.0.1, and 6.2.0
# L. Schuring, 1/2025
# Required Variables for script to run. These variables are defined in the AL_SurfGen.scro compute procedure:
	# AMIRA_LOCAL
	# desiredFaceN 
	# faceDensity
	# labelFile
	# outputDir 
	
# PROCEDURES #####################################################################
proc create_initialSurf {labelFile} {
	# GENERATE initial surface "AL_SurfGen_Surface0"
	[create HxGMC "Generate Surface"] setLabel "Generate Surface"
	"Generate Surface" setVar "CustomHelp" {HxGMC}
	"Generate Surface" data connect $labelFile
	"Generate Surface" fire
	"Generate Surface" smoothing setIndex 0 2
	"Generate Surface" smoothingExtent setValue 5
	"Generate Surface" applyTransformToResult 1
	"Generate Surface" fire
	"Generate Surface" setPickable 1
	["Generate Surface" create] setLabel "AL_SurfGen_Surf0"
	return "AL_SurfGen_Surf0"
}

proc set_method {desiredFaceN desiredAreaPerFace surface} {
	if {$desiredFaceN > 0} {
		set method 1
	} else {
		set method 0
		set desiredFaceN [expr ["$surface" getArea] / $desiredAreaPerFace ]
	}
	return method
}


proc get_faceN {surface} {	
	# get number of faces from given surface
	$surface select
	set output ["$surface" Surface getValue]
	regexp {(\d+) faces} $output match faceN
	return $faceN
}

proc get_areaPerFace {surface} {	
	# get number of faces from given surface
	set faceN [get_faceN $surface]
	set surfaceArea [$surface getArea]
	return [expr $surfaceArea / $faceN]
}

proc decimate_surf {surfaceName faceN} {
	echo "DECIMATING SURFACE TO faceN = $faceN"
	# reduce face count of surface to match faceN
	$surfaceName setEditor [create HxSimplifier "Simplifier"]
	$surfaceName simplifyParameters setValue $faceN
	$surfaceName simplifyAction setValue 0
	$surfaceName simplifyAction send
	return $surfaceName
}

proc smooth_surf {surfaceName smoothName iterations lambda} { 
	# Smooth surface with given iterations and lambda variables
	create HxSurfaceSmooth $smoothName
	$smoothName data connect $surfaceName
	$smoothName fire
	$smoothName parameters setValue 0 $iterations
	$smoothName parameters setValue 1 $lambda
	$smoothName fire
	return $smoothName
}

proc apply_smooth_surf {smoothName newSurfaceName } { 
	$smoothName action hit
	$smoothName fire
	[$smoothName getResult] setLabel $newSurfaceName
	return $newSurfaceName
}

proc remesh {surface} {
	create HxRemeshSurface "Remesh Surface"
	"Remesh Surface" data connect "$surface"
	"Remesh Surface" objective setValue 1
	"Remesh Surface" desiredSize setValue 2 100
	"Remesh Surface" fire
	"Remesh Surface" contourOptions setValue 0 1
	"Remesh Surface" contourOptions setValue 0 0
	"Remesh Surface" densityContrast setValue 0.5
	["Remesh Surface" create; "Remesh Surface" getResult] setLabel "$surface.remeshed"
	
	return "$surface.remeshed"
}

proc saveSurface {outputDir surface} {	
	"$surface" exportData "STL ascii" "$outputDir/$surface"
	echo "Saved surface file in the following location: $outputDir/$surface"
}
 	
# SCRIPT #########################################################################

# CREATE INITIAL SURF and get face count
create_initialSurf $labelFile
set faceN [get_faceN "AL_SurfGen_Surf0"]

# SET METHOD for surface generation. Method 0: area per face (default), Method 1: face count
set_method $desiredFaceN $desiredAreaPerFace "AL_SurfGen_Surf0"

# ITERATIVE SIMPLIFICATION AND SMOOTHING OF SURFACE via while loop
set iters 0; # iters: initial iteration of while loop.  
set maxIters 10; # maxIters: Ensures the while loop doesn't go to infinity, must stop at maxIters value

while {$faceN > $desiredFaceN*2 & $iters < $maxIters} {

	# definging naming convention of intermediate surfaces and smoothing modules
	set surfaceName "AL_SurfGen_Surf$iters"
	set smoothName "AL_SurfGen_Smooth$iters"
	
	decimate_surf $surfaceName [expr $faceN / 2]
	smooth_surf $surfaceName $smoothName 20 0.6
	
	# Define new surface name that will result from smoothing action. 
	set iters [expr {$iters + 1}]
	set surfaceName "AL_SurfGen_Surf$iters"
	apply_smooth_surf $smoothName $surfaceName
		
	# update faceN for new iteration in while loop
	set faceN [expr {$faceN / 2}]	
}

if {$method == 0} {
	# recalculate the desired face count based on the most up-to-date surface area estimate
	set desiredFaceN [expr [$surfaceName getArea] / $desiredAreaPerFace ]
}

# FINAL DECIMATION AND SMOOTHING
set finalSurfName [file rootname [file tail $labelFile]]
decimate_surf $surfaceName $desiredFaceN
smooth_surf $surfaceName "finalSmooth" 10 0.6
apply_smooth_surf "finalSmooth" "$finalSurfName.temp"
[remesh "$finalSurfName.temp"] setLabel "$finalSurfName.stl"
"$finalSurfName.stl" showIcon

echo "FINAL SURFACE FACE COUNT: [get_faceN "$finalSurfName.stl"]"
echo "FINAL SURFACE AREA PER FACE: [get_areaPerFace "$finalSurfName.stl"]"

# SAVE SURFACE FILE: If output directory given, export surface as stl file, save in script directory
if {[info exist outputDir] & [llength $outputDir]> 0} {
	saveSurface $outputDir "$finalSurfName.stl"
}