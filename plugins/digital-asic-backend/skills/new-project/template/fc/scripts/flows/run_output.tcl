######################################################################
# Run Output Step Only
# Opens existing library, writes all output files and final reports
######################################################################
source ../scripts/setup.tcl
open_lib $DESIGN_LIBRARY
source ../scripts/stages/output.tcl
