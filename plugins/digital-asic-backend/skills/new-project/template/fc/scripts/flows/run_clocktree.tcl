######################################################################
# Run Clock Tree Synthesis Step Only
# Opens existing library, runs CTS + clock optimization
######################################################################
source ../scripts/setup.tcl
open_lib $DESIGN_LIBRARY
source ../scripts/stages/clocktree.tcl
