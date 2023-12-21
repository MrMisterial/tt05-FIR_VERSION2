`timescale 1ns / 1ps

module FIR #(
	parameter TAP_SIZE = 2,
	parameter NBR_OF_TAPS = 8,
	parameter X_N_SIZE = 6,
	parameter Y_N_SIZE = 8
) (
    input clk,
    input reset,
    input signed [X_N_SIZE-1:0] x_n, 
    input s_axis_fir_tvalid,
    input s_set_coeffs,
    output wire signed [Y_N_SIZE-1:0] y_n
    );


    
    reg signed [TAP_SIZE-1:0] taps [0:NBR_OF_TAPS-1];
    reg signed [X_N_SIZE-1:0] buffs [0:NBR_OF_TAPS-1];
    //wire signed [Y_N_SIZE-1:0] accs [0:NBR_OF_TAPS-1];
    
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
    			cnt_setup <= 2'b00;	
    			/*		
    			tap0 <= 2'b01;
			tap1 <= 2'b00;
			tap2 <= 2'b01;
			tap3 <= 2'b00;
			tap4 <= 2'b01;
			tap5 <= 2'b00;
			tap6 <= 2'b01;
			tap7 <= 2'b00;	
			*/	
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
    	
    		if(event_init_taps == 1'b1)
    			begin
    				cnt_setup <= cnt_setup + 2'b01;
    				taps[0] <= 2'b01;
				taps[1] <= 2'b00;
				taps[2] <= 2'b01;
				taps[3] <= 2'b00;
				taps[4] <= 2'b01;
				taps[5] <= 2'b00;
				taps[6] <= 2'b01;
				taps[7] <= 2'b00;	
    			

				
    			
    			end
    		if(event_shift_taps == 1'b1)
    			begin
    				/* working
    				taps[0] <= x_n[5:4];
				taps[1] <= x_n[3:2];
				taps[2] <= x_n[1:0];
				taps[3] <= taps[0];
				taps[4] <= taps[1];
				taps[5] <= taps[2];
				taps[6] <= taps[3];
				taps[7] <= taps[4];
				*/
    				
    				
    				taps[0] <= x_n[5:4];
				taps[1] <= x_n[3:2];
				taps[2] <= x_n[1:0];
				
				for (i =3; i<(NBR_OF_TAPS-1); i = i + 1) begin //geht das so???
					taps[i] <= taps[i-3];
				end

    			end
    	end
    	
   integer j;
   always @ (negedge clk)
        begin
            if(event_start_fir == 1'b1)
                begin
                
                	
                buffs[0] <= x_n;
                
                for (j =0; j<(NBR_OF_TAPS-1); j = j + 1) begin //geht das so???
			buffs[j+1] <= buffs[j];
		end
		
		
                end
            else
                begin
                
                
                for (i =0; i<(NBR_OF_TAPS-1); i = i + 1) begin //geht das so???
			buffs[i] <= 6'd0;
		end
		

                end
        end 
        
    /*
    genvar k;
    
    wire signed [Y_N_SIZE-1:0] sum_steps [NBR_OF_TAPS-1:0];
    
       
    generate
    for (k =0; k<(NBR_OF_TAPS-1); k = k + 1) begin //geht das so???
    	assign sum_steps[k + 1] = sum_steps[k] + (taps[k]*buffs[k]);
    end 
    endgenerate
    
    assign y_n = (state == ACTIVE) ? sum_steps[NBR_OF_TAPS-1] : 14'd0;
    */
    
    
    /*
    sum_fir = 'd0;
    for (i =0; i<NBR_OF_TAPS; i = i + 1) begin //geht das so???
	sum_fir = sum_fir + taps[i]*buffs[i];
    end
    */
              
    
    /*
    always @(*) begin
    
    
    for (k =0; k<(NBR_OF_TAPS-1); k = k + 1) 
    begin //geht das so???
    	assign accs[k] = taps[k] * buffs[k];
    end 
    
    
    end
    */
    
    
    
    //wire signed [Y_N_SIZE-1:0] sum_steps [NBR_OF_TAPS-1:0];
    
    reg signed [7:0] sum;
    integer k;
    always @( posedge clk) begin
    
	    
	    sum = 0;
	    
	    
	    for (k =0; k<5; k = k + 1) begin //geht das so???
	    	sum = sum + (taps[k]*buffs[k]);
	    	//sum <= sum + (taps[k]*buffs[k]);
	    	//assign sum_steps[k + 1] = sum_steps[k] + (taps[k]*buffs[k]);
	    end 
	    
	    
	    
	    //assign y_n = (state == ACTIVE) ? sum : 14'd0;
	    
    
    
    end
    assign y_n = (state == ACTIVE) ? sum : {Y_N_SIZE{1'b0}};
    
    
    
endmodule

