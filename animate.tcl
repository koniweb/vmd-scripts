#------------------------------------------------------------
# animate.tcl
#------------------------------------------------------------
# by kweber 2012/07/05
# * render_png
# * render_rgb
# * video_sim
# * video_rot
#------------------------------------------------------------
# set a list of available functions
set functionlist {}

# render in povray
lappend functionlist render_png
proc render_png {name {sizex 3} {sizey 3} } {
    render POV3 $name.pov exec ~/bin/pov2png.sh $name.pov $sizex $sizey "+UA"
}

lappend functionlist render_rgb
proc render_rgb {name {sizex ""} {sizey ""} } {
    render snapshot $name.rgb
}

# animate simulation
lappend functionlist video_sim
proc video_sim {rendering
		{name movie}
		{startstep 0} 
		{endstep 1000000}
		{increment 1} 
		{sizex ""}
		{sizey ""}
		{delay 10} 
		{delete "yes"} } {
    animate goto start
    set frame 0
    # make folder
    set folder $name
    exec mkdir $folder
    # creating snapshots
    for {set cnt $startstep} {$cnt <= $endstep} {incr cnt $increment} {
        animate goto $cnt
        set filename snap.${name}.[format "%06d" $frame]
        render_$rendering $filename $sizex $sizey
	exec mv $filename.$rendering $folder
        incr frame 
    }
    # creating video
    exec convert -delay 10 -loop 4 ${folder}/snap.*.$rendering \
	${folder}/$name.gif
    # remove everything
    if {${delete} != "no"} {
	foreach fileobject [glob -nocomplain ${folder}/snap.*] \
	    { catch {exec rm -fR $fileobject} }
    }
    # echo
    echo ...video rendering finished
    echo ...video saved in $name.gif
}

# animate rotation
lappend functionlist video_rot
proc video_rot {rendering {name movie} {steps 10} {delete "yes"} } {
    # Setting up
    set end 360
    # make folder
    set folder ${name}
    exec mkdir ${folder}
    # Creating snapshots
    set frame 0
    set degree [expr $end / $steps] 
    for {set i 0} {$i < $end} {incr i $degree} {
        set filename snap.$name.[format "%06d" $frame]
	render_$rendering $filename $sizex $sizey
        exec mv $filename.$rendering $folder
        incr frame 
        rotate y by $degree
    }
    # creating video
    exec convert -delay 10 -loop 4 ${folder}/snap.*.rgb ${folder/}$name.gif
    # remove everything
    if {${delete} != "no"} {
	foreach fileobject [glob -nocomplain ${folder}/snap.*] \
	    { catch {exec rm -fR $fileobject} }
    }
    # echo
    echo ...video rendering finished
    echo ...video saved in $name.gif
}
