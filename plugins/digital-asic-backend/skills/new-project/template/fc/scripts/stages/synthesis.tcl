######################################################################
# Fusion Compiler Synthesis + Placement
######################################################################


######################################################################
# Open Design
######################################################################
open_block ${DESIGN_NAME}_floorplan


######################################################################
# Synthesis Options
######################################################################
set_fix_multiple_port_nets -all -buffer_constants
set_app_var timing_enable_multiple_clocks_per_reg true

# Set optimization effort BEFORE compile_fusion so synthesis itself
# benefits from high power/area effort (not just place_opt).
set_app_options -name opt.timing.effort -value high
set_app_options -name opt.area.effort   -value high


######################################################################
# Use non-scan ICG cells (smaller, less capacitance) for clock gating.
# Raise min bitwidth to reduce ICG count → fewer CTS buffers.
######################################################################
set_clock_gate_style -test_point none
set_clock_gating_options -minimum_bitwidth 6


######################################################################
# Compile Fusion (unified synthesis + placement)
######################################################################
set_app_options -name compile.flow.enable_power -value true

compile_fusion -spg -gate_clock

redirect -tee -file ../report/timing_synthesis.rpt {report_timing}
redirect -tee -file ../report/qor_synthesis.rpt {report_qor}
redirect -tee -file ../report/power_synthesis.rpt {report_power}

save_block -as ${DESIGN_NAME}_synthesis
save_lib
