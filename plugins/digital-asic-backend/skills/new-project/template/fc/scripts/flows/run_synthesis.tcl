######################################################################
# Run Synthesis Step Only
# Opens existing library, runs synthesis + placement
######################################################################
source ../scripts/setup.tcl
open_lib $DESIGN_LIBRARY
source ../scripts/stages/synthesis.tcl
