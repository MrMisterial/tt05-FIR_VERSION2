`timescale 1ns / 1ps

module FIR #(
	parameter TAP_SIZE = 2,
	parameter NBR_OF_TAPS = 3,
	parameter X_N_SIZE = 8,
	parameter Y_N_SIZE = 10 //TAP_SIZE + X_N_SIZE minimum
) (
    input clk,
    input reset,
    input signed [X_N_SIZE-1:0] x_n, 
    input s_axis_fir_tvalid,
    input s_set_coeffs,
    output wire signed [Y_N_SIZE-1:0] y_n
    );


    parameter BUFF_SIZE = 5;//NBR_OF_TAPS*2-1; //NBR_OF_TAPS;//
    reg signed [TAP_SIZE-1:0] taps [0:NBR_OF_TAPS-1];
    reg signed [X_N_SIZE-1:0] buffs [0:BUFF_SIZE-1];
    
    reg [1:0] cnt_setup;

    reg [1:0] next_state, state;
    
    reg event_shift_taps;
    reg event_start_fir;
    reg event_init_taps;
    
    localparam IDLE         = 2'b00;
    localparam ACTIVE       = 2'b01;
    localparam CONFIG       = 2'b10;
    localparam SETUP        = 2'b11;
     
    
    
    always @ (posedge clk) begin	
    		if(reset == 1'b1) begin
    			state <= SETUP; 
    		end
    		else begin
    			state <= next_state;
    		end
    end
    			
    	
    always @(state,s_set_coeffs,s_axis_fir_tvalid) begin
    	case (state)
    	    SETUP: begin
    	    	if(cnt_setup == 2'b11) begin
    	    		next_state <= IDLE;
    	    	end
    	    	
    	    
    	    end
    	    
            IDLE: begin
		if (s_axis_fir_tvalid == 1'b1) begin
			next_state <= ACTIVE;
		end
		
		if (s_set_coeffs == 1'b1) begin
			next_state <= CONFIG;
		end
            end
            ACTIVE: begin
            	if (s_set_coeffs == 1'b1) begin
            		next_state <= CONFIG;
            	end
            	
            
            	if (s_axis_fir_tvalid == 1'b0 && s_set_coeffs == 1'b0) begin
            		next_state <= IDLE;
            	end
                
            end 
            CONFIG: begin
            	if (s_set_coeffs == 1'b0) begin
                	next_state <= IDLE;
                end
            end
            
            default: 
                    next_state <= IDLE;
        endcase
    end
    
    //brauche ich dieses switch case statement?
    always @(state) begin
    
    	case (state)
    		SETUP: begin
    			event_init_taps <= 1'b1;
    		end
		IDLE: begin
			event_init_taps <= 1'b0;
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
			event_init_taps <= 1'b0;
			event_shift_taps <= 1'b0;
			event_start_fir <= 1'b0;
		end
		    
        endcase
    
    end
    
    integer i;
    always @ (negedge clk)
    	begin
    	
    		if(reset == 1'b1) begin	 
    			cnt_setup <= 2'b00;  			
    		end	
    	
    		if(event_init_taps == 1'b1)
    			begin
    				cnt_setup <= cnt_setup + 2'b01;
    				taps[0] <= {TAP_SIZE{1'b0}};
				taps[1] <= {TAP_SIZE{1'b1}};
				taps[2] <= {TAP_SIZE{1'b0}};
				/*
				taps[3] <= 2'b00;
				taps[4] <= 2'b01;
				taps[5] <= 2'b00;
				taps[6] <= 2'b01;
				taps[7] <= 2'b00;	
				*/
    			
    			end
    		if(event_shift_taps == 1'b1)
    			begin
    				taps[0] <= x_n[TAP_SIZE-1:0];
				//taps[1] <= x_n[3:2];
				//taps[2] <= x_n[1:0];
				
				for (i =1; i<(NBR_OF_TAPS-1); i = i + 1) begin //geht das so???
					taps[i] <= taps[i-1];
				end

    			end
    	end
    	
   integer j;
   integer w;
   always @ (negedge clk)
        begin
            if(event_start_fir == 1'b1)
                begin
                
                	
                buffs[0] <= x_n;
                
                for (j =0; j<(BUFF_SIZE-1); j = j + 1) begin //geht das so???
			buffs[j+1] <= buffs[j];
		end
		
		
                end
            else
                begin
                
                
                for (w =0; w<(BUFF_SIZE-1); w = w + 1) begin //geht das so???
			buffs[w] <= {X_N_SIZE{1'b0}};
		end
		

                end
        end 
        

    reg signed [Y_N_SIZE-1:0] sum;
    integer k;
    always @( posedge clk) begin    	    
	    sum = 0;	 	    
	    for (k =0; k<(BUFF_SIZE-1); k = k + 1) begin //geht das so???
	    	sum = sum + (taps[k]*buffs[k]);
	    	/*
	    	if (k < (NBR_OF_TAPS-1)) begin
	    		sum = sum + (taps[k]*buffs[k]);
	    	end
	    	else begin
	    		sum = sum + (taps[(BUFF_SIZE-1)-k]*buffs[k]);
	    	end
	    	*/
	    
	    	

	    end    
    end
    assign y_n = (state == ACTIVE) ? sum : {Y_N_SIZE{1'b0}};
    
    
    
endmodule

