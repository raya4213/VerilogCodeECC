`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:06:56 09/21/2014 
// Design Name: 
// Module Name:    Sequntial_Xor 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Sequntial_Xor(

		input wire clk, 
		input wire [3:0] command, 
		input wire [2:0] start_addr, 
		
		
		output reg [2:0] b_adbus_A,
		output reg [2:0] b_adbus_B, 
		
		output reg cmd_Xor, 
		output reg interupt_Xor,
		output reg b_w_C,
		output reg b_w_D,
		
		output reg [2:0] b_adbus_C,
		output reg [2:0] b_adbus_D,
		
		output reg [2:0]  select_line,
		
		input wire [9:0] Data_len_Polynomial
    );

	 
	 reg [3:0] fsm;
	 
	 initial begin
		cmd_Xor<=0;
		 interupt_Xor<=1'h0;
	 end
	 
	 always @(posedge clk)begin
    if(command==4'h6)begin
		fsm<=4'h1;
	 end
        case(fsm) 
		  4'h1:begin
					fsm <= 4'h2;
					cmd_Xor <= 1;
					b_adbus_A <= start_addr-1'h1;                       //read first 256
					b_adbus_B <= start_addr-1'h1; 
					select_line <= 4'h5;
				end
				
				4'h2:begin				
					b_w_C<=1'h1;
					b_adbus_C<=start_addr-1'h1;
					
					if( (Data_len_Polynomial/9'h100) == 2'h0)begin
						fsm<=4'h5;
						interupt_Xor<=1'h1;
						end
					else  begin
						fsm<=4'h3;
						b_adbus_A <= start_addr-2'h2;                       //read second 256
						b_adbus_B <= start_addr-2'h2; 
						end
						
				end
				
			
			4'h3:begin
					fsm<=4;
					b_w_C<=1'h0;
					b_w_D<=1'h1;
					b_adbus_D<=start_addr-1'h1;
					
					if( (Data_len_Polynomial/9'h100) == 2'h1)begin
						fsm<=4'h5;
						interupt_Xor<=1'h1;
						end
					else  begin
						fsm<=4'h4;
						b_adbus_A <= start_addr-2'h3;                       //read second 256
						b_adbus_B <= start_addr-2'h3;						 
						end
					
			end
			
			4'h4:begin
					b_w_D<=1'h0;
					b_w_C<=1'h1;
					b_adbus_C<=start_addr-2'h2;
					fsm<=4'h5; 
					interupt_Xor<=1;
			end			
						
			4'h5:begin
				b_w_C<=1'h0;
			   interupt_Xor<=1'h0;
				fsm<=4'h6;
			end
		  
		  
		 4'h6:begin
          cmd_Xor<=1'h0;
       end			 
			
	endcase
	end

endmodule
