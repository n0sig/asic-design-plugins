######################################################################
# Run Routing Step Only
# Opens existing library, runs routing + optimization
######################################################################
source ../scripts/setup.tcl
open_lib $DESIGN_LIBRARY
source ../scripts/stages/routing.tcl
