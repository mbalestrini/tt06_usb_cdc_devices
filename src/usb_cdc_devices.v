`default_nettype none

module usb_cdc_devices
  (
   input wire clk, // 48MHz Clock = 12*BIT_SAMPLES
   input wire rstn_i,

   output wire dp_pu_o, // USB 1.5kOhm Pullup EN

   output wire tx_en_o, // USB+- tristate control
   output wire dp_tx_o, // USB+
   input wire dp_rx_i,  // USB+
   output wire dn_tx_o, // USB-
   input wire dn_rx_i,   // USB-
   
   output wire led_o, // User LED ON=1, OFF=0
   input wire [7:0] inputs_i
   // output dbg_pin_0
   );

   /**** usb_cdc ****/
   localparam VENDOR_ID = 16'h0000;
   localparam PRODUCT_ID = 16'h0000;
   localparam BIT_SAMPLES = 'd4;    
   localparam CHANNELS = 'd1;
   // If we use a different clock for the app we should set APP_CLK_FREQ.
   // The important value is the 12MHz threshold, not the exact value. 
   // in_fifo and out_fifo synchronize clocks according to if the clock is <=12 or not
   localparam USE_APP_CLK = 0;
   localparam APP_CLK_FREQ = 12;

   /**** arcade_io_device ****/
   localparam ARCADE_IO_NUM_INPUTS = 8;


   wire             clk_usb;
   wire             clk_app;

   wire [10:0]      frame;
   wire             configured;
   
   wire [7:0]       out_data;
   wire             out_valid;
   wire             in_ready;
   wire [7:0]       in_data;
   wire             in_valid;
   wire             out_ready;

   assign clk_usb = clk;
   assign clk_app = clk;

   assign led_o = (configured) ? frame[9] : ~&frame[4:3];
//    assign dbg_pin_0 = tx_en;
   

   arcade_io_device #(
            .NUM_INPUTS(ARCADE_IO_NUM_INPUTS)
   ) u_device0 (
            .clk_i(clk_app),
            .rstn_i(rstn_i),
            .inputs_i(inputs_i),
            .frame_i(frame),
            .out_data_i(out_data),
            .out_valid_i(out_valid),
            .in_ready_i(in_ready),
            .out_ready_o(out_ready),
            .in_data_o(in_data),
            .in_valid_o(in_valid),
            .usb_configured_i(configured)
            );
            
   usb_cdc #(.VENDORID(VENDOR_ID),
             .PRODUCTID(PRODUCT_ID),
             .CHANNELS(CHANNELS),
             .IN_BULK_MAXPACKETSIZE('d8),
             .OUT_BULK_MAXPACKETSIZE('d8),
             .BIT_SAMPLES(BIT_SAMPLES),
             .USE_APP_CLK(USE_APP_CLK),
             .APP_CLK_FREQ(APP_CLK_FREQ))
   u_usb_cdc (.frame_o(frame),
              .configured_o(configured),
              .app_clk_i(clk_app),
              .clk_i(clk_usb),
              .rstn_i(rstn_i),
              .out_ready_i(out_ready),
              .in_data_i(in_data),
              .in_valid_i(in_valid),
              .dp_rx_i(dp_rx_i),
              .dn_rx_i(dn_rx_i),
              .out_data_o(out_data),
              .out_valid_o(out_valid),
              .in_ready_o(in_ready),
              .dp_pu_o(dp_pu_o),
              .tx_en_o(tx_en_o),
              .dp_tx_o(dp_tx_o),
              .dn_tx_o(dn_tx_o));

   

endmodule
