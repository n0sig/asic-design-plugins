SHELL := /bin/csh -f

.PHONY: all run clean

all: run

run:
	mkdir -p spef
	mkdir -p temp
	cd temp && \
	StarXtract -clean ../scripts/extract_cmax_25c.cmd && \
	StarXtract -clean ../scripts/extract_cmax_125c.cmd && \
	StarXtract -clean ../scripts/extract_cmin_25c.cmd && \
	StarXtract -clean ../scripts/extract_cmin_125c.cmd

clean:
	rm -rf spef
	rm -rf temp
