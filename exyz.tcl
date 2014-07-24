#------------------------------------------------------------
# exyz.tcl
# functions to handle exyz
# * exyz_read_data
#------------------------------------------------------------
# by kweber 2013/04/17
#------------------------------------------------------------
# set a list of available functions
set functionlist {}

# read extended xyz file
lappend functionlist exyz_read_data
proc exyz_read_data {filename molID} {
    # list available keywords via
    # atomselect keywords
    set frm -1
    set numatms [molinfo $molID get numatoms]
    # read file
    set linecnt -1
    set fh [ open $filename ]
    while {[gets $fh line] >= 0} {	
	set linedata [regexp -inline -all -- {\S+} $line]
	# line counter
	incr linecnt
	# read head
	if {[llength $linedata]==1} {
	    set linecnt 0
	    incr frm 
	    # check if number of atoms matches
	    lassign $linedata numatms2
	    if {$numatms2 != $numatms} {
		puts "error: number of atoms in xyz file does not match molecule!"
		return
	    }
	    # read comment
	    gets $fh comment
	    incr linecnt
	    set commands [regexp -inline -all -- {\S+} $comment]
	    set ncommands [llength $commands]
	    # create list for every command
	    for {set ccnt 0} {$ccnt<$ncommands} {incr ccnt} { 
		set l[lindex $commands $ccnt] {}
	    }		  
	} 
	
	# Read additional data
	set atmcnt 0
	for {set i 0} {$i<$numatms} {incr i} {
	    if {[gets $fh line]<0} {
		puts "error: unexpected end of xyz-file!"
		return
	    }
	    # counter
	    incr atmcnt
	    incr linecnt
	    # process data
	    set linedata [regexp -inline -all -- {\S+} $line]
	    # assign data to real variables lists l${command}
	    set cnt -1
	    foreach e $linedata {
		incr cnt
		if {$cnt>=3} {
		    # check for number of rows
		    if {$cnt-4>$ncommands} {
			puts "error: number of rows does not match assignment in comment"
			return
		    }
		    lappend l[lindex $commands [expr $cnt-4]] $e
		}
	    }
	}
	# check for number of atoms
	if {$atmcnt!=$numatms} {
	    puts "error: expected $numatms atoms but found only $atmcnt in frame $frm!"
	    return
	}
	
	# save data lists l${command} to atomdata $command
	set sel [atomselect $molID "all" frame $frm]
	for {set ccnt 0} {$ccnt<$ncommands} {incr ccnt} { 
	    $sel set [lindex $commands $ccnt] [set l[lindex $commands $ccnt]] 
	}
	# remove selection
	$sel delete
    }
    # close file
    close $fh
    puts "... variables $commands read succesfully"
}
