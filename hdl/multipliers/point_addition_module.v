`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Barc
// Engineer: Rahul
// 
// Create Date:    14:51:47 10/09/2014 
// Design Name: 
// Module Name:    point_addition_module 
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

//2'h2 for point double

module point_addition_module(
   input wire         clk,
   input wire         interupt_sqr, 
	input wire			 interupt_red, 
	input wire			 interupt_swap, 
	input wire			 interupt_inv, 
	input wire			 interupt_mul,
	input wire   		 interupt_Xor,
	input wire         interupt_transfer,
	
	output reg [2:0]   	start_addr,
	output reg  [3:0]  	command_ECC,            //command for 	ECC primitive operation
	output reg         	interupt,           //interupt on completion of Point Addition
	output reg        	cmd_addition,
	
	
	 output reg       		read_write_command,          //enable to transfer data to inner Ram
	 output reg [5:0] 		read_address,
	 output reg [5:0] 		write_address,
    output reg 			   command_transfer,	
	 input wire [9:0]       Data_len_Polynomial,
	 input wire [1:0] 	   command          //cmd to perform point doubling
    );
	 
    initial begin
	    cmd_addition<=1'h0;
		 interupt<=1'h0;
		 fsm<=6'h0;
		 end
		 
	reg [5:0] fsm;
	reg [2:0] var;
		
	always @(posedge clk) begin	
	
		if(command==2'h1) begin
		     fsm<=6'h1;                         //start point addition
			  cmd_addition<=1'h1;
			  end
			  
	      case (fsm)
				6'h1:begin
					var<=Data_len_Polynomial/8'h80;
					read_write_command<=1'h0;
					read_address<=6'h3;
					write_address<=6'b001_010;       //transfer X1 to A inner Ram
					command_transfer<=1'h1;
					fsm<=6'h2;
					end
					
			 6'h2:begin
					if(interupt_transfer) begin
						fsm<=6'h3;
						read_write_command<=1'h0;
						read_address<=6'h21;
						write_address<=6'b010_010;       //transfer x2  to B inner Ram
						command_transfer<=1'h1;
						end
					else
						command_transfer<=1'h0;
					end
			
			6'h3:begin
					command_transfer<=1'h0;
			      if(interupt_transfer) begin
						fsm<=6'h4;
					   start_addr<=3'h3;
						command_ECC<=4'h6;        //X1+x2 Xor
						end
					end
			
			
		
		6'h4:begin
				if(interupt_Xor) begin
					fsm<=6'h5;                //transfer to outer Ram
	            read_write_command<=1'h1;
					read_address<=6'b011_010;
					write_address<=6'hc;      
					command_transfer<=1'h1;
					end
					command_ECC<=4'h0;
				end	
     
		6'h5:begin
					
					if(interupt_transfer) begin
					   fsm<=6'h6;
						command_transfer<=1'h1;
						read_write_command<=1'h0;
						read_address<=6'hc;   
						write_address<=6'b001_101;     //transfer X1+X2 to inner Ram
						end
					else
						command_transfer<=4'h0;
					end
		
		6'h6:begin
			
			if(interupt_transfer) begin
				fsm<=6'h7;
				command_transfer<=1'h1;
				read_write_command<=1'h0;
				read_address<=6'h9;        //transfer a to inner Ram
				write_address<=6'b010_101;
				end
			else
				command_transfer<=1'h0;
			end
			
			
		6'h7:begin
			command_transfer<=1'h0;
			if(interupt_transfer) begin
				fsm<=6'h8;
				command_ECC<=4'h6;       // xor x1+x2+a
				start_addr<=3'h6;
				end
			end
			
			
		6'h8:begin
				command_ECC<=4'h0;
				if(interupt_Xor)begin
					fsm<=6'h9;
					command_transfer<=1'h1;
					read_write_command<=1'h1;
					read_address<=6'b011_101;
					write_address<=6'hf;       //store xor x1+x2+a in outer Ram

						end
				end
		
		6'h9:begin			
			if(interupt_transfer) begin            
			   fsm<=6'ha;
				command_ECC<=4'h3;              //inverse (x1+x2) 
				start_addr<=3'h6;
				end
				command_transfer<=4'h0;
			end
		
		6'ha:begin
			command_ECC<=4'h0;
			if(interupt_inv) begin
				fsm<=6'hb;
				read_write_command<=1'h1; 
				if(var[1]^var[0])
						read_address<=6'b100_101;
					else begin
							if(var[2]||var[1])
								read_address<=6'b011_100;
							else
								read_address<=6'b011_101;
                     end                      //copy inverse to outer Ram
				write_address<=6'h12;       
				command_transfer<=1'h1;
				end
			else
				command_transfer<=1'h0;
			end
		
		6'hb:begin
			if(interupt_transfer) begin
				fsm<=6'hc;
				read_write_command<=1'h0; 
				read_address<=6'h6;                      //copy y1 to inner Ram
				write_address<=6'b010_101;       
				command_transfer<=1'h1;        
			   end
			else
				command_transfer<=1'h0;
			end
		
		6'hc:begin
			if(interupt_transfer) begin
				fsm<=6'hd;
				read_write_command<=1'h0; 
				read_address<=6'h27;                      //copy y2 to inner Ram
				write_address<=6'b001_101;       
				command_transfer<=1'h1;        
			   end
			else
				command_transfer<=1'h0;
			end
			
		6'hd:begin
			command_transfer<=1'h0;
			if(interupt_transfer)begin
				fsm<=6'he;
				command_ECC<=4'h6;
				start_addr<=3'h6;                 //xor y1+y2
				end
			end
			
			
			6'he:begin
			if(interupt_Xor)begin
				fsm<=6'hf;
				read_write_command<=1'h1; 
				read_address<=6'b011_101;         
				write_address<=6'h15;             //store y1+y2 in outer Ram    
				command_transfer<=1'h1;
				end
			else
				command_ECC<=4'h0;
			end
			
			
			6'hf:begin
			if(interupt_transfer)begin
				fsm<=6'h10;
				read_write_command<=1'h0; 
				read_address<=6'h15;         
				write_address<=6'b010_101;             //store y1+y2 in inner Ram    
				command_transfer<=1'h1;
				end
			else
				command_transfer<=3'h0;
			end
			
			6'h10:begin
			     if(interupt_transfer) begin
						fsm<=6'h11;
						read_write_command<=1'h0; 
						read_address<=6'h12;         
						write_address<=6'b001_101;             //store x1+x2  inverse in inner Ram    
						command_transfer<=1'h1;
						end
				else
				command_transfer<=3'h0;
			     end
				  
			6'h11:begin
					command_transfer<=3'h0;
					if(interupt_transfer) begin
						fsm<=6'h12;
						command_ECC<=4'h1;          //Mulltiply (y1+y2) * Inv(x1+x2)
						start_addr<=3'h6;
						end
					end
			
			6'h12:begin
				if(interupt_mul) begin
					fsm<=6'h13;
					command_ECC<=4'h4;
					start_addr<=3'h5;          //reduce (y1+y2) * Inv(x1+x2)
					end
				else
					command_ECC<=4'h0;
			end
		
		 
		  6'h13:begin
				command_ECC<=4'h0;
				if(interupt_red) begin
					fsm<=6'h14;
					read_write_command<=1'h1;
					if(var[1]^var[0])
						read_address<=6'b100_101;
					else begin
							if(var[2]||var[1])
								read_address<=6'b011_100;
							else
								read_address<=6'b011_101;
                     end
					write_address<=6'h18;             //store lambda in outer Ram    
					command_transfer<=1'h1;
					end
				end
			
			6'h14:begin
				if(interupt_transfer)begin
					fsm<=6'h15;
					read_write_command<=1'h0; 
					read_address<=6'h18;         
					write_address<=6'b001_101;             //store lambda in inner Ram    
					command_transfer<=1'h1;
					end
				else
				   command_transfer<=4'h0;
					end
			
			6'h15:begin
				command_transfer<=4'h0;
				if(interupt_transfer)begin
					fsm<=6'h16;
					command_ECC<=4'h2;            //cal lambda^2
					start_addr<=3'h6;
				   end
			end
			
			6'h16:begin		
					if(interupt_sqr)begin
						fsm<=6'h17;
						command_ECC<=4'h4;              //reduce lambda sqr
						start_addr<=3'h5;
						end
					else
						command_ECC<=4'h0;					
					end
			
			
			6'h17:begin
					command_ECC<=1'h0;
				   if(interupt_red)begin
						fsm<=6'h18;
						read_write_command<=1'h1; 
						if(var[1]^var[0])
							read_address<=6'b100_101;
					   else begin
							if(var[2]||var[1])
								read_address<=6'b011_100;
							else
								read_address<=6'b011_101;
                     end         
						write_address<=6'h1b;             //store lambda^2 in outer Ram    
						command_transfer<=1'h1;
						end
					end
			
			6'h18:begin
					command_transfer<=1'h0;
					if(interupt_transfer)begin
						fsm<=6'h19;
						read_write_command<=1'h0; 
						read_address<=6'h1b;         
						write_address<=6'b010_101;             //store lambda^2 in inner ram     
						command_transfer<=1'h1;
		            end
				end
			
			6'h19:begin	
					if(interupt_transfer)begin
						command_ECC<=4'h6;
						start_addr<=3'h6;                //xor lambda^2+lambda
					   fsm<=6'h1a;                
						end
						command_transfer<=1'h0;					
					end
			
			
			6'h1a:begin
					command_ECC<=4'h0;
				   if(interupt_Xor)begin
						read_write_command<=1'h1; 
						read_address<=6'b011_101;         
						write_address<=6'hc;             //store lambda^2 +lambda in outer ram     
						command_transfer<=1'h1;
						fsm<=6'h1b;
						end
					end
					
		    6'h1b:begin
				 if(interupt_transfer) begin
						fsm<=6'h1c;
						read_write_command<=1'h0; 
						read_address<=6'hc;         
						write_address<=6'b001_010;                  
						command_transfer<=1'h1;        //store lambda^2+lambda in inner Ram
						end
					else
						command_transfer<=1'h0;
					end
				
				6'h1c:begin
					if(interupt_transfer)begin
						fsm<=6'h1d;
						read_write_command<=1'h0; 
						read_address<=6'hf;         
						write_address<=6'b010_010;             //store x1+x2+a in iner ram     
						command_transfer<=1'h1;
						end
					else
						command_transfer<=1'h0;
						end
				
				6'h1d:begin
					if(interupt_transfer)begin
						fsm<=6'h1e;
						command_ECC<=4'h6;            //calculate x3
						start_addr<=3'h3;
						end
	
						command_transfer<=1'h0;
						end
				
				 6'h1e:begin
				   command_ECC<=1'h0;
					if(interupt_Xor)begin
						fsm<=6'h1f;
						read_write_command<=1'h1; 
						read_address<=6'b011_010;         
						write_address<=6'h21;             //store x3 in outer ram     
						command_transfer<=1'h1;
						end
					end
					
					6'h1f:begin
					if(interupt_transfer) begin
						fsm<=6'h20;
						read_write_command<=1'h0; 
						read_address<=6'h21;         
						write_address<=6'b001_010;                 // x3 in inner Ram 
						command_transfer<=1'h1;
						end
					else
						command_transfer<=1'h0;
					end
						
				6'h20:begin				
					if(interupt_transfer)begin
						read_write_command<=1'h0; 
						read_address<=6'h3;         
						write_address<=6'b010_010;                 //store x1 in inner Ram 
						command_transfer<=1'h1;
						fsm<=6'h21;
						end
					else
						command_transfer<=1'h0;
					end
				
				
					6'h21:begin
						if(interupt_transfer)begin
							command_ECC<=4'h6;         //Xor x1+x3
							start_addr<=3'h3;
							fsm<=6'h22;
							end
							command_transfer<=1'h0;
						end
					 
					 
					 6'h22:begin
						command_ECC<=3'h0;
						if(interupt_Xor) begin
						   fsm<=6'h23;
							read_write_command<=1'h1; 
							read_address<=6'b011_010;         
							write_address<=6'h24;             //store x3+x1 in outer ram     
							command_transfer<=1'h1;
							end
						end
						
					6'h23:begin						
						if(interupt_transfer)begin							
							fsm<=6'h24;                
							read_write_command<=1'h0; 
							read_address<=6'h24;         
							write_address<=6'b010_101;                 //store x1+x3 in inner Ram 
							command_transfer<=1'h1;
							end
						else
							command_transfer<=1'h0;
						end
						
						6'h24:begin
							command_transfer<=1'h0;
							if(interupt_transfer) begin
								command_ECC<=4'h1;      //mul lambda*(x1+x3)
								start_addr<=3'h6;
								fsm<=6'h25;
								end
						end				   
						
						6'h25:begin
							if(interupt_mul)begin
								command_ECC<=4'h4;       //reduce above mul 
								start_addr<=3'h5;
								fsm<=6'h26;
								end
							else
								command_ECC<=4'h0;	
							end
							
							
							6'h26:begin
								command_ECC<=4'h0;
							if(interupt_red)begin
								read_write_command<=1'h1; 
								if(var[1]^var[0])
									read_address<=6'b100_101;
								else begin
							if(var[2]||var[1])
								read_address<=6'b011_100;
							else
								read_address<=6'b011_101;
                     end         
								write_address<=6'h2a;                 //store lambda*(x1+x3) in outer Ram
								command_transfer<=1'h1;
								fsm<=6'h28;
								end
							end
							
					6'h28:begin							
							if(interupt_transfer)begin
								fsm<=6'h29;
								read_write_command<=1'h0; 
								read_address<=6'h6;         
								write_address<=6'b010_010;   //store y1 in inner Ram
								command_transfer<=1'h1;
								end
							else
								command_transfer<=1'h0;
							end
					
					6'h29:begin
						command_transfer<=1'h0;
						if(interupt_transfer)begin
								fsm<=6'h2a;
								command_ECC<=4'h6;
								start_addr<=3'h3;            //xor y1+x3
								end
						end
					
					
					6'h2a:begin
						command_ECC<=1'h0;
						if(interupt_Xor) begin	
							fsm<=6'h2b;
							read_write_command<=1'h1; 
							read_address<=6'b011_010;         
							write_address<=6'h2d;                 //store X3+Y1 in outer Ram
							command_transfer<=1'h1;
							end
						end
					
					 6'h2b:begin
			
						if(interupt_transfer) begin
						   fsm<=6'h2c;
							read_write_command<=1'h0; 
							read_address<=6'h2a;         
							write_address<=6'b010_010;             //store lambda*(x1+x3) in inner ram     
							command_transfer<=1'h1;
							end
						else
							command_transfer<=1'h0;
						end
						
					6'h2c:begin						
						if(interupt_transfer)begin							
							fsm<=6'h2d;                
							read_write_command<=1'h0; 
							read_address<=6'h2d;         
							write_address<=6'b001_010;                 //store x3+y2 in inner Ram 
							command_transfer<=1'h1;
							end
						else
							command_transfer<=1'h0;
						end
					
					6'h2d:begin
							command_transfer<=1'h0;
							if(interupt_transfer)begin
								command_ECC<=4'h6;
								start_addr<=3'h3;          //xor to cal Y3   
								fsm<=6'h2e;
								end
							end
					
					6'h2e:begin
							command_ECC<=4'h0;
							if(interupt_Xor)begin
								fsm<=6'h2f;
								read_write_command<=1'h1; 
								read_address<=6'b011_010;         
								write_address<=6'h27;                 //store y3 in outer Ram 
								command_transfer<=1'h1;		
								end
							end
						
					6'h2f:begin
						command_transfer<=1'h0;
						if(interupt_transfer) begin	
							fsm<=6'h30;
							interupt<=1'h1;
							end
						end
					
					6'h30:begin
							cmd_addition<=1'h0;
							interupt<=1'h0;
							fsm <= 6'h31;
							end		
					6'h31:begin
							fsm <= 6'h32;
							end
			 
										
					endcase
	end  
endmodule
