#top file
TOP = dv/uart_echo_tb
SIM_OUT = obj_dir/uart_echo_tb.out
WAVE = dump.vcd

#tools
VERILATOR = verilator

#paths
THIRD_PARTY_DIR = third_party

#files reqired
RTL_FILES = $(shell cat rtl/rtl.f)
TB_FILES = $(shell cat dv/dv.f)

#all rule
all: $(SIM_OUT)

#compile rule
#-cc to geenrate cpp file
#-exe to make verilator generate executable
$(SIM_OUT): $(RTL_FILES) $(TB_FILES) ./dv/uart_echo_tb.cpp
	@echo "Running Verilator with files:"
	@echo "RTL Files: $(RTL_FILES)"
	@echo "TB Files: $(TB_FILES)"
	$(VERILATOR) --cc --exe --sv -Wno-fatal --debug --trace \
		-I$(THIRD_PARTY_DIR)/alexforencich_uart \
		-f rtl/rtl.f -f dv/dv.f -f dv/verilator_options.f \
		./dv/uart_echo_tb.cpp -o $(SIM_OUT)


#run rule
run: $(SIM_OUT)
	./$(SIM_OUT)

#waveform rule
wave: $(WAVE)
	gtkwave $(WAVE)

#clean rule
clean:
	rm -rf obj_dir *.vcd $(SIM_OUT)
