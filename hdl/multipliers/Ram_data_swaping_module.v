`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: BARC
// Engineer: Rahul and Deepak
// 
// Create Date:    02:49:20 09/15/2014 
// Design Name: 
// Module Name:    Ram_data_swaping_module 
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
module Ram_data_swaping_module#(
parameter Data=255,
parameter Addr =2)(
      input wire             clk,
		input wire [Addr:0]    read_addr,
		input wire [Addr:0]    write_addr,
		input wire [1:0]       numbr_of_chunk,
		
		input wire             select_Ram_C_Or_D,
		input wire             select_Ram_A_Or_B,
		
 ///THis pin gave command to DMA to swap data
		output reg             select_Ram_C_DMA,  
		output reg             select_Ram_D_DMA, 
		
		output reg             b_w_A, 
		output reg [Addr:0]    b_adbus_A, 
		
		output reg             b_w_B, 
		output reg [Addr:0]    b_adbus_B, 

		output reg [Addr:0]    b_adbus_C, 

		output reg [Addr:0]    b_adbus_D, 
		
		output reg            interupt,
      input wire [3:0]      command,
      output reg             cmd_swap		
	    );
		 //select_Ram_C_Or_D   1:C_Ram   0:D_Ram
		 //select_Ram_A_Or_B   1:A_Ram   0:B_Ram
		 initial begin
		   //swap<=4'hf;
			cmd_swap<=1'h0;
			interupt<=1'h0;
			select_Ram_D_DMA<=1'h0;
			select_Ram_C_DMA<=1'h0;
		 end
		 reg [3:0]  swap;
		 always @(posedge clk) begin
		 
		    if(command==4'h5)begin
             swap<=3'h1;
				 cmd_swap<=1'h1;
             end

           case (swap)
			  
			  4'h1:begin
			       cmd_swap<=1'h1;
			       swap<=4'h2;
					  b_adbus_C<=read_addr;
					  b_adbus_D<=read_addr;
					end
					  
			  4'h2:begin
			      swap<=4'h3;
					
            end					  
				
				4'h3:begin
				 if(numbr_of_chunk[1])
						 swap<=4'h4;
					else begin
						 swap<=4'h7;
						 
						 end
			      if(select_Ram_C_Or_D) begin
					   select_Ram_C_DMA<=1'h1;
						select_Ram_D_DMA<=1'h0;
						end
					else  begin
					   select_Ram_C_DMA<=1'h0;
						select_Ram_D_DMA<=1'h1;
						b_adbus_C<=read_addr-1'h1;
						end
					if(select_Ram_A_Or_B)begin
					   b_w_A<=1'h1;
						b_w_B<=1'h0;
					   b_adbus_A<=write_addr;					 
					  end			  
					else begin
					  b_w_B<=1'h1;
					  b_w_A<=1'h0;
					  b_adbus_B<=write_addr;					 
					  end
				  end
					  				  
				  4'h4:begin
				      if(!select_Ram_C_Or_D) begin
					   select_Ram_C_DMA<=1'h1;
						select_Ram_D_DMA<=1'h0;
						end
					else  begin
					   
					   select_Ram_C_DMA<=1'h0;
						select_Ram_D_DMA<=1'h1;
						end
						if(select_Ram_A_Or_B)begin
						   b_w_B<=1'h0;
							b_w_A<=1'h1;
							b_adbus_A<=write_addr-1'h1;
						
							end
						else begin
						   b_w_A<=1'h0;
							b_w_B<=1'h1;
							b_adbus_B<=write_addr-1'h1;
							end
							
						if(numbr_of_chunk[0])
							swap<=4'h5;
							else begin
								swap<=4'h7;
								interupt<=1'h1;
								end
						if(select_Ram_C_Or_D)
							b_adbus_C<=read_addr-1'h1;
						else
							b_adbus_D<=read_addr-1'h1;
							end
				
				4'h5:begin
				   swap<=4'h6;
				   end
				
				4'h6:begin
				   swap<=4'h7;
					//interupt<=1'h1;
					if(select_Ram_C_Or_D) begin
					   select_Ram_C_DMA<=1'h1;
						select_Ram_D_DMA<=1'h0;
						end
					else  begin
					   select_Ram_C_DMA<=1'h0;
						select_Ram_D_DMA<=1'h1;
						end
					if(select_Ram_A_Or_B)begin
					      b_w_B<=1'h0;
							b_w_A<=1'h1;
							b_adbus_A<=write_addr-2'h2;
							end
							
						else begin
						   b_w_A<=1'h0;
							b_w_B<=1'h1;
							b_adbus_B<=write_addr-2'h2;
							end					
					end
					
				4'h7:begin
				    swap<=4'h8;
					 interupt<=1'h1;
					 end
					 
					 
				 4'h8:begin
					 interupt<=1'h0;
					  cmd_swap<=1'h0;
					  b_w_B<=1'h0;
					  b_w_A<=1'h0;
					 end					 									 
		 endcase
	 end		 
endmodule
