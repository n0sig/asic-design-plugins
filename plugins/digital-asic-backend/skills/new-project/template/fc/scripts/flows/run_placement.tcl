######################################################################
# Run Placement Step Only
# Opens existing library, runs placement optimization
######################################################################
source ../scripts/setup.tcl
open_lib $DESIGN_LIBRARY
source ../scripts/stages/placement.tcl
