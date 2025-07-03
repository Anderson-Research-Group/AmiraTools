# Amira Script 
# Surface Generation for Amira 5.6, 6.0.1, and 6.2.0
# L. Schuring, 1/2025
# Required Variables for script to run. These variables are defined in the AL_SurfGen.scro compute procedure:
	# AMIRA_LOCAL
	# desiredFaceN 
	# labelFile
	# outputDir 

# final surface name derived from labelFile name
set finalSurfName [file rootname [file tail $labelFile]]
# maxIters: ensures that the decimation/smoothing while loop doesn't go to infinity. 
set maxIters 10

# GENERATE SURFACE (constrained smoothing)
[create HxGMC "Generate Surface"] setLabel "Generate Surface"
"Generate Surface" setVar "CustomHelp" {HxGMC}
"Generate Surface" data connect $labelFile
"Generate Surface" fire
"Generate Surface" smoothing setIndex 0 2
"Generate Surface" smoothingExtent setValue 5
"Generate Surface" applyTransformToResult 1
"Generate Surface" fire
"Generate Surface" setPickable 1
["Generate Surface" create] setLabel "Surface0"
Surface0 select
# GET # OF SURFACE FACES (faceN) 
set output ["Surface0" Surface getValue]
regexp {(\d+) faces} $output match faceN

# ITERATIVE SIMPLIFICATION AND SMOOTHING OF SURFACE via while loop
set faceN [expr {$faceN / 2}]
set iters 0
set sArea ["Surface0" getArea]
set sAreaTri [expr $sArea / $faceN]
echo "ORIGINAL sAreaTri $sAreaTri"
set surfaceName "Surface0"
while {$sAreaTri < 1.2 & $iters < $maxIters} {

	# definging naming convention of intermediate surfaces and smoothing modules
	set surfaceName "Surface$iters"
	set smoothName "Smooth$iters"
	
	# reduce face count be cut in half (halfed outside of while loop and at end of while loop)
	$surfaceName setEditor [create HxSimplifier "Simplifier"]
	$surfaceName simplifyParameters setValue $faceN
	$surfaceName simplifyAction setValue 0
	$surfaceName simplifyAction send
	#$surfaceName select

	# Smooth surface with iterations = 20 and lambda = 0.6
	create HxSurfaceSmooth $smoothName
	$smoothName data connect $surfaceName
	$smoothName fire
	$smoothName parameters setValue 0 20
	$smoothName parameters setValue 1 0.6
	$smoothName fire
	#$smoothName select
	
	# Define new intermediate surfname that will result from smoothing action
	set iters [expr {$iters + 1}]
	set surfaceName "Surface$iters"
	[$smoothName action hit; $smoothName fire; $smoothName getResult] setLabel $surfaceName
		
	set faceN [expr {$faceN / 2}]
	set sArea ["Surface$iters" getArea]
	set sAreaTri [expr $sArea / $faceN]
	echo "IS THIS GOING THROUGH THE WHILE LOOP $sAreaTri"
}

# FINAL DECIMATION AND SMOOTHING

# Smooth surface with iterations = 10 and lambda = 0.6
create HxSurfaceSmooth "finalSmooth"
"finalSmooth" data connect $surfaceName
"finalSmooth" fire
"finalSmooth" parameters setValue 0 10
"finalSmooth" parameters setValue 1 0.6
"finalSmooth" fire
set hideNewModules 0
["finalSmooth" action hit; "finalSmooth" fire; "finalSmooth" getResult] setLabel "$finalSurfName"
"$finalSurfName" showIcon

# If output directory given, export surface as stl file, save in script directory
if {[info exist outputDir] & [llength $outputDir]> 0} {
	echo "saving file here: $outputDir"
	
	"$finalSurfName" exportData "STL ascii" "$outputDir/$finalSurfName.stl"
	echo "Saved file: $outputDir/$finalSurfName.stl"
}