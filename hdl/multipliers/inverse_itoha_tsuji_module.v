`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Rahul Yamasani
// 
// Create Date:    00:27:56 09/16/2014 
// Design Name: 
// Module Name:    inverse_itoha_tsuji_module 
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
module inverse_itoha_tsuji_module(

	input wire clk, 
	 				
	output reg [2:0] read_addr_inv,
	output reg [2:0] write_addr_inv,
	
	output reg [3:0] b_command,
	
	input wire [2:0]      start_addr,			 
	input wire            interupt_sqr, 
	input wire            interupt_red, 
	input wire            interupt_swap, 
	input wire            interupt_mul,
	output reg            interupt,
	output reg            select_Ram_C_Or_D, 
	output reg            select_Ram_A_Or_B, 
	output reg [1:0]      numbr_of_chunk,
   input wire [3:0]      command,
	output reg            cmd_inv,
	
	input wire [9:0]     Data_len_Polynomial
    );

     reg [4:0] Inv;
	  reg [10:0] count,len_Reduction_Polynomial;
	  reg [2:0] var;
	  
		initial begin
			cmd_inv<=1'h0;
			Inv<=4'h0;
			interupt<=1'h0;
			select_Ram_A_Or_B<=1'h0;
			select_Ram_C_Or_D<=1'h0;
		end
		
		always @(posedge clk)begin
			if(command==4'h3)begin        //check command is for inverse or not				
				Inv<=5'h1;                 //start fsm			
				end

				
				case(Inv)
				5'h1:begin
				  Inv<=5'h3;
				  cmd_inv<=1'h1;
				  read_addr_inv<=start_addr;
              b_command<=4'h2;    //command for square operation				  
				end
								
				5'h3:begin
				    b_command<=4'h0;
				    count<=Data_len_Polynomial-2'h2;
					 len_Reduction_Polynomial<=Data_len_Polynomial;
					 if(interupt_sqr)
				      Inv<=5'h4;
						end
				
				
			  5'h4:begin
			      Inv<=5'h5;
			      b_command<=4'h4;
					read_addr_inv<=start_addr-1'h1;   //give addr from where reduction start
					
					end
			
			
			5'h5:begin
			     b_command<=5'h0;
				  numbr_of_chunk<=Data_len_Polynomial/9'h100+1'h1;
				  var<=Data_len_Polynomial/8'h80;   //to decide where to swap data from
			     if(interupt_red)
					 Inv<=4'h6;

			end
	    
		 
		 5'h6:begin     //move square data to A Ram
		       Inv<=5'h7;
		       b_command<=4'h5;      //command for data swapping
				 write_addr_inv<=start_addr-1'h1;
				 if((var[1]&&var[0])||var[2])begin
				  read_addr_inv<=start_addr-2'h2;
				  end
				 else
					read_addr_inv<=start_addr-1'h1;
				 
				 select_Ram_A_Or_B<=1'h1;
				 if(var[1]^var[0])
				   select_Ram_C_Or_D<=1'h0;
				else
				   select_Ram_C_Or_D<=1'h1;
				 end
		
		
		5'h7:begin
			 b_command<=4'h0;
			 if(interupt_swap) 
			      Inv<=5'h8;				
				 end  
      
      5'h8:begin
		    Inv<=5'h9;
          b_command<=4'h5;
          select_Ram_A_Or_B<=1'h0;
          end
    
       5'h9:begin                //move data to B polynomial
          b_command<=4'h0;
			 if(interupt_swap) 
			      Inv<=5'ha;
          end
			 
		5'ha:begin     //calculation of square
		
		   Inv<=5'hb;
			b_command<=4'h2;
         count<=count-1'h1;			
			read_addr_inv<=start_addr;
			end
			
			
		5'hb:begin
			b_command<=4'h0;
			if(interupt_sqr)
			  Inv<=5'hc;			  
		end
		
		
       5'hc:begin
			      Inv<=5'hd;
			      b_command<=4'h4;
					read_addr_inv<=start_addr-1'h1;   //give addr from where reduction start
					
					end
			
			
			5'hd:begin
			     b_command<=5'h0;
			     if(interupt_red)
					 Inv<=4'he;

			end
	    
		 
		 5'he:begin     //move square data to A Ram
		       Inv<=5'hf;
		       b_command<=4'h5;      //command for data swapping
				  write_addr_inv<=start_addr-1'h1;
		        if((var[1]&&var[0])||var[2])
				  read_addr_inv<=start_addr-2'h2;
				 else
					read_addr_inv<=start_addr-1'h1;
				 
				 
				 select_Ram_A_Or_B<=1'h1;
				 end
				 
		5'hf:begin
		   b_command<=4'h0;
		   if(interupt_swap)
		     Inv<=5'h10;
		   end
			
		5'h10:begin        //multiplication
		   Inv<=5'h11;
		   b_command<=4'h1;
			read_addr_inv<=start_addr;
			end
			
		5'h11:begin
		   b_command<=4'h0;
			if(interupt_mul)
			  Inv<=5'h12;
			end
									 		 
	     5'h12:begin
				Inv<=5'h13;
				b_command<=4'h4;
				read_addr_inv<=start_addr-1'h1;   //give addr from where reduction start
					
					end
			
			
			5'h13:begin
			     b_command<=5'h0;
			     if(interupt_red)
					 Inv<=5'h14;

			end 
			
 	     
        5'h14:begin     //move mul data to B Ram
		       Inv<=5'h15;
		       b_command<=4'h5;      //command for data swapping
				 write_addr_inv<=start_addr-1'h1;
				 
				 
				 if((var[1]&&var[0])||var[2])
				  read_addr_inv<=start_addr-2'h2;
				 else
					read_addr_inv<=start_addr-1'h1;
				 select_Ram_A_Or_B<=1'h0;                   //result in B
				 end
				 
		5'h15:begin
		   b_command<=4'h0;
		  if(count==10'h0) begin
		    Inv<=5'h16;
			 interupt<=1'h1;
			 end
			 
		  if(interupt_swap)
			   Inv<=5'ha;
		//	   Inv<=5'h16;
		   end
		5'h16:begin
			cmd_inv<=1'h0;
		   interupt<=1'h0;
			end

		  endcase										   
       		           			 											 											

end
endmodule
