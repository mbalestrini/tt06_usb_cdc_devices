PROJ = tt_um_mbalestrini_usb_cdc_devices
IN_DIR = build/input
OUT_DIR = build/output

# VERILOG_SRC_FILES:
include $(IN_DIR)/src_files.mk


synth: $(OUT_DIR)/$(PROJ).json

$(OUT_DIR):
	mkdir -p $@

$(OUT_DIR)/%.json: $(VERILOG_SRC_FILES) | $(OUT_DIR)
	yosys -l $(OUT_DIR)/log_yosys_$(PROJ).txt -p '$(foreach file,$^,read_verilog $(file);)' -p 'synth -top $(PROJ); write_json $@'
	
lint: $(VERILOG_SRC_FILES) | $(OUT_DIR)
	verilator --lint-only --waiver-output $(OUT_DIR)/waivers_$(PROJ).vlt -Wall -Wno-UNUSED -Wno-UNDRIVEN -Wno-TIMESCALEMOD --top-module $(PROJ) $^
	# verilator --lint-only -Wall --top-module $(PROJ) $^

lint_with_waivers: $(VERILOG_SRC_FILES) | $(OUT_DIR)
	verilator --lint-only --waiver-output $(OUT_DIR)/waivers_$(PROJ).vlt -Wall -Wno-UNUSED -Wno-UNDRIVEN -Wno-TIMESCALEMOD --top-module $(PROJ) $(IN_DIR)/temp_lint_waiver.vlt $^


synth_interactive: $(VERILOG_SRC_FILES) | $(OUT_DIR)
	yosys -l $(OUT_DIR)/log_yosys_interactive_$(PROJ).txt -p '$(foreach file,$^,read_verilog $(file);)' -p 'hierarchy -top $(PROJ)' -p 'shell'
	
# synth_interactive_liberty:
# 	yosys -l $(OUT_DIR)/log_yosys_interactive_$(PROJ).txt -p '$(foreach file,$^,read_verilog $(file);)' -p 'synth; stat -liberty $(PDK_ROOT)/$(PDK)/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib' -p 'shell'

formal_arcade_io_device:
	sby --prefix $(OUT_DIR)/task -f $(IN_DIR)/arcade_io_device.sby

show_formal_arcade_io_device_cover:
	gtkwave $(OUT_DIR)/task_task_cover/engine_0/trace0.vcd $(IN_DIR)/formal_arcade_io_device.gtkw 

show_formal_arcade_io_device_prove:
	gtkwave $(OUT_DIR)/task_task_prove/engine_0/trace.vcd $(IN_DIR)/formal_arcade_io_device.gtkw

clean:
	rm -rf $(OUT_DIR)