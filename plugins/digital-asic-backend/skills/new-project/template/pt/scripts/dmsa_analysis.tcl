##################################################################
#    Update_timing and check_timing Section                      #
##################################################################
remote_execute {
    update_timing -full
    #check_timing -verbose > $REPORTS_DIR/${DESIGN_NAME}_check_timing.report
}

##################################################################
#    Save_Session Section                                        #
##################################################################
remote_execute {
    save_session ${DESIGN_NAME}
}

report_constraint -all_violators -sign 4 > ${REPORTS_DIR}/${DESIGN_NAME}_allvios.rpt

remote_execute {
    report_constraint -all_violators -sign 4 > ${REPORTS_DIR}/${DESIGN_NAME}_curvios.rpt
}

##################################################################
#    Report_timing Section                                       #
##################################################################
#report_timing -crosstalk_delta -slack_lesser_than 0.0 -pba_mode exhaustive -delay min_max -nosplit -input -net -sign 4 > $REPORTS_DIR/${DESIGN_NAME}_dmsa_report_timing_pba.report
#report_analysis_coverage > $REPORTS_DIR/${DESIGN_NAME}_dmsa_report_analysis_coverage.report

# Noise Reporting
remote_execute {
    set_noise_parameters -enable_propagation
    check_noise
    update_noise

    report_noise -nosplit -all_violators -above -low  > $REPORTS_DIR/${DESIGN_NAME}_report_noise_all_viol_abv_low.report
    report_noise -nosplit -nworst 10     -above -low  > $REPORTS_DIR/${DESIGN_NAME}_report_noise_alow.report
    report_noise -nosplit -all_violators -below -high > $REPORTS_DIR/${DESIGN_NAME}_report_noise_all_viol_below_high.report
    report_noise -nosplit -nworst 10     -below -high > $REPORTS_DIR/${DESIGN_NAME}_report_noise_below_high.report
}

##################################################################
#    Fix ECO DRC Section                                         #
##################################################################
set eco_drc_buf_list {
    BUFX2 BUFX3 BUFX4 BUFX8 BUFX12 BUFX16 BUFX20
}
set eco_hold_buf_list {
    BUFX2 BUFX3 BUFX4 BUFX8 BUFX12 BUFX16 BUFX20
}

fix_eco_drc -type max_transition  -method {size_cell}                -verbose
fix_eco_drc -type max_capacitance -method {size_cell}                -verbose
fix_eco_drc -type max_transition  -method {size_cell insert_buffer}  -verbose -buffer_list $eco_drc_buf_list
fix_eco_drc -type max_capacitance -method {size_cell insert_buffer}  -verbose -buffer_list $eco_drc_buf_list

fix_eco_timing -type setup -methods {size_cell}                               -slack_lesser_than -0.01
fix_eco_timing -type hold  -methods {size_cell insert_buffer} -buffer_list $eco_hold_buf_list -slack_lesser_than -0.01

report_constraints -all_violators > ${REPORTS_DIR}/${DESIGN_NAME}_fix_all_vios.report

current_scenario
remote_execute {
    write_changes -format icctcl -output ${RESULTS_DIR}/${OUTPUT_NAME}
}
