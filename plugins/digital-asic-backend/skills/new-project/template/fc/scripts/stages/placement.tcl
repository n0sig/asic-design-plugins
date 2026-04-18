######################################################################
# Placement Optimization
######################################################################


######################################################################
# Open Design
######################################################################
open_block ${DESIGN_NAME}_synthesis


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
save_block -as ${DESIGN_NAME}_placement
save_lib
