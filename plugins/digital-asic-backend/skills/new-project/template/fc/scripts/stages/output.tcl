######################################################################
# Open Design
######################################################################
open_block ${DESIGN_NAME}_dfm


######################################################################
# Write Verilog for PrimeTime
######################################################################
write_verilog -exclude {pg_objects end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells} \
    ${PROJECT_PATH}/fc/output/${DESIGN_NAME}_pt.v


######################################################################
# Write Verilog for LVS (with PG pins)
######################################################################
write_verilog -exclude {end_cap_cells well_tap_cells filler_cells pad_spacer_cells cover_cells} \
    ${PROJECT_PATH}/fc/output/${DESIGN_NAME}_lvs.v


######################################################################
# Write SDC
######################################################################
write_sdc -output ${PROJECT_PATH}/fc/output/${DESIGN_NAME}.sdc


######################################################################
# Write GDS
######################################################################
write_gds ${PROJECT_PATH}/fc/output/${DESIGN_NAME}.gds \
    -keep_data_type \
    -long_names


######################################################################
# Write DEF
######################################################################
write_def ${PROJECT_PATH}/fc/output/${DESIGN_NAME}.def


######################################################################
# Final Reports
######################################################################
redirect -tee -file ../report/final_timing.rpt {report_timing -delay_type max}
redirect -tee -file ../report/final_timing_hold.rpt {report_timing -delay_type min}
redirect -tee -file ../report/final_qor.rpt {report_qor}
redirect -tee -file ../report/final_area.rpt {report_design -all}
redirect -tee -file ../report/final_power.rpt {report_power}


echo "\n=================================================================="
echo "Fusion Compiler flow completed for ${DESIGN_NAME}"
echo "Output files in: ${PROJECT_PATH}/fc/output/"
echo "\n=================================================================="
