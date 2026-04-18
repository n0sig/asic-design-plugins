.PHONY: all clean init floorplan synthesis placement clocktree routing dfm output eco

DIRS = scripts report output temp

all:
	mkdir -p $(DIRS)
	cd temp && fc_shell -f ../scripts/flows/run_full.tcl | tee ../report/run_fc.log

init:
	mkdir -p $(DIRS)
	cd temp && fc_shell -f ../scripts/flows/run_init.tcl | tee ../report/run_init.log

floorplan:
	mkdir -p $(DIRS)
	cd temp && fc_shell -f ../scripts/flows/run_floorplan.tcl | tee ../report/run_floorplan.log

synthesis:
	mkdir -p $(DIRS)
	cd temp && fc_shell -f ../scripts/flows/run_synthesis.tcl | tee ../report/run_synthesis.log

placement:
	mkdir -p $(DIRS)
	cd temp && fc_shell -f ../scripts/flows/run_placement.tcl | tee ../report/run_placement.log

clocktree:
	mkdir -p $(DIRS)
	cd temp && fc_shell -f ../scripts/flows/run_clocktree.tcl | tee ../report/run_clocktree.log

routing:
	mkdir -p $(DIRS)
	cd temp && fc_shell -f ../scripts/flows/run_routing.tcl | tee ../report/run_routing.log

dfm:
	mkdir -p $(DIRS)
	cd temp && fc_shell -f ../scripts/flows/run_dfm.tcl | tee ../report/run_dfm.log

output:
	mkdir -p $(DIRS)
	cd temp && fc_shell -f ../scripts/flows/run_output.tcl | tee ../report/run_output.log

eco:
	mkdir -p $(DIRS)
	cd temp && fc_shell -f ../scripts/flows/run_eco.tcl | tee ../report/run_eco.log

clean:
	rm -rf report output temp
