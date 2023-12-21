`timescale 1ns / 1ps
`include "fir_adapt_koef.v"

module fir_adapt_tb;

    reg clk, reset, s_axis_fir_tvalid;
    reg signed [7:0] s_axis_fir_tdata;
    wire m_axis_fir_tvalid;
    reg s_set_coeffs;
    wire [10:0] m_axis_fir_tdata;
    
    /*
     * 100Mhz (10ns) clock 
     */
     
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end
    
    always begin
    	reset = 0; #10;
        reset = 1; #10;
        reset = 0; #100000;
    end
    /*
    always begin
        s_axis_fir_tvalid = 0; #100;
        s_axis_fir_tvalid = 1; #998920;
    end
    */
    

    
    always begin
    	s_axis_fir_tvalid = 1;
        s_set_coeffs = 0; #2000000;
        /*
        s_set_coeffs = 1; 
        s_axis_fir_tvalid = 0;
        #35 // 3 takte
        s_set_coeffs = 0; 
        s_axis_fir_tvalid = 1; #2000000
        s_set_coeffs = 0; 
        */
        
    end
    
    
    /* Instantiate FIR module to test. */
    FIR FIR_i(
        .clk(clk),
        .reset(reset),
        .x_n(s_axis_fir_tdata),       
        .s_axis_fir_tvalid(s_axis_fir_tvalid), 
        .s_set_coeffs(s_set_coeffs),  
        .y_n(m_axis_fir_tdata));  

   
        
        
    
    
    
    initial begin
    	$dumpfile("fir_symmetric_tb.vcd");
    	$dumpvars;
    	
	s_axis_fir_tdata <= 8'd0; #300
	
	s_axis_fir_tdata <= 8'd1; #10
	
	s_axis_fir_tdata <= 8'd0; #998
	
	s_set_coeffs = 1;
	s_axis_fir_tvalid = 0; 
	#2
	s_axis_fir_tdata <= 8'd1; #10
	s_axis_fir_tdata <= 8'd2; #10
	s_axis_fir_tdata <= 8'd3; #8
	s_axis_fir_tdata <= 8'd0;
	s_axis_fir_tvalid = 1;
	s_set_coeffs = 0; #2; #100
	
	s_axis_fir_tdata <= 8'd0; #300
	
	s_axis_fir_tdata <= 8'd1; #10
	
	s_axis_fir_tdata <= 8'd0; #1000
	
	/*
	
    	s_axis_fir_tdata <= 6'b000111; #10

    	s_axis_fir_tdata <= 6'b111011; #10

    	s_axis_fir_tdata <= 6'b011011; #10

    	s_set_coeffs = 0; 
    	s_axis_fir_tdata <= 16'h0000; #1000

    	s_axis_fir_tdata <= 16'h0001; #10
 
    	s_axis_fir_tdata <= 16'h0000; #1000
    	*/

    	
    	
    	
    	
    	//s_axis_fir_tdata <= 16'hFFFF; #1000
    	/*
    	s_axis_fir_tdata <= 16'h1F; #1000
    	s_axis_fir_tdata <= 16'h0000; #1000
    	s_axis_fir_tdata <= 16'h1F; #1000
    	s_axis_fir_tdata <= 16'h0000; #1000
    	*/
    	$finish;
    end
          
    
endmodule

