`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: BARC	
// Engineer: Rahul Yamasani and Deepak Kapoor
// 
// Create Date:    10:04:13 08/18/2014 
// Design Name: 
// Module Name:    dma_sample_code 
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
module dma_module_code#(
	parameter DATA = 256,
	parameter ADDR = 3,
	parameter param=6,
	parameter SIZE=64,
	parameter MUL=3'b001,
	parameter XOR=3'b111,
	parameter SQR=3'b010,
	parameter REDUCTION =3'b100,
	parameter INVERSE =3'b011)(                               
	
	input  wire              clk,
	input  wire              a_w,                               
	input	 wire [5:0]        a_adbus,
	input  wire [(DATA-1):0] a_data_in, 
	output wire	[(DATA-1):0] a_data_out,  
	
	input  wire               b_w_A,  
	input  wire [(ADDR-1):0]  b_adbus_A,
   input  wire [1:0]         byte_pos_A,	
	output wire [(DATA-1):0]  b_data_out_A,
	input  wire [(DATA-1):0]  b_data_in_A,
 	
	input  wire                  b_w_B,  
	input  wire [(ADDR-1):0]     b_adbus_B,
   input  wire [1:0]            byte_pos_B,
   input  wire [(DATA-1):0]     b_data_in_B,	
	output wire 	[(DATA-1):0]  b_data_out_B,
	
	
	input  wire                  b_w_C,  
	input  wire [(ADDR-1):0]     b_adbus_C,
	input  wire [1:0]            byte_pos_C,
	output wire [(DATA-1):0]     b_data_out_C,
   input  wire [(DATA-1):0]     b_data_in_C,	
		
	input  wire                  b_w_D,  
	input  wire [(ADDR-1):0]     b_adbus_D,
	input  wire [1:0]            byte_pos_D,
	input  wire [(DATA-1):0]     b_data_in_D,
	output wire [(DATA-1):0]     b_data_out_D,
	
	input  wire [135:0]        A1,               //change
	input  wire [135:0]        B1,
	input  wire [2:0]          select_line,
 
	output      [135:0]        C_Out1,
	output      [127:0]        D_Out1,
	
	output  wire  [3:0]        command,
	input   wire  [3:0]        b_command,
	
	input   wire               cmd_sqr,
	input   wire               cmd_mul,
	input   wire               cmd_red,
	input   wire               cmd_swap,
	input   wire               cmd_inv,
	input   wire               cmd_xor,
	
	input    wire   [2:0]      start_addr,
	input    wire              select_Ram_C,
   input    wire              select_Ram_D
    );
	 
	 wire [255:0] A,B;
	 wire [135:0] C_Out;
	 wire [127:0] D_Out;
	 wire [255:0] b_data_in_C1,b_data_in_D1,b_data_in_A1,b_data_in_B1;
	 reg [9:0] count;
	 reg [2:0] fsm,b_adbus_A1;
	 wire [2:0] b_adbus_A2;   //adress bus goes into Ram_interface
	 
	 
	
	//Ram_interface
		Ram_Interface_Module Ram_interface (
			.clk(clk), 
			.a_w(a_w), 
			.a_adbus(a_adbus), 
			.a_data_in(a_data_in), 
			.a_data_out(a_data_out),  
			.b_w_A(b_w_A), 
			.b_adbus_A(b_adbus_A2), 
			.b_data_in_A(b_data_in_A1), 
			.b_data_out_A(b_data_out_A), 
			.b_w_B(b_w_B), 
			.b_adbus_B(b_adbus_B), 
			.b_data_in_B(b_data_in_B1), 
			.b_data_out_B(b_data_out_B), 
			.b_w_C(b_w_C), 
			.b_adbus_C(b_adbus_C), 
			.b_data_in_C(b_data_in_C1), 
			.b_data_out_C(b_data_out_C),
         .b_w_D(b_w_D), 
			.b_adbus_D(b_adbus_D), 
			.b_data_in_D(b_data_in_D1), 
			.b_data_out_D(b_data_out_D),
			.b_command(b_command),
			.command(command)
			
		);

	lower_bit_implementation lower_bit (
			.A(A), 
			.B(B), 
			.select_line(select_line), 
			.C_Out(C_Out), 
			.D_Out(D_Out)
		);
		
	assign A =(cmd_sqr && byte_pos_A==2'h1)?({128'h0,b_data_out_A[255:128]}):
				 (cmd_sqr && byte_pos_A == 2'h0)?({128'h0,b_data_out_A[127:0]}):
				 (cmd_xor)?b_data_out_A:
				 (cmd_mul||cmd_red)?{120'h0,A1}:255'hz;
				 
	assign B = (cmd_mul||cmd_red)?{120'h0,B1}:
	            (cmd_xor)?b_data_out_B:255'hz;			 
				 
	assign C_Out1 = C_Out;   //C_Out is MSB
	assign D_Out1 = D_Out;   //D_Out1 is LSb


	assign b_data_in_C1 =(cmd_sqr)?({C_Out[127:0],D_Out}):
	                     (cmd_xor?({C_Out[127:0],D_Out}):
				            ((cmd_mul||cmd_red)?b_data_in_C:256'hz));


	assign b_data_in_D1 =(cmd_sqr)?({C_Out[127:0],D_Out}):
	                     (cmd_xor?({C_Out[127:0],D_Out}):
				           ((cmd_mul||cmd_red)?b_data_in_D:256'hz));
				
				
				
		assign	b_data_in_A1= (cmd_swap && select_Ram_C)?b_data_out_C:
						           ((cmd_swap && select_Ram_D)?b_data_out_D:b_data_in_A);
									  
		assign	b_data_in_B1= (cmd_swap && select_Ram_C)?b_data_out_C:
						           ((cmd_swap && select_Ram_D)?b_data_out_D:b_data_in_B);
		
		
		assign b_adbus_A2= (cmd_inv && (!cmd_sqr && !cmd_mul  && !cmd_swap))?b_adbus_A1:b_adbus_A;
		 
							 							
endmodule
