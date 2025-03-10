#top file
TOP = dv/uart_echo_tb
SIM_OUT = obj_dir/uart_echo_tb.out
WAVE = dump.vcd

#tools
#VERILATOR := /workspaces/cse293uart_hw1/verilator/bin/verilator
VERILATOR=utils/oss-cad-suite/bin/verilator

#paths
THIRD_PARTY_DIR = third_party

#files reqired
RTL_FILES = $(shell cat rtl/rtl.f)
TB_FILES = $(shell cat dv/dv.f)

#all rule
all: $(SIM_OUT)

#compile rule
$(SIM_OUT): $(RTL_FILES) $(TB_FILES)
#	@echo "Running Verilator with files:"
#	@echo "RTL Files: $(RTL_FILES)"
#	@echo "TB Files: $(TB_FILES)"
	$(VERILATOR) --binary --Wno-fatal \
		-I$(THIRD_PARTY_DIR)/alexforencich_uart \
		-f rtl/rtl.f -f dv/dv.f -f dv/verilator_options.f \
		$(RTL_FILES) $(TB_FILES) \
		--top-module uart_echo_tb

#run rule
#run: $(SIM_OUT)
#	./$(SIM_OUT)

#waveform rule
wave: $(WAVE)
	gtkwave $(WAVE)

#clean rule
clean:
	rm -rf obj_dir *.vcd $(SIM_OUT)
