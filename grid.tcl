#------------------------------------------------------------
# grid.tcl
#------------------------------------------------------------
# by hdietrich 2014-05-30
# * show_scale
# * show_grid
#------------------------------------------------------------
# set a list of available functions
set functionlist {}

# shows scale
lappend functionlist show_scal
proc show_scale {{res 5} {molid "top"} {gcolor "black"}} {
    set offset [expr $res/2]
    set numatoms [expr [molinfo $molid get numatoms]-1]
    set sel [atomselect $molid all]
    set x [lsort -real [$sel get x]]
    set y [lsort -real [$sel get y]]
    set z [lsort -real [$sel get z]]
    set min(0) [expr int([lindex $x 0]-3)]
    set min(1) [expr int([lindex $y 0]-3)]
    set min(2) [expr int([lindex $z 0]-3)]
    set max(0) [expr int([lindex $x $numatoms]+3)]
    set max(1) [expr int([lindex $y $numatoms]+3)]
    set max(2) [expr int([lindex $z $numatoms]+3)]
    set min2(0) [expr int(([lindex $x 0]-3)/$res)]
    set min2(1) [expr int(([lindex $y 0]-3)/$res)]
    set min2(2) [expr int(([lindex $z 0]-3)/$res)]
    set max2(0) [expr int(([lindex $x $numatoms]+3)/$res)]
    set max2(1) [expr int(([lindex $y $numatoms]+3)/$res)]
    set max2(2) [expr int(([lindex $z $numatoms]+3)/$res)]
    for {set i $min2(0)} {$i <= $max2(0)} {incr i} {
    graphics $molid color $gcolor
	graphics $molid text [list [expr $i*$res] [expr $min(1)-$offset] [expr $min(2)-$offset]] [expr $i*$res]
    graphics $molid color blue
	set start [list [expr $i*$res] $min(1) $min(2)]
	set end   [list [expr $i*$res] $min(1) $max(2)]
    graphics $molid line $start $end
	set start [list [expr $i*$res] $max(1) $min(2)]
	set end   [list [expr $i*$res] $max(1) $max(2)]
    graphics $molid line $start $end
	set start [list [expr $i*$res] $min(1) $min(2)]
	set end   [list [expr $i*$res] $max(1) $min(2)]
    graphics $molid line $start $end
	set start [list [expr $i*$res] $min(1) $max(2)]
	set end   [list [expr $i*$res] $max(1) $max(2)]
    graphics $molid line $start $end
    }
    for {set i $min2(1)} {$i <= $max2(1)} {incr i} {
    graphics $molid color $gcolor
	graphics $molid text [list [expr $min(0)-$offset] [expr $i*$res] [expr $min(2)-$offset]] [expr $i*$res]
    graphics $molid color blue
	set start [list $min(0) [expr $i*$res] $min(2)]
	set end   [list $min(0) [expr $i*$res] $max(2)]
    graphics $molid line $start $end
	set start [list $max(0) [expr $i*$res] $min(2)]
	set end   [list $max(0) [expr $i*$res] $max(2)]
    graphics $molid line $start $end
	set start [list $min(0) [expr $i*$res] $min(2)]
	set end   [list $max(0) [expr $i*$res] $min(2)]
    graphics $molid line $start $end
	set start [list $min(0) [expr $i*$res] $max(2)]
	set end   [list $max(0) [expr $i*$res] $max(2)]
    graphics $molid line $start $end
    }
    for {set i $min2(2)} {$i <= $max2(2)} {incr i} {
    graphics $molid color $gcolor
	graphics $molid text [list [expr $min(0)-$offset] [expr $min(1)-$offset] [expr $i*$res]] [expr $i*$res]
    graphics $molid color blue
	set start [list $min(0) $min(1) [expr $i*$res]]
	set end   [list $min(0) $max(1) [expr $i*$res]]
    graphics $molid line $start $end
	set start [list $max(0) $min(1) [expr $i*$res]]
	set end   [list $max(0) $max(1) [expr $i*$res]]
    graphics $molid line $start $end
	set start [list $min(0) $min(1) [expr $i*$res]]
	set end   [list $max(0) $min(1) [expr $i*$res]]
    graphics $molid line $start $end
	set start [list $min(0) $max(1) [expr $i*$res]]
	set end   [list $max(0) $max(1) [expr $i*$res]]
    graphics $molid line $start $end
    }
    graphics $molid text [list [expr $min(0)-$offset] [expr $min(1)-$offset] [expr $min(2)-$offset]] 0
}

# shows scale
lappend functionlist show_grid
proc show_grid {{res 2} {molid "top"} {gcolor "black"}} {
    set numatoms [expr [molinfo $molid get numatoms]-1]
    set sel [atomselect $molid all]
    set x [lsort -real [$sel get x]]
    set y [lsort -real [$sel get y]]
    set z [lsort -real [$sel get z]]
    set min(0) [expr int([lindex $x 0])-3]
    set min(1) [expr int([lindex $y 0])-3]
    set min(2) [expr int([lindex $z 0])-3]
    set max(0) [expr int([lindex $x $numatoms])+3]
    set max(1) [expr int([lindex $y $numatoms])+3]
    set max(2) [expr int([lindex $z $numatoms])+3]
  graphics $molid color $gcolor
    set nmaxx [expr int(($max(0)-$min(0))/$res)]
    set nmaxy [expr int(($max(1)-$min(1))/$res)]
    set nmaxz [expr int(($max(2)-$min(2))/$res)]
    for {set x 0} {$x<=$nmaxx} {incr x} {
	for {set y 0} {$y<=$nmaxy} {incr y} {
	    set start [list [expr $x*$res+$min(0)] [expr $y*$res+$min(1)] $min(2)]
	    set end   [list [expr $x*$res+$min(0)] [expr $y*$res+$min(1)] $max(2)]
      graphics $molid line $start $end
	}
    }
    for {set x 0} {$x<=$nmaxx} {incr x} {
	for {set z 0} {$z<=$nmaxz} {incr z} {
	    set start [list [expr $x*$res+$min(0)] $min(1) [expr $z*$res+$min(2)]]
	    set end   [list [expr $x*$res+$min(0)] $max(1) [expr $z*$res+$min(2)]]
      graphics $molid line $start $end
	}
    }
    for {set y 0} {$y<=$nmaxy} {incr y} {
	for {set z 0} {$z<=$nmaxz} {incr z} {
	    set start [list $min(0) [expr $y*$res+$min(1)] [expr $z*$res+$min(2)]]
	    set end   [list $max(0) [expr $y*$res+$min(1)] [expr $z*$res+$min(2)]]
      graphics $molid line $start $end
	}
    }
} 
