set DESIGN_NAME "__DESIGN_NAME__"
set LIBRARY_PATH "__LIBRARY_PATH__"
set PROJECT_PATH "__PROJECT_PATH__"
set RCPATH       "${PROJECT_PATH}/starrc"
set REPORTS_DIR  "${PROJECT_PATH}/pt/report"
set WORKING_DIR  "${PROJECT_PATH}/pt/work"
set NETLIST_FILE "${PROJECT_PATH}/fc/output/${DESIGN_NAME}_pt.v"
set OUTPUT_NAME  "eco_changes.tcl"
set RESULTS_DIR  "${PROJECT_PATH}/fc/scripts"


set all_stdcel_libs(tt) "
__DB_TT_FULL_PATH__
"
set all_stdcel_libs(ss) "
__DB_SS_FULL_PATH__
"

set target_library ""
set link_library   "*"
foreach x [array names all_stdcel_libs] {
	set target_library "$target_library $all_stdcel_libs($x)"
}
set link_library   "$link_library $target_library"

set report_default_significant_digits 3
set sh_source_uses_search_path true
set dmsa_num_of_hosts         "4"
set dmsa_num_of_licenses      "16"

set dmsa_modes {func}
set dmsa_corners {tt_cmax tt_cmin ss_cmax ss_cmin}

foreach sc "tt ss" {
	set dmsa_corner_library_files($sc) "$all_stdcel_libs($sc)"
}

set dmsa_mode_constraint_files(func) "${PROJECT_PATH}/fc/output/${DESIGN_NAME}.sdc"

set PARASITIC_PATHS(tt_cmax) "$RCPATH/spef/cmax_25c.spef"
set PARASITIC_PATHS(tt_cmin) "$RCPATH/spef/cmin_25c.spef"
set PARASITIC_PATHS(ss_cmax) "$RCPATH/spef/cmax_125c.spef"
set PARASITIC_PATHS(ss_cmin) "$RCPATH/spef/cmin_125c.spef"
