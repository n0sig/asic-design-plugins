.PHONY:com sim clean
export PROJECT_PATH=__PROJECT_PATH__
export OUTPUT=top

VCS = vcs -full64 -sverilog +v2k -timescale=1ns/1ns                     \
	  -debug_acc+all+dmptf -debug_region+cell+encrypt		\
	  -o ${OUTPUT}							\
	  -l compile.log						\
	  +lint=TFIPC-L							\
	  +memcbk								\
	  +dumparrays							\
      -R   									\
	  +neg_tchk								\
	  -negdelay								\
	  -debug_access

SIM = ./${OUTPUT} -l run.log

com:
	${VCS} -f ${PROJECT_PATH}/hdl/verilog_file_post.f

sim:
	${SIM}

clean:
	rm -rf ./csrc *.daidir *.log simv* *.key *.vcd *.vpd *.fsdb *.dump top
