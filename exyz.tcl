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
    # include a $aX $aY $aZ b $bX $bY $bZ c $cX $cY $cZ
    # and any other keywords which are read in e.g. charge
    # example comment line: a 1.0 0.0 0.0 b 0.0 1.0 0.0 c 0.0 0.0 1.0 charge
    global M_PI
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
	    # get number of commands
	    set ncommands [llength $commands]
	    # create list for every command and 
	    #check if comment starts with vector definition
	    for {set ccnt 0} {$ccnt<$ncommands} {incr ccnt} { 
		if {[lindex $commands $ccnt] == "a"} {
		    set a [list [lindex $commands $ccnt+1] \
    			       [lindex $commands $ccnt+2]  \
			       [lindex $commands $ccnt+3] ]
		    # delete a data
		    set commands [lreplace $commands $ccnt $ccnt+3]
		    incr ccnt -1
		    set ncommands [llength $commands]
		} elseif {[lindex $commands $ccnt] == "b"} {
		    set b [list [lindex $commands $ccnt+1] \
			       [lindex $commands $ccnt+2]  \
			       [lindex $commands $ccnt+3] ]
		    # delete a data
		    set commands [lreplace $commands $ccnt $ccnt+3]
		    incr ccnt -1
		    set ncommands [llength $commands]		    
		} elseif {[lindex $commands $ccnt] == "c"} {
		    set c [list [lindex $commands $ccnt+1] \
			       [lindex $commands $ccnt+2]  \
			       [lindex $commands $ccnt+3] ]
		    # delete a data
		    set commands [lreplace $commands $ccnt $ccnt+3]
		    incr ccnt -1
		    set ncommands [llength $commands]		    
		} else {
		    set l[lindex $commands $ccnt] {}
		    puts [lindex $commands $ccnt]
		}
	    }		  
	} 

	# calculate lengths and angles
	set la [ veclength $a ]
	set lb [ veclength $b ]
	set lc [ veclength $c ]
	set alpha [ expr acos( [vecdot $b $c] / $lb / $lc ) *180/$M_PI ]	
	set beta  [ expr acos( [vecdot $a $c] / $la / $lc ) *180/$M_PI ]
	set gamma [ expr acos( [vecdot $a $b] / $la / $lb ) *180/$M_PI ]
	puts "... vectors set as $la $lb $lc $alpha $beta $gamma"
	# set vectors
	molinfo $molID set a $la
	molinfo $molID set b $lb
	molinfo $molID set c $lc
	molinfo $molID set alpha $alpha
	molinfo $molID set beta  $beta
	molinfo $molID set gamma $gamma

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
