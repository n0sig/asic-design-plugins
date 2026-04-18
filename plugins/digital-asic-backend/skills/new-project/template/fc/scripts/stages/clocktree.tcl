######################################################################
# Open Design
######################################################################
open_block ${DESIGN_NAME}_placement


######################################################################
# Prepare for CTS: remove synthesis-time clock constraints
######################################################################
remove_clock_uncertainty [all_clocks]
remove_clock_latency [all_clocks]
remove_ideal_network [get_ports clk]
set_propagated_clock [all_clocks]


######################################################################
# Give non-scan ICG cells CTS purpose so CTS can resize them,
# potentially eliminating the need for extra clock-tree buffers.
######################################################################
set_lib_cell_purpose -include cts [get_lib_cells */TLATNCAX*]


######################################################################
# Clock Tree Synthesis
######################################################################
synthesize_clock_trees
check_clock_trees

redirect -tee -file ../report/timing_cts.rpt {report_timing}


######################################################################
# Clock Optimization (includes hold fixing)
######################################################################
# After propagated clock latency is known, cells sized for ideal-clock
# timing often have extra slack.  Power recovery exploits that slack
# to downsize cells and reduce leakage.
set_app_options -name clock_opt.flow.enable_power -value true

clock_opt

redirect -tee -file ../report/timing_clock_opt.rpt {report_timing}
redirect -tee -file ../report/timing_clock_opt_hold.rpt {report_timing -delay_type min}


######################################################################
# Save Clock Tree
######################################################################
save_block -as ${DESIGN_NAME}_clocktree
save_lib
