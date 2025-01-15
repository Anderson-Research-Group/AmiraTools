# Surface Generation for Amira 5.6, 6.0.1, and 6.2.0
# L. Schuring, 1/2025

# maxIters ensures that the decimation/smoothing while loop doesn't go to infinity
set maxIters 10

# GENERATE SURFACE (constrained smoothing)
create HxGMC "Generate Surface"
"Generate Surface" setVar "CustomHelp" {HxGMC}
"Generate Surface" data connect $labelFile
"Generate Surface" fire
"Generate Surface" smoothing setIndex 0 2
"Generate Surface" smoothingExtent setValue 5
"Generate Surface" applyTransformToResult 1
"Generate Surface" fire
"Generate Surface" setPickable 1
[ "Generate Surface" create Surface0] setLabel "Surface0"
Surface0 master connect "Generate Surface" "result" 0
Surface0 fire
Surface0 select
theObjectPool setSelectionOrder Surface0

# GET # OF SURFACE FACES (faceN) 
set output ["Surface0" Surface getValue]
regexp {(\d+) faces} $output match faceN
#echo "NUMBER OF FACES" $faceN

# ITERATIVE SIMPLIFICATION AND SMOOTHING OF SURFACE
set faceN [expr {$faceN / 2}]
set iters 0
while {$faceN > $desiredFaceN & $iters < $maxIters} {

	set surfaceName "Surface$iters"
	set smoothName "Smooth$iters"
	
	# reduce face count be cut in half (halfed outside of while loop and at end of while loop)
	$surfaceName setEditor [create HxSimplifier "Simplifier"]
	$surfaceName simplifyParameters setValue $faceN
	$surfaceName simplifyAction setValue 0
	$surfaceName simplifyAction send

	# Smooth surface with iterations = 20 and lambda = 0.6
	create HxSurfaceSmooth $smoothName
	$smoothName data connect $surfaceName
	$smoothName fire
	$smoothName parameters setValue 0 20
	$smoothName parameters setValue 1 0.6
	$smoothName fire
	
	set iters [expr {$iters + 1}]
	set surfaceName "Surface$iters"
	echo "While loop iteration:" $iters
	[$smoothName action hit; $smoothName fire; $smoothName getResult] setLabel $surfaceName
		
	set faceN [expr {$faceN / 2}]	
}


# FINAL DECIMATION AND SMOOTHING
# reduce face count be the desiredFaceN
$surfaceName setEditor [create HxSimplifier "Simplifier"]
$surfaceName simplifyParameters setValue $desiredFaceN
$surfaceName simplifyAction setValue 0
$surfaceName simplifyAction send

# Smooth surface with iterations = 10 and lambda = 0.6
create HxSurfaceSmooth "finalSmooth"
"finalSmooth" data connect $surfaceName
"finalSmooth" fire
"finalSmooth" parameters setValue 0 10
"finalSmooth" parameters setValue 1 0.6
"finalSmooth" fire
["finalSmooth" action hit; "finalSmooth" fire; "finalSmooth" getResult] setLabel "finalSurface"

# If output directory given, export surface as stl file, save in script directory
if {[info exist outputDir] & [llength $outputDir]> 0} {
	echo "saving file here: $outputDir"
	set stlFileName [file rootname [file tail $labelFile]]
	"finalSurface" exportData "STL ascii" "$outputDir/$stlFileName.stl"
}
#set stlFileName [string map {.am .stl} $labelFile]
