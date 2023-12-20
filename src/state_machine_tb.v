`timescale 1ns / 1ps
`include "fir_adapt_koef.v"

module state_machine_tb;

    reg clk, reset, s_axis_fir_tvalid, m_axis_fir_tready;
    reg signed [5:0] s_axis_fir_tdata;
    wire m_axis_fir_tvalid;
    reg s_set_coeffs;
    wire [3:0] m_axis_fir_tkeep;
    wire [7:0] m_axis_fir_tdata;
    
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
    

    



    
    
    /* Instantiate FIR module to test. */
    FIR FIR_i(
        .clk(clk),
        .reset(reset),
        .s_axis_fir_tdata(s_axis_fir_tdata),       
        .s_axis_fir_tvalid(s_axis_fir_tvalid), 
        .s_set_coeffs(s_set_coeffs),
        .s_axis_fir_tready(s_axis_fir_tready),    
        .m_axis_fir_tdata(m_axis_fir_tdata));  

   
        
        
    
    
    
    initial begin
    	$dumpfile("state_machine_tb.vcd");
    	$dumpvars;
    	
    	m_axis_fir_tready = 1; 
        s_set_coeffs = 0; 
        s_axis_fir_tdata <= 6'b111111;
        s_axis_fir_tvalid = 0; #200
        
        
       
        s_axis_fir_tvalid = 1; #100;
        s_axis_fir_tdata <= 6'b000000; #1000;
        s_axis_fir_tvalid = 0; #1000
        
        /*
        s_set_coeffs = 1; #30
        s_set_coeffs = 0; #30
        
        
        s_axis_fir_tvalid = 1; #30;
        s_set_coeffs = 1; #50
        
        s_axis_fir_tvalid = 0; #20
        s_set_coeffs = 0; #30
        */
        
    	$finish;
    end
          
    
endmodule

