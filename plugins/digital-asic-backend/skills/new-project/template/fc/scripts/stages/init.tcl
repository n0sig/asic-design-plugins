######################################################################
# Design Setup — Read RTL, Elaborate, Apply Constraints
######################################################################


######################################################################
# Read and Elaborate RTL
######################################################################
# Read all SystemVerilog sources listed in hdl/filelist.f.
# -F resolves relative paths inside the filelist relative to the
#    filelist's own directory (hdl/), so entries like "top.sv" or
#    "sub/block.sv" work without any absolute path prefix.
# Create an empty filelist if one does not already exist so that
# subsequent steps fail with a clear error rather than a tool crash.

set _filelist "${PROJECT_PATH}/hdl/filelist.f"
if {![file exists $_filelist]} {
    set _fh [open $_filelist w]
    puts $_fh "// VCS filelist — add your SystemVerilog source files below."
    puts $_fh "// Paths are relative to this file's directory (hdl/)."
    puts $_fh "// Example:"
    puts $_fh "//   top.sv"
    puts $_fh "//   sub/block.sv"
    puts $_fh "//   +incdir+include"
    close $_fh
    puts "WARNING: hdl/filelist.f was missing and has been created as an empty placeholder."
    puts "WARNING: Populate ${_filelist} with your RTL files and re-run."
}
analyze -vcs "-sverilog -F ${_filelist}"

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
