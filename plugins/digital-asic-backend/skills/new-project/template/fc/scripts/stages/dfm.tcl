######################################################################
# Open Design — copy from route so the source checkpoint stays clean
######################################################################
if {[sizeof_collection [get_blocks -quiet ${DESIGN_NAME}_dfm]] > 0} {
    remove_block -force [get_blocks ${DESIGN_NAME}_dfm]
}
copy_block -from ${DESIGN_NAME}_route -to ${DESIGN_NAME}_dfm
open_block ${DESIGN_NAME}_dfm


######################################################################
# Redundant Vias Insertion
######################################################################
add_redundant_vias


######################################################################
# Wire Spreading and Widening (reduce critical area)
######################################################################
spread_wires
widen_wires


######################################################################
# Insert Filler Cells
######################################################################
set FILLER_CELLS [get_lib_cells "*/FILL64 */FILL32 */FILL16 */FILL8 */FILL4 */FILL2 */FILL1"]
create_stdcell_fillers -lib_cells $FILLER_CELLS


######################################################################
# Reconnect PG
######################################################################
connect_pg_net -automatic


######################################################################
# DRC and LVS Check
######################################################################
check_routes
check_lvs

redirect -tee -file ../report/dfm_drc.rpt {check_routes}
redirect -tee -file ../report/dfm_lvs.rpt {check_lvs}


######################################################################
# Save DFM
######################################################################
save_block
save_lib
