`timescale 1ns / 1ps

module FIR(
    input clk,
    input reset,
    input signed [5:0] x_n, 
    input s_axis_fir_tvalid,
    input s_set_coeffs,
    output wire signed [7:0] y_n
    );

    
    reg signed [5:0] buff0, buff1, buff2, buff3, buff4, buff5, buff6, buff7; 
    reg signed [1:0] tap0, tap1, tap2, tap3, tap4, tap5, tap6, tap7; 
    wire signed [7:0] acc0, acc1, acc2, acc3, acc4, acc5, acc6, acc7; 
    reg [1:0] next_state, state;
    
    reg event_shift_taps;
    reg event_start_fir;
    
    localparam IDLE         = 2'b00;
    localparam ACTIVE       = 2'b01;
    localparam CONFIG       = 2'b10;
    
    
    
    always @ (posedge clk) begin	
    		if(reset == 1'b1) begin
    			state <= IDLE; 			
    			tap0 <= 2'b01;
			tap1 <= 2'b00;
			tap2 <= 2'b01;
			tap3 <= 2'b00;
			tap4 <= 2'b01;
			tap5 <= 2'b00;
			tap6 <= 2'b01;
			tap7 <= 2'b00;		
    		end
    		else begin
    			state <= next_state;
    		end
    end
    			
    	
    always @(state,s_set_coeffs,s_axis_fir_tvalid) begin
    	case (state)
            IDLE: begin
		if (s_axis_fir_tvalid == 1'b1) begin
			next_state = ACTIVE;
		end
		
		if (s_set_coeffs == 1'b1) begin
			next_state = CONFIG;
		end
            end
            ACTIVE: begin
            	if (s_set_coeffs == 1'b1) begin
            		next_state = CONFIG;
            	end
            	
            
            	if (s_axis_fir_tvalid == 1'b0 && s_set_coeffs == 1'b0) begin
            		next_state = IDLE;
            	end
                
            end 
            CONFIG: begin
            	if (s_set_coeffs == 1'b0) begin
                	next_state = IDLE;
                end
            end
            
            default: 
                    next_state = IDLE;
        endcase
    end
    
    //brauche ich dieses switch case statement?
    always @(state) begin
    
    	case (state)
		IDLE: begin
			event_shift_taps <= 1'b0;
			event_start_fir <= 1'b0;
			
		end
		
		ACTIVE: begin
			event_start_fir <= 1'b1;
			event_shift_taps <= 1'b0;
			
		end 
		
		CONFIG: begin
			event_shift_taps <= 1'b1;
			event_start_fir <= 1'b0;
			
		end

		default: begin
			event_shift_taps <= 1'b0;
			event_start_fir <= 1'b0;
		end
		    
        endcase
    
    end
    
    always @ (negedge clk)
    	begin
    		if(event_shift_taps == 1'b1)
    			begin
				tap0 <= x_n[5:4];
				tap1 <= x_n[3:2];
				tap2 <= x_n[1:0];
				tap3 <= tap0;
				tap4 <= tap1;
				tap5 <= tap2;
				tap6 <= tap3;
				tap7 <= tap4;
				/*

				buff0 <= 6'd0;
				buff1 <= 6'd0;        
				buff2 <= 6'd0;         
				buff3 <= 6'd0; 
				buff4 <= 6'd0;
				buff5 <= 6'd0;
				buff6 <= 6'd0;
				buff7 <= 6'd0;
				*/
    			end
    	end
    	
   always @ (negedge clk)
        begin
            if(event_start_fir == 1'b1)
                begin
                    buff0 <= x_n; //in_sample
                    buff1 <= buff0;        
                    buff2 <= buff1;         
                    buff3 <= buff2;   
                    buff4 <= buff3; 
                    buff5 <= buff4; 
                    buff6 <= buff5; 
                    buff7 <= buff6;    
                   
                end
            else
                begin
                    buff0 <= 6'd0;
                    buff1 <= 6'd0;        
                    buff2 <= 6'd0;         
                    buff3 <= 6'd0; 
                    buff4 <= 6'd0;
                    buff5 <= 6'd0;
                    buff6 <= 6'd0;
                    buff7 <= 6'd0;     
                    
                end
        end     
    assign acc0 = tap0 * buff0;
    assign acc1 = tap1 * buff1;
    assign acc2 = tap2 * buff2;
    assign acc3 = tap3 * buff3;
    assign acc4 = tap4 * buff4;
    assign acc5 = tap5 * buff5;
    assign acc6 = tap6 * buff6;
    assign acc7 = tap7 * buff7;
        

    assign y_n = (state == ACTIVE) ? acc0 + acc1 + acc2 + acc3 + acc4 + acc5 + acc6 + acc7 : 8'd0;

	
    
    
endmodule

