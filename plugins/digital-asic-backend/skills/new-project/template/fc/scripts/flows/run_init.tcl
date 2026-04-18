######################################################################
# Run Init Stage Only
# Creates design library, reads RTL, applies constraints
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
# Run Init
######################################################################
source ../scripts/stages/init.tcl
