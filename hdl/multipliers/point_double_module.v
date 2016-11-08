`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: BARC
// Engineer: Deepak and Rahul
// 
// Create Date:    15:05:56 10/09/2014 
// Design Name: 
// Module Name:    point_double_module 
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
//1d 1e(for x3) 26 for y3
// 482  380 390
//changing code here
module point_double_module(
   input wire         clk,
   input wire         interupt_sqr, 
	input wire			 interupt_red, 
	input wire			 interupt_swap, 
	input wire			 interupt_inv, 
	input wire			 interupt_mul,
	input wire   		 interupt_Xor,
	input wire         interupt_transfer,
	
	output reg [2:0]   start_addr,
	output reg [3:0]   command_ECC,            //command for 	ECC primitive operation
	output reg         interupt,           //interupt on completion of Point Addition
	output reg         cmd_double,
	
	
	 output reg       read_write_command,
	 output reg [5:0] read_address,
	 output reg [5:0] write_address,
	 
    output reg command_transfer,	 
	 input wire [9:0] Data_len_Polynomial,
	 input wire [1:0] command
    );
    initial begin
	    cmd_double<=1'h0;
		 interupt<=1'h0;
		 end
		 
		 
	 reg [6:0] fsm;
	 reg [2:0] var;
	 
		 
	always @(posedge clk) begin
		if(command==2'h2) begin
		     fsm<=6'h1;                         //start point doubling
			  cmd_double<=1'h1;
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
						read_address<=6'h6;
						write_address<=6'b010_010;       //transfer y1  to B inner Ram
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
						command_ECC<=4'h2;        //X square
						end
					end
			
			
		
		6'h4:begin
				if(interupt_sqr) begin
					fsm<=6'h5;
					command_ECC<=4'h4;                //reduce Square term
					start_addr<=2'h2;
					end
				else
					command_ECC<=4'h0;
				end	
     
		6'h5:begin
					command_ECC<=4'h0;
					if(interupt_red) begin
						fsm<=6'h6;
						command_transfer<=1'h1;
						read_write_command<=1'h1;
						if(var[1]^var[0])           //store x^2 result in outer Ram
							read_address<=6'b100_010;
						else begin
							if(var[2]||var[1])
								read_address<=6'b011_001;
							else
								read_address<=6'b011_010;
                     end								
						write_address<=6'hf;
						end
					end
		
		6'h6:begin
			command_transfer<=1'h0;
			if(interupt_transfer) begin
				 fsm<=6'h7;
				  command_ECC<=4'h3;      //x Inverse_operation
            start_addr<=4'h3;				
				end
			end
			
			
		6'h7:begin
				command_ECC<=4'h0;
				if(interupt_inv)begin
					fsm<=6'h8;
					command_transfer<=1'h1;
					read_write_command<=1'h1;
					if(var[1]^var[0])
						read_address<=6'b100_010;
					else begin
							if(var[2]||var[1])
								read_address<=6'b011_001;
							else
								read_address<=6'b011_010;
                     end			
					write_address<=6'h12;       //store x inv res       in outer RAM

						end
				end
		
		6'h8:begin			
			if(interupt_transfer) begin            //copy y1 result to inner Ram
			   fsm<=6'h9;
				read_write_command<=1'h0; 
				read_address<=6'h6;
				write_address<=6'b001_010;       
				command_transfer<=1'h1;
				end
			else
				command_transfer<=4'h0;
			end
		
		6'h9:begin
			if(interupt_transfer) begin
				fsm<=6'ha;
				read_write_command<=1'h0; 
				read_address<=6'h12;                      //copy inverse to inner Ram
				write_address<=6'b010_010;       
				command_transfer<=1'h1;
				end
			else
				command_transfer<=1'h0;
			end
		
		6'ha:begin
			command_transfer<=1'h0;
			if(interupt_transfer) begin
				fsm<=6'hb;
				command_ECC<=4'h1;          //Multiplication (y1)*inv X1) cal of lambda
			   end
			end
		
		6'hb:begin
			command_ECC<=4'h0;
			if(interupt_mul)begin
				fsm<=6'hc;
				command_ECC<=4'h4;   //reduce the above term
				start_addr<=3'h2;
				end
			end
			
		6'hc:begin
			command_ECC<=3'h0;
			if(interupt_red)begin
				fsm<=6'hd;
				read_write_command<=1'h1; 
				if(var[1]^var[0])
						read_address<=6'b100_010;
					else begin
							if(var[2]||var[1])
								read_address<=6'b011_001;
							else
								read_address<=6'b011_010;
                     end	         
				write_address<=6'h15;             //store y1/x1 in outer Ram    
				command_transfer<=1'h1;
				end
			end
			
			
			6'hd:begin
			if(interupt_transfer)begin
				fsm<=6'he;
				read_write_command<=1'h0; 
				read_address<=6'h15;         
				write_address<=6'b001_010;             //store y1/x1 in inner Ram    
				command_transfer<=1'h1;
				end
			else
				command_transfer<=3'h0;
			end
			
			
			6'he:begin
			if(interupt_transfer)begin
				fsm<=6'hf;
				read_write_command<=1'h0; 
				read_address<=6'h3;         
				write_address<=6'b010_010;             //store x1 in inner Ram    
				command_transfer<=1'h1;
				end
			else
				command_transfer<=3'h0;
			end
			
			6'hf:begin
					command_transfer<=1'h0;
			     if(interupt_transfer) begin
						fsm<=6'h10;
						start_addr<=3'h3;
						command_ECC<=4'h6;                  //x1+y1/x1         
						end
			     end
				  
			6'h10:begin
					command_ECC<=3'h0;
					if(interupt_Xor) begin
						fsm<=6'h11;
						read_write_command<=1'h1;
					   read_address<=6'b011_010;
					   write_address<=6'hc;       //store xor result  x1+y1/x1
						command_transfer<=1'h1;
						end
					end
			
			6'h11:begin
				
				if(interupt_transfer) begin
					fsm<=6'h29;
					read_write_command<=1'h0; 
					read_address<=6'hc;         
					write_address<=6'b001_010;             //store lambda  in inner ram     
					command_transfer<=1'h1;
					end
				else
					command_transfer<=1'h0;
			end
		
		 
		  6'h29:begin
				command_transfer<=1'h0;
				if(interupt_transfer) begin
					command_ECC<=4'h2;   //square of lambda
					start_addr<=3'h3;
					fsm<=6'h12;
					end
				end
			
			6'h12:begin
				
				if(interupt_sqr)begin
					fsm<=6'h13;
	            command_ECC<=4'h4;          //reduce Lambda square
					start_addr<=3'h2;
					end
				else
				   command_ECC<=4'h0;
					end
			
			6'h13:begin
				command_ECC<=4'h0;
				if(interupt_red)begin
					fsm<=6'h14;
					read_write_command<=1'h1; 
					if(var[1]^var[0])          
							read_address<=6'b100_010;
						else begin
							if(var[2]||var[1])
								read_address<=6'b011_001;
							else
								read_address<=6'b011_010;
                     end	        
					write_address<=6'h18;             //store lambda^2  in outer ram     
					command_transfer<=1'h1;
				   end
			end
			
			6'h14:begin		
					if(interupt_transfer)begin
						read_write_command<=1'h0; 
						read_address<=6'h18;         
						write_address<=6'b010_010;             //store lambda sqr in inner ram     
						command_transfer<=1'h1;
						fsm<=6'h15;
						end
					else
						command_transfer<=1'h0;					
					end
			
			
			6'h15:begin
					command_transfer<=1'h0;
				   if(interupt_transfer)begin
						command_ECC<=4'h6;     //xor lamda^2 +lambda
						start_addr<=3'h3;
						fsm<=6'h16;
						end
					end
			
			6'h16:begin
					command_ECC<=4'h0;
					if(interupt_Xor)begin
						fsm<=6'h1a;
						read_write_command<=1'h1; 
						read_address<=6'b011_010;         
						write_address<=6'h1b;             //store lambda^2+lambda xor in outer ram     
						command_transfer<=1'h1;
		            end
				end
			
			6'h17:begin                                  //remove this cycle
	
					if(interupt_transfer)begin
						read_write_command<=1'h0; 
						read_address<=6'h0;         
						write_address<=6'b010_010;             //store 1 in inner ram     
						command_transfer<=1'h1;
					   fsm<=6'h18;
						end
					else
						command_transfer<=1'h0;					
					end
			
			
			6'h18:begin                               //remove this cycle
					command_transfer<=1'h0;
				   if(interupt_transfer)begin
						command_ECC<=4'h6;     //xor lamda +1
						start_addr<=3'h3;
						fsm<=6'h19;
						end
					end
					
		    6'h19:begin                             //remove this cycle
			    command_ECC<=4'h0;
				 if(interupt_Xor) begin
						fsm<=6'h1a;
						read_write_command<=1'h1; 
						read_address<=6'b011_010;         
						write_address<=6'h1e;             //store 1+lambda xor in outer ram     
						command_transfer<=1'h1;
						end
					end
				
				6'h1a:begin
					if(interupt_transfer)begin
						fsm<=6'h1b;
						read_write_command<=1'h0; 
						read_address<=6'h1b;         
						write_address<=6'b010_010;             //store lambda^2+lambda xor in iner ram     
						command_transfer<=1'h1;
						end
					else
						command_transfer<=1'h0;
						end
				
				6'h1b:begin
					if(interupt_transfer)begin
						fsm<=6'h1c;
						read_write_command<=1'h0; 
						read_address<=6'h9;         
						write_address<=6'b001_010;            //store a in inner Ram    
						command_transfer<=1'h1;
						end
					else
						command_transfer<=1'h0;
						end
				
				 6'h1c:begin
				   command_transfer<=1'h0;
					if(interupt_transfer)begin
						fsm<=6'h1d;
						command_ECC<=4'h6;                  //Xor lambda^2+lambda+a 
						end
					end
					
					6'h1d:begin
					command_ECC<=4'h0;
					if(interupt_Xor) begin
						fsm<=6'h1e;
						read_write_command<=1'h1; 
						read_address<=6'b011_010;         
						write_address<=6'h3;                 // x3 or store result Xor lambda^2+lambda+a 
						command_transfer<=1'h1;
						end
					end
						
				6'h1e:begin
					
					if(interupt_transfer)begin
						read_write_command<=1'h0; 
						read_address<=6'h3;         
						write_address<=6'b001_010;                 //store x3 in inner Ram 
						command_transfer<=1'h1;
						fsm<=6'h1f;
						end
					else
						command_transfer<=1'h0;
					end
				
				
					6'h1f:begin
					
						if(interupt_transfer)begin
							read_write_command<=1'h0; 
							read_address<=6'hc;         
							write_address<=6'b010_010;                 //store lambda in inner Ram 
							command_transfer<=1'h1;
							fsm<=6'h20;
							end
						else
							command_transfer<=1'h0;
						end
					 
					 
					 6'h20:begin
						command_transfer<=1'h0;
						if(interupt_transfer) begin
						   fsm<=6'h21;
							command_ECC<=4'h1;            //multi (lambda)*X3
							end
						end
						
					6'h21:begin
						
						if(interupt_mul)begin
							command_ECC<=6'h4;
							fsm<=6'h22;                //reduction (lambda)*X3
							start_addr<=3'h2;
							end
						else
							command_ECC<=4'h0;
						end
						
						6'h22:begin
							command_ECC<=4'h0;
							if(interupt_red) begin
								read_write_command<=1'h1; 
								if(var[1]^var[0])          
									read_address<=6'b100_010;
								else begin
							if(var[2]||var[1])
								read_address<=6'b011_001;
							else
								read_address<=6'b011_010;
                     end	        
								write_address<=6'h24;                 //store (lambda)*X3 in outer Ram 
								command_transfer<=1'h1;
								fsm<=6'h23;
								end
						end
						
						   
						
						6'h23:begin
							if(interupt_transfer)begin
								read_write_command<=1'h0; 
								read_address<=6'h24;         
								write_address<=6'b001_010;                 //store (lambda)*X3 in inner Ram 
								command_transfer<=1'h1;
								fsm<=7'h32;
								end
							else
								command_transfer<=1'h0;	
							end
						
						6'h32:begin
							if(interupt_transfer)begin
								read_write_command<=1'h0; 
								read_address<=6'h3;         
								write_address<=6'b010_010;                 //store X3 in inner Ram 
								command_transfer<=1'h1;
								fsm<=7'h33;
								end
							else begin
								command_transfer<=1'h0;	
								end
						end

						6'h33:begin

							command_transfer<=1'h0;
								if(interupt_transfer)begin 
									command_ECC<=4'h6;
									fsm<=6'h34;                 //xor (lambda)*X3+X3
									start_addr<=4'h3;
									end
							end
						
						6'h34:begin
							command_ECC<=4'h0;
							if(interupt_Xor) begin
								fsm<=6'h35;
								read_write_command<=1'h1; 
								read_address<=6'b011_010;         
								write_address<=6'h1e;                 // store (lambda)*X3+X3 in address 1e of outer ram
								command_transfer<=1'h1;
								end
							
						end
						
						6'h35:begin
							if(interupt_transfer)begin
								read_write_command<=1'h0; 
								read_address<=6'h1e;         
								write_address<=6'b001_010;                 //store (lambda)*X3+X3 into inner ram 
								command_transfer<=1'h1;
								fsm<=6'h24;
								end
								else
									command_transfer<=1'h0;
						end
							
							6'h24:begin
							if(interupt_transfer)begin
								read_write_command<=1'h0; 
								read_address<=6'hf;         
								write_address<=6'b010_010;                 //store x1^2 in inner Ram 
								command_transfer<=1'h1;
								fsm<=6'h25;
								end
								else
									command_transfer<=1'h0;	
							end
							
					6'h25:begin
							command_transfer<=1'h0;
							if(interupt_transfer)begin 
								command_ECC<=4'h6;
								fsm<=6'h26;                 //xor x1^2+(lambda)*X3
								start_addr<=4'h3;
								end
							end
					
					6'h26:begin
						command_ECC<=4'h0;
						if(interupt_Xor)begin
								read_write_command<=1'h1; 
								read_address<=6'b011_010;         
								write_address<=6'h6;                 //store y3 in outer Ram 
								command_transfer<=1'h1;
								fsm<=6'h27;
								end
						end
					
					
					6'h27:begin
						command_transfer<=1'h0;
						if(interupt_transfer) begin	
							fsm<=6'h28;
							interupt<=1'h1;
							end
						end	
					
					6'h28:begin
							cmd_double<=1'h0;
							interupt<=1'h0;
							fsm<=6'h30;
							end
							
					6'h30:begin
						fsm<=6'h31;
					end
						
										
   endcase			
	end
	endmodule 
