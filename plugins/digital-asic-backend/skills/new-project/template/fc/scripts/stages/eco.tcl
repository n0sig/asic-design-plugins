######################################################################
# ECO Flow (Incremental — do NOT re-run full synthesis/PnR)
# Opens DFM checkpoint, applies PT ECO changes, re-routes, re-fills
######################################################################

######################################################################
# Open DFM Checkpoint
######################################################################
open_block ${DESIGN_NAME}_dfm


######################################################################
# Remove Filler Cells
######################################################################
remove_cells [get_cells -hierarchical -filter design_type==filler]


######################################################################
# Apply ECO Changes from PrimeTime
######################################################################
source ../scripts/eco_changes.tcl


######################################################################
# Legalize Placement
######################################################################
legalize_placement -incremental


######################################################################
# Incremental Routing
######################################################################
route_detail -incremental true
route_eco


######################################################################
# Re-add Filler Cells
######################################################################
set FILLER_CELLS [get_lib_cells "*/FILL64 */FILL32 */FILL16 */FILL8 */FILL4 */FILL2 */FILL1"]
create_stdcell_fillers -lib_cells $FILLER_CELLS
connect_pg_net -automatic


######################################################################
# DRC and LVS Check
######################################################################
check_routes
check_lvs

redirect -tee -file ../report/dfm_drc.rpt {check_routes}
redirect -tee -file ../report/dfm_lvs.rpt {check_lvs}


######################################################################
# Save Updated DFM
######################################################################
save_block -as ${DESIGN_NAME}_dfm
save_lib


######################################################################
# Write Outputs
######################################################################
write_verilog -exclude {pg_objects end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells} \
    ${PROJECT_PATH}/fc/output/${DESIGN_NAME}_pt.v

write_verilog -exclude {end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells} \
    ${PROJECT_PATH}/fc/output/${DESIGN_NAME}_lvs.v

write_sdc -output ${PROJECT_PATH}/fc/output/${DESIGN_NAME}.sdc

write_gds ${PROJECT_PATH}/fc/output/${DESIGN_NAME}.gds \
    -keep_data_type \
    -long_names

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
echo "ECO flow completed for ${DESIGN_NAME}"
echo "Output files in: ${PROJECT_PATH}/fc/output/"
echo "\n=================================================================="
