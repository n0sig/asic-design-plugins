######################################################################
# Run Full Fusion Compiler Flow
# Creates design library from scratch and runs all steps
######################################################################
source ../scripts/setup.tcl

######################################################################
# Create NDM Design Library (destroys existing)
######################################################################
file delete -force $DESIGN_LIBRARY
create_lib $DESIGN_LIBRARY \
    -technology $TECH_FILE \
    -ref_libs [list $NDM_REFERENCE_LIB $NDM_REFERENCE_LIB_PHY_ONLY]

######################################################################
# Run Full Flow
######################################################################
source ../scripts/stages/init.tcl
source ../scripts/stages/floorplan.tcl
source ../scripts/stages/synthesis.tcl
source ../scripts/stages/placement.tcl
source ../scripts/stages/clocktree.tcl
source ../scripts/stages/routing.tcl
source ../scripts/stages/dfm.tcl
source ../scripts/stages/output.tcl
