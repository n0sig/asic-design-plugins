SHELL := /bin/csh -f

.PHONY: all run clean

all: run

run:
	mkdir -p report
	mkdir -p result
	mkdir -p work
	mkdir -p temp
	cd temp && pt_shell -multi_scenario -f ../scripts/dmsa.tcl | tee dmsa.log

clean:
	rm -rf report
	rm -rf result
	rm -rf work
	rm -rf temp
