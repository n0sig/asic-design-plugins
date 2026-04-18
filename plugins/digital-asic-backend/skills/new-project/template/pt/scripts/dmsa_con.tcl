set timing_report_use_worst_parallel_cell_arc true
set pba_exhaustive_endpoint_path_limit 100
set si_enable_analysis true
set si_xtalk_double_switching_mode clock_network
set timing_remove_clock_reconvergence_pessimism true

set select_dmsa_corner_libs ""
set c [lindex [split $corner _] 0]
foreach dml $dmsa_corner_library_files($c) {
    lappend select_dmsa_corner_libs $dml
}

echo "select_dmsa_corner_libs $select_dmsa_corner_libs"

set link_path "* $select_dmsa_corner_libs"

read_verilog $NETLIST_FILE
current_design $DESIGN_NAME
link -remove_sub_designs

read_parasitics -keep_capacitive_coupling -format spef $PARASITIC_PATHS($corner)

report_annotated_parasitics -check > $REPORTS_DIR/${DESIGN_NAME}_report_annotated_parasitics_${corner}.report

# Filter out VDD/VSS power-port constraints from FC-exported SDC
# (power ports are stripped from the _pt.v netlist)
set sdc_file $dmsa_mode_constraint_files($mode)
set filtered_sdc "${WORKING_DIR}/filtered_${mode}_${corner}.sdc"
set fin  [open $sdc_file r]
set fout [open $filtered_sdc w]
while {[gets $fin line] >= 0} {
    if {[regexp {get_ports\s+\{?(VDD|VSS)\}?} $line]} { continue }
    puts $fout $line
}
close $fin
close $fout
source $filtered_sdc
set_propagated_clock [all_clocks]

# TODO: Add design-specific clock gating check disables if needed
# Example: set_disable_clock_gating_check [get_cells u_xxx/u_gated_clk]

suppress_message UITE-216
group_path -name in2reg  -from [all_inputs]                -to [all_registers -data_pin]
group_path -name reg2out -to   [all_outputs]               -from [all_registers -clock_pin]
group_path -name reg2reg -from [all_registers -clock_pin]  -to [all_registers -data_pin]
unsuppress_message UITE-216
