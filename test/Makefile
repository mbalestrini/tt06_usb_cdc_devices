PROJ = tt_um_mbalestrini_usb_cdc_devices
IN_DIR = ../build/input
OUT_DIR = output

# Testbench HDL files
TB_HDL_FILES = \
	tb_src_files/usb_monitor.v \
	tb_tt_um_mbalestrini_usb_cdc_devices.v

INC_DIRS = -Itb_src_files

ifneq ($(GATES),yes)

INC_DIRS += -I../src -I../src/device0 -I../src/usb_cdc

VERILOG_SRC_FILES = \
	../src/tt_um_mbalestrini_usb_cdc_devices.v \
	../src/usb_cdc_devices.v \
	../src/prescaler.v \
	../src/device0/arcade_io_device.v \
	../src/device0/input_debouncer.v \
	../src/device1/loopback_device.v \
	../src/usb_cdc/*.v


else

INC_DIRS += -I$(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog

COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DUSE_POWER_PINS
COMPILE_ARGS    += -DSIM
COMPILE_ARGS    += -DUNIT_DELAY=\#1


VERILOG_SRC_FILES = gate_level_netlist.v
VERILOG_SRC_FILES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SRC_FILES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v
	

endif 
	
	
# list of HDL files directories separated by ":"
VPATH = tb_src_files: \
    
all: sim

$(OUT_DIR):
	mkdir -p $@

$(OUT_DIR)/%.vvp: $(VERILOG_SRC_FILES) $(TB_HDL_FILES) | $(OUT_DIR)
	iverilog $(COMPILE_ARGS) -g2001 -t vvp -s tb_$(PROJ) $(INC_DIRS) -o $@ $^	

$(OUT_DIR)/%.fst: $(OUT_DIR)/%.vvp
	rm -f results.xml
	vvp -N $< -fst && mv tb.dump $@ 
	echo '<testsuites name="results"><testsuite name="all"><testcase name="test_project"/></testsuite></testsuites>' > results.xml

sim: $(OUT_DIR)/$(PROJ).fst

$(OUT_DIR)/%.xml: $(VERILOG_SRC_FILES) $(TB_HDL_FILES) | $(OUT_DIR)
	verilator --no-timing -xml-only --bbox-unsup --bbox-sys -Wno-lint -Wno-MULTIDRIVEN -Wno-TIMESCALEMOD -Wno-STMTDLY -Wno-INFINITELOOP -DBLACKBOX -DNO_ICE40_DEFAULT_ASSIGNMENTS --top tb_$(PROJ) $(INC_DIRS) $^ --xml-output $@

$(OUT_DIR)/%.stems: $(OUT_DIR)/%.xml
	xml2stems $< $@

wave: $(OUT_DIR)/$(PROJ).stems $(OUT_DIR)/$(PROJ).fst
	gtkwave --autosavename --saveonexit --tcl_init=tb_src_files/gtkwave/procs.tcl --wish --stems $^ --rcvar 'do_initial_zoom_fit yes' --rcvar 'splash_disable yes'

$(OUT_DIR)/%.fst: $(OUT_DIR)/tb.dump
	vcd2fst $<  $@

fst: $(OUT_DIR)/$(PROJ).stems $(OUT_DIR)/tb.fst
	gtkwave --autosavename --saveonexit --tcl_init=tb_src_files/gtkwave/procs.tcl --wish --stems $^ --rcvar 'do_initial_zoom_fit yes' --rcvar 'splash_disable yes'


wave_gl: $(OUT_DIR)/$(PROJ).fst
	gtkwave --saveonexit --wish --rcvar 'do_initial_zoom_fit yes' --rcvar 'splash_disable yes' $^ tb_src_files/gtkwave/gl.gtkw

clean:
	rm -rf $(OUT_DIR)
