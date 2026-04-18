######################################################################
# Fusion Compiler ECO Setup
# Opens existing design library — does NOT recreate it
######################################################################
source ../scripts/setup.tcl

open_lib $DESIGN_LIBRARY

######################################################################
# Run ECO Flow
######################################################################
source ../scripts/stages/eco.tcl
