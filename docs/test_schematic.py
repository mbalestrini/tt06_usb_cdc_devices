import schemdraw
import schemdraw.elements as elm

# schemdraw.theme('monokai')
with schemdraw.Drawing(file="test_schematic.png") as d:
    d.config(fontsize=12)
    # d.config(unit=3)
    TT = (elm.Ic(size=[15,30])
        
         .side('L', spacing=3, pad=2, leadlen=2.5)
         .side('R', spacing=3, pad=2, leadlen=2.5)         
        #  .side('T', pad=1.5, spacing=1)
        #  .side('B', pad=1.5, spacing=1)
        #  .pin(name='BIDIR[2]', side='left', pin='')
        #  .pin(name='BIDIR[3]', side='left', pin='')
        #  .pin(name='BIDIR[4]', side='left', pin='')
        #  .pin(name='BIDIR[5]', side='left', pin='')
        #  .pin(name='BIDIR[6]', side='left', pin='')
        #  .pin(name='BIDIR[7]', side='left', pin='')
         .pin(lblsize=12, anchorname='IN_6', name='IN[6]', side='left', pin='input_6')
         .pin(lblsize=12, anchorname='IN_5', name='IN[5]', side='left', pin='input_5')
         .pin(lblsize=12, anchorname='IN_4', name='IN[4]', side='left', pin='input_4')
         .pin(lblsize=12, anchorname='IN_3', name='IN[3]', side='left', pin='input_3')
         .pin(lblsize=12, anchorname='IN_2', name='IN[2]', side='left', pin='input_2')
         .pin(lblsize=12, anchorname='IN_1', name='IN[1]', side='left', pin='input_1')
         .pin(lblsize=12, anchorname='IN_0', name='IN[0]', side='left', pin='input_0')

         .pin(lblsize=12, anchorname='USB_N', name='BIDIR[1]', side='left', pin='usb_n')
         .pin(lblsize=12, anchorname='USB_P', name='BIDIR[0]', side='left', pin='usb_p')
         .pin(lblsize=12, anchorname='USB_PU', name='OUT[0]', side='left', pin='usb_pu')

         .pin(lblsize=12, anchorname='OUT_7', name='OUT[7]', side='right', pin='debug_frame[3]')
         .pin(lblsize=12, anchorname='OUT_6', name='OUT[6]', side='right', pin='debug_frame[2]')
         .pin(lblsize=12, anchorname='OUT_5', name='OUT[5]', side='right', pin='debug_frame[1]')
         .pin(lblsize=12, anchorname='OUT_4', name='OUT[4]', side='right', pin='debug_frame[0]')
         .pin(lblsize=12, anchorname='OUT_3', name='OUT[3]', side='right', pin='debug_usb_tx_en')
         .pin(lblsize=12, anchorname='OUT_2', name='OUT[2]', side='right', pin='debug_usb_configured')
         .pin(lblsize=12, anchorname='OUT_1', name='OUT[1]', side='right', pin='debug_led')

        .fill("#c0c0c0")
         .label('TT06_USB_CDC_DEVICES', loc='center',  fontsize=15))
    
    elm.Dot().at(TT.USB_P)
    elm.Line().at(TT.USB_P).left().label(label="D+", loc="left")    
    elm.Resistor().at(TT.USB_PU).label("1.5k").toy(TT.USB_P)

    
    elm.Line().to(TT.USB_P)
    
    elm.Line().at(TT.USB_N).left().label(label="D-", loc="left")
    # elm.Line().at(TT.USB_N).left().label(label="D-", loc="left")
    

    
    # elm.Label("D+").up()
    


    #     input  wire [7:0] ui_in,    // Dedicated inputs
    # output wire [7:0] uo_out,   // Dedicated outputs
    # input  wire [7:0] uio_in,   // IOs: Input path
    # output wire [7:0] uio_out,  // IOs: Output path
    # output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    # input  wire       ena,      // will go high when the design is enabled
    # input  wire       clk,      // clock
    # input  wire       rst_n     // reset_n - low to reset