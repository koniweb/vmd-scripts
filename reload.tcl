#------------------------------------------------------------
# display_standard.tcl
# sets representations, colors etc. to standard
# * reload
#------------------------------------------------------------
# by kweber 2012/09/17
#------------------------------------------------------------
# set a list of available functions
set functionlist {}

# standart display settings
lappend functionlist reload
proc reload {whichmolecules} {
    # do this for all molecules
    foreach mid [molinfo $whichmolecules] {
	# set filename and type
	lassign [ lindex [molinfo $mid get filename] 0] filename
	lassign [ lindex [molinfo $mid get filetype] 0] filetype
	# save view
	set view [molinfo $mid get {center_matrix rotate_matrix scale_matrix global_matrix}]
	# save Representations
	set rep ""
	set nrep [molinfo top get numreps]
	for {set ir 0} {$ir < $nrep} {incr ir} {
	    lappend rep [molinfo top get "{rep $ir} {selection $ir} {color $ir}"]
	}
	# delete molecule
	animate delete all
	# load file new
	lassign [molinfo top get id ] savetopid
	mol top $mid
	mol addfile $filename type $filetype
	mol top $savetopid
	# restore view
	molinfo top set {center_matrix rotate_matrix scale_matrix global_matrix} $view
	# restore display settings
	### delete existing representations for all molecules
        for {set i 0} {$i < $nrep} {incr i} {mol delrep 0 $mid}
	### add old representations
        for {set ir 0} {$ir < $nrep} {incr ir} {
	    mol color [lindex $rep $ir 2]
	    mol selection [lindex $rep $ir 1]
	    mol addrep $mid
	    mol modstyle $ir $mid [lindex $rep $ir 0]
	}
    }	
}
