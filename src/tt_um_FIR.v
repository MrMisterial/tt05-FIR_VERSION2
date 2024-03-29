`default_nettype none
`include "fir_adapt_koef.v"

module tt_um_FIR #( parameter MAX_COUNT = 24'd10_000_000 ) (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    wire reset = rst_n;
    //wire [6:0] led_out;
    //assign uo_out[7:0] = 8'b00000000;
    //assign uio_out[7:0] = 8'b00000000;
    //assign uio_oe[7:0] = 8'b11111100;
    assign uio_oe[7:0] = 8'b00111111;
    //assign uo_out[7] = 1'b0;

    // use bidirectionals as outputs
    //assign uio_oe = 8'b11111111;

    // put bottom 8 bits of second counter out on the bidirectional gpio
    //assign uio_out = second_counter[7:0];

    // external clock is 10MHz, so need 24 bit counter


    // if external inputs are set then use that as compare count
    // otherwise use the hard coded MAX_COUNT
    //wire [23:0] compare = ui_in == 0 ? MAX_COUNT: {6'b0, ui_in[7:0], 10'b0};

	/*
    always @(posedge clk) begin
        // if reset, set counter to 0
       
        second_counter <= 0;
        digit <= 0;
        
    end
    */
    


    // instantiate segment display
    //seg7 seg7(.counter(digit), .segments(led_out));
    
        
    wire [10:0] m_axis_fir_tdata; //FIR OUTPUT DATA
    assign uo_out = m_axis_fir_tdata[7:0]; //8Bits output
    
    assign uio_out[2:0] = m_axis_fir_tdata[10:8]; //8Bits output
    assign uio_out[5:3] = 3'b000;
    
    assign uio_out[7:6] = 2'b00; //8Bits output
    
    //set param
    wire s_set_coeffs;
    assign s_set_coeffs = uio_in[6];
    
    wire s_axis_fir_tvalid;
    assign s_axis_fir_tvalid = uio_in[7];
   
    
    wire [7:0] s_axis_fir_tdata; //FIR INPUT DATA 
    assign s_axis_fir_tdata = ui_in[7:0]; //8 Bit in

    
    
    FIR FIR_i(
        .clk(clk),
        .reset(reset),
        .x_n(s_axis_fir_tdata),       
        .s_axis_fir_tvalid(s_axis_fir_tvalid), 
        .s_set_coeffs(s_set_coeffs),   
        .o_y_n(m_axis_fir_tdata));  
        
	

endmodule
