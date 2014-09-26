#------------------------------------------------------------
# periodic.tcl
# functions to show periodic features faster
#* periodic
#------------------------------------------------------------
# by kweber 2012/11/01
#------------------------------------------------------------
# set a list of available functions
set functionlist {}

# show periodic for all representations of all molecules
lappend functionlist periodic
proc periodic {a b c alpha beta gamma {number 1} {direction ""} } {
    # set standard direction
    if { $direction == "" } { set direction xy }
    # set the representation
    foreach mid [molinfo list] {
        set numreps [molinfo $mid get numreps]
        for {set rep 0} {$rep < $numreps} {incr rep} {

	    echo periodicity of rep $rep set to
	    echo $mid $rep $a $b $c $alpha $beta $gamma

	    set numframes [molinfo $mid get numframes]
	    for {set i 0} {$i < $numframes} {incr i} {
		molinfo $mid set frame $i
		molinfo $mid set a $a
		molinfo $mid set b $b
		molinfo $mid set c $c
		molinfo $mid set alpha $alpha
		molinfo $mid set beta $beta
		molinfo $mid set gamma $gamma
	    }
	    mol showperiodic $mid $rep $direction
	    mol numperiodic $mid $rep $number
	}
    }
}

# show periodic for all representations of all molecules
lappend functionlist boxxyz
proc boxxyz { {a {}} {b {}} {c {}} {whichmolecules "top"} } {
    global M_PI
    # set vectors orthogonal standart if not set
    if {[veclength $a]==0} { set a {1.0 0.0 0.0}}
    if {[veclength $b]==0} { set b {0.0 1.0 0.0}}
    if {[veclength $c]==0} { set c {0.0 0.0 1.0}}
    # calculate lengths and angles and set those
    set la [ veclength $a ]
    set lb [ veclength $b ]
    set lc [ veclength $c ]
    set alpha [ expr acos( [vecdot $b $c] / $lb / $lc ) *180/$M_PI ]
    set beta  [ expr acos( [vecdot $a $c] / $la / $lc ) *180/$M_PI ]
    set gamma [ expr acos( [vecdot $a $b] / $la / $lb ) *180/$M_PI ]
    puts "... vectors set as $la $lb $lc $alpha $beta $gamma"
    # do this for all molecules                                                                                     
    foreach mid [molinfo $whichmolecules] {
	# set vectors
	molinfo $mid set a $la
	molinfo $mid set b $lb
	molinfo $mid set c $lc
	molinfo $mid set alpha $alpha
	molinfo $mid set beta  $beta
	molinfo $mid set gamma $gamma
    }
    pbc box_draw
}

# creates new molecule with more atoms to get bonds correctly
lappend functionlist periodic_mult
proc periodic_mult {molID nx ny nz {a 0} {b 0} {c 0} {alpha 0} {beta 0} {gamma 0}} {
    # check a, b, c 
    if { $a==0.0 || $b==0.0 || $c==0 } {
	foreach mid $molID {
	    if {[molinfo $mid get a]==0 || 
		[molinfo $mid get b]==0 || 
		[molinfo $mid get c]==0} {
		vmdcon -err "a,b or c not given."
		return -1
	    } else {
		set a [molinfo $mid get a]
		set b [molinfo $mid get b]
		set c [molinfo $mid get c]
	    }
	}
    }
    # check angles
    if { $alpha==0.0 || $beta==0.0 || $gamma==0 } {
	foreach mid $molID {
	    if {[molinfo $mid get alpha]==0 || 
		[molinfo $mid get beta] ==0 || 
		[molinfo $mid get gamma]==0} {
		vmdcon -err "alpha, beta or gamma not given."
		return -1
	    } else {
		set alpha [molinfo $mid get alpha]
		set beta  [molinfo $mid get beta]
		set gamma [molinfo $mid get gamma]
	    }
	}
    }
    # for all molecules
    foreach mid $molID {
	set rep {}
	set sel {}
	set col {}
	# for all representations
        set numreps [molinfo $mid get numreps]
	for {set nrep 0} {$nrep < $numreps} {incr nrep} {
	    # for all frames
	    set numframes [molinfo $mid get numframes]
	    for {set i 0} {$i < $numframes} {incr i} {
		# set everything periodic
		molinfo $mid set frame $i
		molinfo $mid set a $a
		molinfo $mid set b $b
		molinfo $mid set c $c
		molinfo $mid set alpha $alpha
		molinfo $mid set beta $beta
		molinfo $mid set gamma $gamma
		# save representation
	    }
	    lassign [molinfo $mid get "{rep $nrep}  {selection $nrep } {color $nrep }  {material $nrep }"] var1 var2 var3 var4
	    lappend rep $var1
	    lappend sel $var2
	    lappend col $var3
	    lappend mat $var4
	    puts "... periodicity of rep $nrep set to"
	    puts "    $mid $a $b $c $alpha $beta $gamma"
	}

	# copy molecule and copy representations
	set newmol [replicatemol_nonortho $mid $nx $ny $nz]
	set newid [lindex [molinfo list] end]
	# delete old representations
	set numrepsnew [molinfo $newid get numreps]
	puts $numrepsnew
	for {set nrep 0} {$nrep < $numrepsnew} {incr nrep} {
	    mol delrep $nrep $newid
	}
	# add old representation
        for {set nrep 0} {$nrep < $numreps} {incr nrep} {
	    mol color [lindex $col $nrep]
	    mol representation [lindex $rep $nrep]
	    mol selection [lindex $sel $nrep]
	    mol material [lindex $mat $nrep]
	    mol addrep $newid
	    for {set i 0} {$i < $numframes} {incr i} {
                # set everything periodic
		molinfo $newid set a [expr $a*$nx]
                molinfo $newid set b [expr $b*$nx]
		molinfo $newid set c [expr $c*$nx]
	    }
	}
	puts "... molecule $mid multiplied to $newid by $nx $ny $nz"
    }
}

# creates new molecule with more atoms to get bonds correctly 
# (works with topotools and therefore only with orthogonal boxes)
lappend functionlist periodic_mult_ortho
proc periodic_mult_ortho {molID nx ny nz {a 0.0} {b 0.0} {c 0.0} } {
    # check a, b, c 
    if { $a==0.0 || $b==0.0 || $c==0 } {
	foreach mid $molID {
	    if {[molinfo $mid get a]==0 || 
		[molinfo $mid get b]==0 || 
		[molinfo $mid get c]==0} {
		vmdcon -err "a,b or c not given."
		return -1
	    } else {
		set a [molinfo $mid get a]
		set b [molinfo $mid get b]
		set c [molinfo $mid get c]
	    }
	}
    }
    # check angles
    foreach mid $molID {
	if { [molinfo $mid get alpha]!=90 || 
	     [molinfo $mid get beta] !=90 ||
	     [molinfo $mid get gamma]!=90} {
	    vmdcon -err "alpha, beta or gamma not given correctly."
	    return -1
	}
    }
    # only rectangular boxes
    set alpha 90
    set beta 90
    set gamma 90
    # for all molecules
    foreach mid $molID {
	set rep {}
	set sel {}
	set col {}
	# for all representations
        set numreps [molinfo $mid get numreps]
	for {set nrep 0} {$nrep < $numreps} {incr nrep} {
	    # for all frames
	    set numframes [molinfo $mid get numframes]
	    for {set i 0} {$i < $numframes} {incr i} {
		# set everything periodic
		molinfo $mid set frame $i
		molinfo $mid set a $a
		molinfo $mid set b $b
		molinfo $mid set c $c
		molinfo $mid set alpha $alpha
		molinfo $mid set beta $beta
		molinfo $mid set gamma $gamma
		# save representation
	    }
	    lassign [molinfo $mid get "{rep $nrep}  {selection $nrep } {color $nrep }  {material $nrep }"] var1 var2 var3 var4
	    lappend rep $var1
	    lappend sel $var2
	    lappend col $var3
	    lappend mat $var4
	    puts "... periodicity of rep $nrep set to"
	    puts "    $mid $a $b $c $alpha $beta $gamma"
	}

	# copy molecule and copy representations
	set newmol [::TopoTools::replicatemol $mid $nx $ny $nz]
	set newid [lindex [molinfo list] end]
	# delete old representations
	set numrepsnew [molinfo $newid get numreps]
	puts $numrepsnew
	for {set nrep 0} {$nrep < $numrepsnew} {incr nrep} {
	    mol delrep $nrep $newid
	}
	# add old representation
        for {set nrep 0} {$nrep < $numreps} {incr nrep} {
	    mol color [lindex $col $nrep]
	    mol representation [lindex $rep $nrep]
	    mol selection [lindex $sel $nrep]
	    mol material [lindex $mat $nrep]
	    mol addrep $newid
	    for {set i 0} {$i < $numframes} {incr i} {
                # set everything periodic
		molinfo $newid set a [expr $a*$nx]
                molinfo $newid set b [expr $b*$nx]
		molinfo $newid set c [expr $c*$nx]
	    }
	}
	puts "... molecule $mid multiplied to $newid by $nx $ny $nz"
    }
}

# from topotools -> corrected for nonorthogonal boxes
proc replicatemol_nonortho {mol nx ny nz} {

    if {[string equal $mol top]} {
        set mol [molinfo top]
    }

    # build translation vectors
    set xs [expr {-($nx-1)*0.5}]
    set ys [expr {-($ny-1)*0.5}]
    set zs [expr {-($nz-1)*0.5}]
    set transvecs {}
    for {set i 0} {$i < $nx} {incr i} {
        for {set j 0} {$j < $ny} {incr j} {
            for {set k 0} {$k < $nz} {incr k} {
                lappend transvecs [list [expr {$xs + $i}] [expr {$ys + $j}] [expr {$zs + $k}]]
            }
        }
    }

    # compute total number of atoms.
    set nrepl [llength $transvecs]
    if {!$nrepl} {
        vmdcon -err "replicatemol: no or bad nx/ny/nz replications given."
        return -1
    }
    set ntotal 0
    set natoms 0
    if {[catch {molinfo $mol get numatoms} natoms]} {
        vmdcon -err "replicatemol: molecule id $mol does not exist."
        return -1
    } else {
        set ntotal [expr {$natoms * $nrepl}]
    }
    if {!$natoms} {
        vmdcon -err "replicatemol: cannot replicate an empty molecule."
        return -1
    }

    set molname replicatedmol-$nrepl-x-$mol
    set newmol -1
    if {[catch {mol new atoms $ntotal} newmol]} {
        vmdcon -err "replicatemol: could not create new molecule: $mol"
        return -1
    } else {
        animate dup $newmol
    }
    mol rename $newmol $molname

    # copy data over piece by piece
    set ntotal 0
    set bondlist {}
    set anglelist {}
    set dihedrallist {}
    set improperlist {}
    set ctermlist {}

    set oldsel [atomselect $mol all]
    set obndlist [topo getbondlist both -molid $mol]
    set oanglist [topo getanglelist -molid $mol]
    set odihlist [topo getdihedrallist -molid $mol]
    set oimplist [topo getimproperlist -molid $mol]
    set octermlist [topo getcrosstermlist -molid $mol]

    set box     [molinfo $mol get {a b c}]
    molinfo $newmol set {a b c} [vecmul $box [list $nx $ny $nz]]
    set boxtilt [molinfo $mol get {alpha beta gamma}]
    molinfo $newmol set {alpha beta gamma} $boxtilt

    foreach v $transvecs {
        set newsel [atomselect $newmol \
                        "index $ntotal to [expr $ntotal + [$oldsel num] - 1]"]

        # per atom props
        set cpylist {name type mass charge radius element x y z \
                         resname resid chain segname}
        $newsel set $cpylist [$oldsel get $cpylist]

        set movevec {0.0 0.0 0.0}
	if  { $boxtilt=={90 90 90} } {
	    # if orthogonal
	    if {[catch {vecmul $v $box} movevec]} {
		vmdcon -warn "failure to compute translation vector from $v: $movevec. skipping..."
		continue
	    }
        } else {
	    # if not orthogonal
	    set deg2rad [expr 3.141592/180]
	    set alpharad [expr [lindex $boxtilt 0] * $deg2rad]
	    set betarad  [expr [lindex $boxtilt 1] * $deg2rad]
	    set gammarad [expr [lindex $boxtilt 2] * $deg2rad]
	    set ax [lindex $box 0]
	    set bx [expr [lindex $box 1] * cos($gammarad) ]
	    set by [expr [lindex $box 1] * sin($gammarad) ]
	    set cx [expr [lindex $box 2] * cos($betarad) ]
	    set cy [expr [lindex $box 2] * [ expr cos($betarad) -cos($betarad) * cos($gammarad)] / sin($gammarad)] 
	    # calc cz
	    set V1  [expr [lindex $box 0] *  [lindex $box 1] * [lindex $box 2] ]
	    set V21  [expr 1 - cos($alpharad)*cos($alpharad) \
			  - cos($betarad)*cos($betarad)- cos($gammarad)*cos($gammarad) ] 
	    set V22  [expr 2 * [ expr cos($alpharad) * cos($betarad)*cos($gammarad) ] ]
	    set V [expr $V1 * { sqrt ([ expr $V21 + $V22 ]) } ]
	    set cz [expr $V / [expr [lindex $box 0] * [lindex $box 1] * sin($gammarad) ] ]
	    # define vecs as vecs
	    set avec [list $ax 0.0 0.0]
	    set bvec [list $bx $by 0.0]
	    set cvec [list $cx $cy $cz]
	    set movevec [vecadd \
			     [vecscale [lindex $v 0] $avec]  \
			     [vecscale [lindex $v 1] $bvec]  \
			     [vecscale [lindex $v 2] $cvec] ]
	}

        $newsel moveby $movevec
        # assign structure data. we need to renumber indices
        foreach l $obndlist {
            lassign $l a b t o
            lappend bondlist [list [expr {$a+$ntotal}] [expr {$b+$ntotal}] $t $o]
        }
	
        foreach l $oanglist {
            lassign $l t a b c
            lappend anglelist [list $t [expr {$a + $ntotal}] [expr {$b + $ntotal}] \
				   [expr {$c + $ntotal}]]
        }
	
        foreach l $odihlist {
            lassign $l t a b c d
            lappend dihedrallist [list $t [expr {$a + $ntotal}] [expr {$b + $ntotal}] \
				      [expr {$c + $ntotal}] [expr {$d + $ntotal}]]
        }
        foreach l $oimplist {
            lassign $l t a b c d
            lappend improperlist [list $t [expr {$a + $ntotal}] [expr {$b + $ntotal}] \
				      [expr {$c + $ntotal}] [expr {$d + $ntotal}]]
        }
	foreach l $octermlist {
            lassign $l a b c d e f g h
	    lappend ctermlist [list [expr {$a + $ntotal}] [expr {$b + $ntotal}] \
				   [expr {$c + $ntotal}] [expr {$d + $ntotal}] \
				   [expr {$e + $ntotal}] [expr {$f + $ntotal}] \
				   [expr {$g + $ntotal}] [expr {$h + $ntotal}]]
	}
        incr ntotal [$oldsel num]
        $newsel delete
    }
    # apply structure info
    topo setbondlist both -molid $newmol $bondlist
    topo setanglelist -molid $newmol $anglelist
    topo setdihedrallist -molid $newmol $dihedrallist
    topo setimproperlist -molid $newmol $improperlist
    topo setcrosstermlist -molid $mol $ctermlist
    
    #R#variable newaddsrep 
    mol reanalyze $newmol
    #R#if {$newaddsrep} {
    #R#    adddefaultrep $newmol
    #R#}
    
    $oldsel delete
    return $newmol
}
