#------------------------------------------------------------
# color.tcl
# functions to handle coloring
# * exyz_read_data
#------------------------------------------------------------
# by kweber 2013/04/17
#------------------------------------------------------------
# set a list of available functions
set functionlist {}

# read extended xyz file
lappend functionlist color_data_map
proc color_data_map {molID repID data} {
    # do for molID list
    foreach mid $molID {
	set rep {}
	set sel {}
	set col {}
	set numreps [molinfo $mid get numreps]
	# do for repID list
	foreach rid $repID {
	    lassign [molinfo $mid get "{rep $rid}  {selection $rid } 
            {color $rid }  {material $rid }"] rep sel col mat

	    # search for maximum color values
	    set newdata $data
	    set ldata {}
	    set lmin {}
	    set lmax {}
	    # loop over frames append min max data
	    set numframes [molinfo $mid get numframes]   
	    for {set fcnt 0} {$fcnt<$numframes} {incr fcnt} {
		set asel [atomselect $mid all frame $fcnt]
		set ldata [$asel get $newdata]
		set ldata [lsort -increasing $ldata]
		lappend lmin [lindex $ldata 0]
		lappend lmax [lindex $ldata end]
	    }
	    # find minimum und maximum
	    set max [lindex [lsort -decreasing $lmax ] 0]
	    set min [lindex [lsort -increasing $lmin ] 0]
	    
	    # add representation
	    set nrep [molinfo $mid get numreps]
	    mol color $newdata
	    mol representation $rep
	    mol selection $sel
	    mol material $mat
	    mol addrep $mid
	    # hide old representation
	    mol showrep $mid $rid off
	    # change scale method
	    color scale method rgb
	    mol scaleminmax $mid $nrep $min $max
	}
    }
    # open gui to add color scale bar
    puts "Set Minimum scale value: $min"
    puts "Set Maximum scale value: $max"
    puts "Set Color of labels:     black"
    puts "-->Press Draw Color Scale Bar"
    colorscalebar_tk_cb
}
