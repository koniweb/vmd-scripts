#------------------------------------------------------------
# display_standard.tcl
# sets representations, colors etc. to standard
# * display_standard
#------------------------------------------------------------
# by kweber 2012/09/17
#------------------------------------------------------------
# set a list of available functions
set functionlist {}

# standart display settings
lappend functionlist display_standard
proc display_standard {whichmolecules} {
    # do this for all molecules
    foreach mid [molinfo $whichmolecules] {
        # delete existing representations
        set numreps [molinfo $mid get numreps]
        for {set rep 0} {$rep < $numreps} {incr rep} {
    	mol delrep 0 $mid
        }
        
        # change default rep for already loaded molecules
        mol selection "all"
        mol color Type
        # CPK
        mol addrep $mid
        mol modstyle 0 $mid CPK 1.0 0.0 23 21
	# Dynamic Bonds (turned off)
        mol addrep $mid
        mol modstyle 1 $mid DynamicBonds 2.1 0.3 8
	mol showrep $mid 1 off
    }
}
