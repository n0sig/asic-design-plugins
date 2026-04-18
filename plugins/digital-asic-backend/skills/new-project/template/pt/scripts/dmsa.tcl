source ../scripts/setup.tcl

# eco_enable_more_scenarios_than_hosts was obsoleted in PT 2021.06
set multi_scenario_working_directory ${WORKING_DIR}
set multi_scenario_merged_error_log ${WORKING_DIR}/error_log.txt
set_host_options -num_processes $dmsa_num_of_hosts -max_cores 32

#set_multi_scenario_license_limit -feature PrimeTime $dmsa_num_of_licenses
#set_multi_scenario_license_limit -feature PrimeTime-SI $dmsa_num_of_licenses

if {1} {
	foreach mode $dmsa_modes {
		foreach corner $dmsa_corners {
			echo "$mode $corner"
			create_scenario \
				-name ${mode}_${corner} \
				-specific_variables {mode corner} \
				-specific_data "../scripts/setup.tcl ../scripts/dmsa_con.tcl"
		}
	}
} \
else {
	foreach mode $dmsa_modes {
		foreach corner $dmsa_corners {
			echo "$mode $corner"
			create_scenario \
				-name ${mode}_${corner} \
				-image ${WORKING_DIR}/${mode}_${corner}/${DESIGN_NAME}
		}
	}
}

start_hosts
current_session -all

source ../scripts/dmsa_analysis.tcl
