`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:24:00 08/21/2014 
// Design Name: 
// Module Name:    Square_571 
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

/*Input from Port A and Output to Port C and Port D alternatively*/


module Square_571#(
	parameter ADDR = 3
	)(
	output  reg  [2:0]           b_adbus_A,
   output  reg                   byte_pos_A,
	
	output  reg                  b_w_C,  
	output  reg [(ADDR-1):0]     b_adbus_C,
   output  reg                  byte_pos_C,

	
	output  reg                  b_w_D,  
	output  reg [(ADDR-1):0]     b_adbus_D,
	
	input      wire              clk,
	input wire   [2:0]           start_addr,
	input wire[3:0]				  command,
	output reg                   cmd_sqr,
	
	output  reg [2:0]            select_line,
	output reg                   interupt,
	input  wire    [9:0]         Data_len_Polynomial
    );
	 
	reg [3:0] Sqr;
	reg [9:0] Poly_len,Poly_chunk;
	
	initial begin
		cmd_sqr<=1'h0;
		select_line=3'h2;
		interupt<=1'h0;
	end
		

	always @(posedge clk)begin
		if (command == 4'b010)begin
			Sqr <= 4'h2;
		end		
		
		case (Sqr)
		 
				4'h2:begin
				   cmd_sqr<=1'h1;
				   Sqr <= 4'h3;
					b_adbus_A <= start_addr-((Data_len_Polynomial/9'h100)+1'h1);				
               byte_pos_A <= 1'h0;
               Poly_len<=(Data_len_Polynomial/8'h80)+1'h1;	
               Poly_chunk<=(Data_len_Polynomial/256)+1'h1;						
		   		end
			  
			4'h3:begin
			         //write_addr<=start_addr-Poly_chunk;
					 if(Poly_len%2'h2==0)begin			
						b_w_D <=1;
						b_adbus_D <=start_addr-Poly_chunk;
						byte_pos_C<=1'h1;
						end
					 else begin
						b_w_C <=1;
						b_adbus_C <=start_addr-Poly_chunk;
                  byte_pos_C<=1'h0;            						
						end        				 	
					
               if(Poly_len==4'h1)  begin              //check condition whether to perform further squaring or not depending upon poly len
						Sqr<=4'hc; 						//go to C to genearte interupt
						interupt<=1'h1;
						end
               else
                  Sqr <= 4'h4;									
	 	end
		
				//Reading Msb
				  4'h4:begin
						b_w_D<=1'h0; 
						b_w_C<=1'h0;					
						byte_pos_A <= 2'h1;
						Sqr <= 4'h5;			
						end
					
					
					4'h5:begin	       					
						 if(Poly_len%2==0)begin			
						     b_w_C <=1;
						     b_adbus_C <=start_addr-Poly_chunk;
							  byte_pos_C<=1'h0;
						     end
					   else begin
						     b_w_D <=1;
						     b_adbus_D <=start_addr-Poly_chunk+1'h1;
                       byte_pos_C<=1'h1;							  
						    end 
                   Poly_chunk<=Poly_chunk-1'h1;							 
                   if(Poly_len==2'h2) begin
                    Sqr<=4'hc;
                    interupt<=1'h1;
                    end						  
                  else   begin
                     Sqr <= 4'h6;						
					      b_adbus_A <= start_addr-(Poly_chunk-1'h1);
							end
				      end
						
						
					/*Squaring of 256 done*/
					
					4'h6:begin
						b_w_C <=0;
						b_w_D <=0;						
						
						byte_pos_A <= 1'h0;					
						Sqr <= 4'h7;
						end
				/*Msb Read[255:128]*/
				
			4'h7:begin								
               if(Poly_len%2==0)begin			
						b_w_D <=1;
						b_adbus_D <=start_addr-Poly_chunk;
						byte_pos_C<=1'h1;
						end
					 else begin
						b_w_C <=1;
						b_adbus_C <=start_addr-Poly_chunk;
                  byte_pos_C<=1'h0;						
						end  
						
               if(Poly_len==2'h3) begin
                    Sqr<=4'hc;
						  interupt<=1'h1;
                    end						  
                else
                     Sqr <= 4'h8;					
				end
				
				4'h8:begin
				     b_w_D <=1'h0;
					  b_w_C<=1'h0;
				     byte_pos_A <= 1'h1;
						Sqr <= 4'h9;
						
					end
					
					4'h9:begin								
						if(Poly_len%2==1)begin			
							b_w_D <=1;
							b_adbus_D <=start_addr-Poly_chunk+1'h1;
							byte_pos_C<=1'h1;
							end
					 else begin
							b_w_C <=1;
							b_adbus_C <=start_addr-Poly_chunk;
							byte_pos_C<=1'h0;						
							end 
                  Poly_chunk<=Poly_chunk-1'h1;							
                  if(Poly_len[2])begin
                    Sqr<=4'hc; 			
                    interupt<=1'h1;
                  end						  
                  else begin
                     Sqr <= 4'ha;
                     b_adbus_A <= start_addr-(Poly_chunk-1'h1);
                     end							
				end				
				
				4'ha:begin
				   b_w_C<=0;
					b_w_D<=0;
					
               byte_pos_A <= 2'h0;					
					Sqr <= 4'hb;
					end
				/*Msb Read[255:128]*/
				
			4'hb:begin
					Sqr <= 4'hc;
               interupt<=1'h1;					
               b_w_C <=1;
					b_adbus_C <= start_addr-Poly_chunk;      
					byte_pos_C <= 1'h0;					
				end
				
			4'hc:begin
			    Sqr<=4'hd;
			    b_w_C<=1'h0;
			    interupt<=1'h0;
             end	
         4'hd:begin
             cmd_sqr<=1'h0;
           end				 
				
			endcase
	end
						



endmodule
