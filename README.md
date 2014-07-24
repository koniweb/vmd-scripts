vmd-scripts
===========

A small set of small tcl-scripts for vmd

To source all these files and read out available functions:
foreach file [glob -nocomplain FOLDER/*.tcl]  {
    source $file
    puts "...file $file loaded"
    puts "   --> available functions: $functionlist"