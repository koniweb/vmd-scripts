#------------------------------------------------------------
# arrows.tcl
# functions to draw arrows
# * draw_velocity_arrows
# * draw_arrow
# * draw_animate_velocity_arrows
# * draw_new_velocity_arrows
#------------------------------------------------------------
# by kweber 2013/04/17
#------------------------------------------------------------
# set a list of available functions
set functionlist {}

# draw arrows from two positions
lappend functionlist draw_arrow
proc draw_arrow {molID start end {radius 0.2} {resol 8}} {
  set rcyl $radius
    set rcon [expr $rcyl*2]
    set diffvec [vecsub $end $start]
    set veclen  [veclength $diffvec]
    set unitvec [vecscale [expr 1/$veclen] $diffvec]
    if {$veclen==0} { return }
    if {$veclen>[expr 2*$rcon]} {
	set middle [vecsub $end [vecscale [expr 2*$rcon] $unitvec]]
#     graphics $molID sphere $start radius $rcyl resolution $resol
    graphics $molID cylinder $start $middle radius $rcyl filled yes resolution $resol
    graphics $molID cone $middle $end radius $rcon resolution $resol
    } else {
	#     graphics $mol sphere $start radius [expr 0.25*$veclen] resolution $resol
	graphics $molID cone $start $end radius [expr 0.5*$veclen] resolution $resol
    }
}

# use position of atom and vx vy vz to draw an arrow
lappend functionlist draw_velocity_arrows
proc draw_velocity_arrows {molID onoff {scale 2} {radius 0.05} {resol 8}} {
    if {[string match "on" $onoff]} {
	set sel [atomselect $molID "all" frame now]
	set velvecs [$sel get {vx vy vz}]
	set posvecs [$sel get {x y z}]
	# get maximum value
	set veclenmax 0
	foreach pos $posvecs vel $velvecs {
	    set veclen [veclength $vel]
	    if {$veclen>$veclenmax} {
		set veclenmax $veclen
	    }
	}
	foreach pos $posvecs vel $velvecs {
	    set veclen [veclength $vel]
	    if {$veclen>0} {
		set unitvec [vecscale [expr ($scale)/($veclenmax)] $vel]
		draw_arrow $molID $pos [vecadd $pos $unitvec] $radius $resol
	    }
	}
	$sel delete
	puts "... vectors successfully drawn with scale $scale radius $radius and resolution $resol"
    } elseif {[string match "off" $onoff]} {
	graphics $molID delete all
	puts "... vectors successfully removed"
    }
}

# use animate command with arrows
lappend functionlist draw_animate_velocity_arrows
proc draw_animate_velocity_arrows {molID frame {sleeptime 0.5} {scale 2} {radius 0.05} {resol 8}} {
    set numframes [molinfo $molID get numframes]
    # adapt animate command to draw arrows
    if {[string is integer -strict $frame] && $frame>=0 || $frame == "start" || $frame == "end" } {
	animate goto $frame
	draw_new_velocity_arrows $molID $scale $radius $resol
    } elseif {$frame == "next" || $frame == "prev"} {
	animate $frame
	draw_new_velocity_arrows $molID $scale $radius $resol
    # animate movie
    } elseif {$frame == "forward" || $frame == "for" || 
	      $frame == "rev" || $frame == "reverse"} {
	if {$frame == "forward" || $frame == "for"} {set step 1
	} else {set step -1}
	set nframe [molinfo $molID get frame]
	for {set cntf $nframe} {$cntf < $numframes && $cntf >=0} {incr cntf $step} {
	    animate goto $cntf
	    draw_new_velocity_arrows $molID $scale $radius $resol
	    display update ui
	    sleep $sleeptime
	}
    } else {
	puts "frame command $frame not known"
	puts "known commands: framenumber, next, prev, start, end, for, rev"
	return
    }
}

# redraw arrows
lappend functionlist draw_new_velocity_arrows
proc draw_new_velocity_arrows {molID {scale 2} {radius 0.05} {resol 8}} {
	graphics $molID delete all
	draw_velocity_arrows $molID on $scale $radius $resol
}

