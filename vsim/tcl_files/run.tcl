#!/bin/bash
# \
exec vsim -64 -do "$0"

set TB            tb
set VSIM_FLAGS    ""
set MEMLOAD       "PRELOAD"

source ./tcl_files/config/vsim.tcl
