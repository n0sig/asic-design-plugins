######################################################################
# Run Floorplan Step Only
# Opens existing library, runs floorplan
######################################################################
source ../scripts/setup.tcl
open_lib $DESIGN_LIBRARY
source ../scripts/stages/floorplan.tcl
