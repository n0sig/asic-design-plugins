###################################
# Constraints file for design
# TODO: Define clock and I/O timing constraints
###################################
# set CLK_PERIOD "10"
#
# create_clock -period $CLK_PERIOD -name clk -waveform [list 0 [expr {$CLK_PERIOD/2.0}]] [get_ports clk]
# set_clock_latency -source -max [expr {0.005*$CLK_PERIOD}] [get_clocks clk]
# set_clock_latency -max [expr {0.005*$CLK_PERIOD}] [get_clocks clk]
#
# set_input_delay [expr {0.1*$CLK_PERIOD}] -clock clk [all_inputs]
# set_output_delay -max [expr {0.2*$CLK_PERIOD}] -clock clk [all_outputs]
# set_output_delay -min 0.5 -clock clk [all_outputs]
#
# set_input_transition -max 0.1 [remove_from_collection [all_inputs] [get_ports clk]]
# set_load 0.04 [all_outputs]
#
# set_ideal_network [get_ports clk]
