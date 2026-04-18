######################################################################
# Design Setup — Read RTL, Elaborate, Apply Constraints
######################################################################


######################################################################
# Read and Elaborate RTL
######################################################################
# TODO: Add your RTL files here
analyze -format verilog {
}

elaborate $DESIGN_NAME
set_top_module $DESIGN_NAME


######################################################################
# Read TLU+ Parasitic Tech Files
######################################################################
read_parasitic_tech -tlup $MAX_TLUPLUS_FILE -layermap $TLUPLUS_MAP_FILE -name rcworst
read_parasitic_tech -tlup $MIN_TLUPLUS_FILE -layermap $TLUPLUS_MAP_FILE -name rcbest
read_parasitic_tech -tlup $TYP_TLUPLUS_FILE -layermap $TLUPLUS_MAP_FILE -name rctypical

set_parasitic_parameters -late_spec rcworst -early_spec rcbest

# TODO: Set operating conditions for your design
set_temperature 25
set_voltage 1.20


######################################################################
# Enable Clock Reconvergence Pessimism Removal (CRPR)
# Critical for hold analysis with different early/late parasitics
######################################################################
set_app_options -name time.remove_clock_reconvergence_pessimism -value true


######################################################################
# Apply Timing Constraints
######################################################################
source ../scripts/constraints/timing.tcl


######################################################################
# Apply Physical Constraints
######################################################################
source ../scripts/constraints/physical.tcl


######################################################################
# Check Design
######################################################################
report_ref_libs


######################################################################
# Save Initial Design
######################################################################
save_block -as ${DESIGN_NAME}_initial
save_lib
