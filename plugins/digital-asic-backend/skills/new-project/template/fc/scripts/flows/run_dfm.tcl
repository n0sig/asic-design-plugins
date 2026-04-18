######################################################################
# Run DFM Step Only
# Opens existing library, runs DFM (redundant vias, fillers, DRC/LVS)
######################################################################
source ../scripts/setup.tcl
open_lib $DESIGN_LIBRARY
source ../scripts/stages/dfm.tcl
