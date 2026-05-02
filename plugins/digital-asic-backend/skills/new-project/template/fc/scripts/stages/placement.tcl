######################################################################
# Placement Optimization
######################################################################


######################################################################
# Open Design — copy from synthesis so the source checkpoint stays clean
######################################################################
if {[sizeof_collection [get_blocks -quiet ${DESIGN_NAME}_placement]] > 0} {
    remove_block -force [get_blocks ${DESIGN_NAME}_placement]
}
copy_block -from ${DESIGN_NAME}_synthesis -to ${DESIGN_NAME}_placement
open_block ${DESIGN_NAME}_placement


######################################################################
# Placement Options
######################################################################
set_app_options -name opt.timing.effort         -value high
set_app_options -name opt.area.effort           -value high
set_app_options -name place_opt.flow.enable_power -value true


######################################################################
# Place Optimization
######################################################################
place_opt

report_congestion
redirect -tee -file ../report/placement_timing.rpt {report_timing}
redirect -tee -file ../report/placement_qor.rpt   {report_qor}


######################################################################
# Save Placement
######################################################################
save_block
save_lib
