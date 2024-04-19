`timescale 1 ns/10 ps  // time-unit/precision
`define BIT_TIME (1000/12)
`define CLK_PER (1000/48)

module tb_tt_um_mbalestrini_usb_cdc_devices ( );
`define USB_CDC_INST tb_tt_um_mbalestrini_usb_cdc_devices.u_dut.u_usb_cdc_devices.u_usb_cdc

   localparam MAX_BITS = 128;
   localparam MAX_BYTES = 128*CHANNELS;
   localparam MAX_STRING = 128;

   reg        dp_force;
   reg        dn_force;
   reg        power_on;
   reg [8*MAX_STRING-1:0] test;

   wire                   dp_sense;
   wire                   dn_sense;

   integer                errors;
   integer                warnings;
   integer                i;
   integer                test_frame_num;

   localparam             IN_BULK_MAXPACKETSIZE = 'd8;
   localparam             OUT_BULK_MAXPACKETSIZE = 'd8;
   localparam             VENDORID = 16'h0000;
   localparam             PRODUCTID = 16'h0000;

// `include "usb_test_1ch.v"
`include "usb_test_2ch.v"

   `progress_bar(test, 37)

   reg                    clk;

   initial begin
      clk = 0;
   end

   always @(clk or power_on) begin
      if (power_on | clk)
        #(`CLK_PER/2) clk <= ~clk;
   end

   wire led;
   wire usb_p;
   wire usb_n;
   wire usb_pu;

   // TT module pins
   wire [7:0] ui_in;    // Dedicated inputs
   wire [7:0] uo_out;   // Dedicated outputs
   wire [7:0] uio_in;   // IOs: Input path
   wire [7:0] uio_out;  // IOs: Output path
   wire [7:0] uio_oe;   // IOs: Enable path (active high: 0=input, 1=output)
   reg       ena;      // will go high when the design is enabled
   reg       rst_n;     // reset_n - low to reset

   reg [7:0] device_inputs;

   wire usb_dp_pu; // USB 1.5kOhm Pullup EN
   wire usb_dp_tx; // USB+
   wire usb_dp_rx; // USB+
   wire usb_dn_tx; // USB-
   wire usb_dn_rx; // USB-
   wire usb_tx_en;

   assign usb_dp_pu = uo_out[0];
   assign usb_dp_tx = uio_out[0];
   assign uio_in[0] = usb_dp_rx;   
   assign usb_dn_tx = uio_out[1];
   assign uio_in[1] = usb_dn_rx;
   assign usb_tx_en = uio_oe[0];

   assign usb_p = usb_tx_en ? usb_dp_tx : 1'bz;
   assign usb_n = usb_tx_en ? usb_dn_tx : 1'bz;

   assign usb_dp_rx = usb_p;
   assign usb_dn_rx = usb_n;
   assign usb_pu = usb_dp_pu;

   assign led = uo_out[1];

   assign ui_in = device_inputs;
   
   tt_um_mbalestrini_usb_cdc_devices   u_dut (
   `ifdef GL_TEST
      .VPWR(1'b1),
      .VGND(1'b0),
   `endif
      .ui_in(ui_in),    // Dedicated inputs
      .uo_out(uo_out),   // Dedicated outputs
      .uio_in(uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe(uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena(ena),      // will go high when the design is enabled
      .clk(clk),      // clock
      .rst_n(rst_n)     // reset_n - low to reset
   );

   // loopback u_loopback (.clk(clk),
   //                      .led(led),
   //                      .usb_p(usb_p),
   //                      .usb_n(usb_n),
   //                      .usb_pu(usb_pu));

   assign usb_p = dp_force;
   assign usb_n = dn_force;

   // assign usb_p = ~usb_tx_en ? dp_force : usb_dp_tx;
   // assign usb_n = ~usb_tx_en ? dn_force : usb_dn_tx;

   assign (pull1, highz0) usb_p = usb_pu; // 1.5kOhm device pull-up resistor
   //pullup (usb_p); // to speedup simulation don't wait for usb_pu

   //pulldown (weak0) dp_pd (usb_p), dn_pd (usb_n); // 15kOhm host pull-down resistors
   assign (highz1, weak0) usb_p = 1'b0; // to bypass verilator error on above pulldown
   assign (highz1, weak0) usb_n = 1'b0; // to bypass verilator error on above pulldown

   assign dp_sense = usb_p;
   assign dn_sense = usb_n;

   `ifndef GL_TEST
   usb_monitor #(.MAX_BITS(MAX_BITS),
                 .MAX_BYTES(MAX_BYTES))
   u_usb_monitor (.usb_dp_i(dp_sense),
                  .usb_dn_i(dn_sense));
   `endif 

   
   reg [6:0] address;
   reg [15:0] datain_toggle;
   reg [15:0] dataout_toggle;

   initial begin : u_host
      $timeformat(-6, 3, "us", 3);
      $dumpfile("tb.dump");
      $dumpvars;

      device_inputs = 8'b0;
      test = "MAIN RESET";
      rst_n = 1'b0;
      ena = 1'b0;
      #(10*`CLK_PER);
      test = "ENABLE PROJECT";
      ena = 1'b1;
      #(10*`CLK_PER);
      rst_n = 1'b1;


      power_on = 1'b1;
      dp_force = 1'bZ;
      dn_force = 1'bZ;
      errors = 0;
      warnings = 0;
      address = 'd0;
      dataout_toggle = 'd0;
      datain_toggle = 'd0;
      test = "WAIT_IDLE";
      wait_idle(20000000/83*`BIT_TIME);
      #(100000/83*`BIT_TIME);

      test_usb(address, datain_toggle, dataout_toggle);

      // Test simulating input ui_in[0] > Should output character "A" on bulk endp
      test = "Test IN BULK DATA after ui_in[0]=1";
      device_inputs[0] = 1'b1;      

      test_frame_num = 0;
      // Send mora than 10 SOF because the debouncer is using the usb frame number to count
      for(i = 0; i < 12; i=i+1) begin         
         test_sof(test_frame_num , test_frame_num );
         test_frame_num = test_frame_num + 1;
      end
      
      // Host should receive character 'A' (h41)
      test_data_in(address, ENDP_BULK1,
                   {8'h41},
                   1, PID_ACK, IN_BULK_MAXPACKETSIZE, 100000/83*`BIT_TIME, 0, datain_toggle, ZLP);

      test = "Test IN BULK DATA after ui_in[0]=0";
      device_inputs[0] = 1'b0;      

      // Send mora than 10 SOF because the debouncer is using the usb frame number to count
      for(i = 0; i < 12; i=i+1) begin
         test_sof(test_frame_num , test_frame_num );
         test_frame_num = test_frame_num + 1;
      end
      
      // Host shold receive character 'a' (h61)
      test_data_in(address, ENDP_BULK1,
                   {8'h61},
                   1, PID_ACK, IN_BULK_MAXPACKETSIZE, 100000/83*`BIT_TIME, 0, datain_toggle, ZLP);


      /*
      test = "OUT BULK DATA";
      test_data_out(address, ENDP_BULK,
                    {8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h06, 8'h07},
                    7, PID_ACK, OUT_BULK_MAXPACKETSIZE, 100000/83*`BIT_TIME, 0, dataout_toggle);

      test = "IN BULK DATA";
      test_data_in(address, ENDP_BULK,
                   {8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h06, 8'h07},
                   7, PID_ACK, IN_BULK_MAXPACKETSIZE, 100000/83*`BIT_TIME, 0, datain_toggle, ZLP);

      test = "IN BULK DATA with NAK";
      test_data_in(address, ENDP_BULK,
                   {8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h06, 8'h07},
                   7, PID_NAK, IN_BULK_MAXPACKETSIZE, 100000/83*`BIT_TIME, 0, datain_toggle, ZLP);

      test = "OUT BULK DATA";
      test_data_out(address, ENDP_BULK,
                    {8'h11, 8'h12, 8'h13, 8'h14, 8'h15, 8'h16, 8'h17, 8'h18},
                    8, PID_ACK, OUT_BULK_MAXPACKETSIZE, 100000/83*`BIT_TIME, 0, dataout_toggle);

      test = "IN BULK DATA with ZLP";
      test_data_in(address, ENDP_BULK,
                   {8'h11, 8'h12, 8'h13, 8'h14, 8'h15, 8'h16, 8'h17, 8'h18},
                   8, PID_ACK, IN_BULK_MAXPACKETSIZE, 100000/83*`BIT_TIME, 0, datain_toggle, ZLP);

      test = "OUT BULK DATA";
      test_data_out(address, ENDP_BULK,
                    {8'h21, 8'h22, 8'h23, 8'h24, 8'h25, 8'h26, 8'h27, 8'h28,
                     8'h31, 8'h32, 8'h33, 8'h34, 8'h35, 8'h36, 8'h37, 8'h38},
                    16, PID_ACK, OUT_BULK_MAXPACKETSIZE, 100000/83*`BIT_TIME, 0, dataout_toggle);

      test = "IN BULK DATA with ZLP";
      test_data_in(address, ENDP_BULK,
                   {8'h21, 8'h22, 8'h23, 8'h24, 8'h25, 8'h26, 8'h27, 8'h28,
                    8'h31, 8'h32, 8'h33, 8'h34, 8'h35, 8'h36, 8'h37, 8'h38},
                   16, PID_ACK, IN_BULK_MAXPACKETSIZE, 100000/83*`BIT_TIME, 0, datain_toggle, ZLP);

      test = "OUT BULK DATA";
      test_data_out(address, ENDP_BULK,
                    {8'h41, 8'h42, 8'h43, 8'h44, 8'h45, 8'h46, 8'h47, 8'h48,
                     8'h51, 8'h52, 8'h53, 8'h54, 8'h55, 8'h56, 8'h57, 8'h58,
                     8'h61, 8'h62, 8'h63, 8'h64, 8'h65},
                    21, PID_NAK, OUT_BULK_MAXPACKETSIZE, 100000/83*`BIT_TIME, 0, dataout_toggle);

      test = "IN BULK DATA with ZLP";
      test_data_in(address, ENDP_BULK,
                   {8'h41, 8'h42, 8'h43, 8'h44, 8'h45, 8'h46, 8'h47, 8'h48,
                    8'h51, 8'h52, 8'h53, 8'h54, 8'h55, 8'h56, 8'h57, 8'h58},
                   16, PID_ACK, IN_BULK_MAXPACKETSIZE, 100000/83*`BIT_TIME, 0, datain_toggle, ZLP);

      test = "OUT BULK DATA (1/3)";
      test_data_out(address, ENDP_BULK,
                    {8'h71, 8'h72},
                    2, PID_ACK, OUT_BULK_MAXPACKETSIZE, 100000/83*`BIT_TIME, 0, dataout_toggle);

      test = "CLEAR_FEATURE on OUT endpoint 1 (reset data toggle)";
      test_setup_out(address, 8'h02, STD_REQ_CLEAR_FEATURE, 16'h0000, 16'h0001, 16'h0000,
                     8'd0, 'd0, PID_ACK);

      test = "OUT BULK DATA (2/3) skipped due to data toggle mismatch";
      test_data_out(address, ENDP_BULK,
                    {8'h73, 8'h74},
                    2, PID_ACK, OUT_BULK_MAXPACKETSIZE, 100000/83*`BIT_TIME, 0, dataout_toggle);

      test = "OUT BULK DATA (3/3)";
      test_data_out(address, ENDP_BULK,
                    {8'h75, 8'h76},
                    2, PID_ACK, OUT_BULK_MAXPACKETSIZE, 100000/83*`BIT_TIME, 0, dataout_toggle);

      test = "IN BULK DATA";
      test_data_in(address, ENDP_BULK,
                   {8'h71, 8'h72, 8'h75, 8'h76},
                   4, PID_ACK, IN_BULK_MAXPACKETSIZE, 100000/83*`BIT_TIME, 0, datain_toggle, ZLP);

      */

      test = "Test END";
      #(100*`BIT_TIME);
      `report_end("All tests correctly executed!")
   end
endmodule
