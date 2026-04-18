######################################################################
# Open Design
######################################################################
open_block ${DESIGN_NAME}_clocktree


######################################################################
# Routing Options
######################################################################
set_app_options -name route.detail.optimize_wire_via_effort_level -value high
set_app_options -name route.detail.insert_diodes_during_routing -value true


######################################################################
# Antenna Rules
######################################################################
source ../scripts/constraints/antenna_rules.tcl


######################################################################
# Auto Route (global + track + detail)
######################################################################
route_auto


######################################################################
# Post-Route Optimization (setup + hold + power)
######################################################################
# After actual wire RC is extracted, cells kept large for SI/DRC margin
# can be downsized.  This is the last opportunity for leakage recovery.
set_app_options -name route_opt.flow.enable_power -value true

route_opt


######################################################################
# Incremental Detail Route Fix
######################################################################
route_detail -incremental true
route_eco


######################################################################
# Reports
######################################################################
redirect -tee -file ../report/route_timing.rpt {report_timing -delay_type max}
redirect -tee -file ../report/route_timing_hold.rpt {report_timing -delay_type min}
redirect -tee -file ../report/route_qor.rpt {report_qor}
redirect -tee -file ../report/route_drc.rpt {report_design -all}

check_routes
check_lvs


######################################################################
# Save Route
######################################################################
save_block -as ${DESIGN_NAME}_route
save_lib
