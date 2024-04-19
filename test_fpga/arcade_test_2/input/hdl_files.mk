# HDL files
HDL_FILES = \
phy_tx.v \
phy_rx.v \
sie.v \
ctrl_endp.v \
in_fifo.v \
out_fifo.v \
bulk_endp.v \
usb_cdc.v \
prescaler.v \
arcade_test_2.v \
usb_cdc_devices.v \
arcade_io_device.v \
input_debouncer.v \
loopback_device.v \


# Testbench HDL files
TB_HDL_FILES = \
SB_PLL40_CORE.v \
usb_monitor.v \
tb_arcade_test_1.v \

# list of HDL files directories separated by ":"
VPATH = ../src: \
        ../src/device0: \
        ../src/device1: \
        ../src/usb_cdc: \
        arcade_test_2: \
        common/hdl: \
        common/hdl/ice40: \

