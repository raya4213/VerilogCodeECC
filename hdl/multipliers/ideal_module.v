`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Rahul Yamasani
// 
// Create Date:    12:45:17 08/21/2014 
// Design Name: 
// Module Name:    ideal_module   (modified)
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
module sequential_state_module#(
parameter DATA=256,
parameter SQR = 3'b010,
parameter MUL = 3'b001,
parameter RED = 3'b100
)(
   input  wire               clk,
	input  wire               a_w,                               
	input	 wire  [5:0]        a_adbus,
	input  wire  [(DATA-1):0] a_data_in, 
	output wire	[(DATA-1):0] a_data_out,
   input   wire     [3:0]    b_command,	
	input   wire     [2:0]	  start_addr,
	input   wire      [2:0]   write_addr,
	
	output  wire              interupt_sqr,
	output  wire              interupt_red,
	output  wire              interupt_swap,
	output  wire              interupt_mul,
	output  wire              interupt_Xor,
	
	
	input   wire              cmd_inv,
	input  wire               select_Ram_C_Or_D,
	input  wire               select_Ram_A_Or_B,

	input wire [1:0]          numbr_of_chunk,
	output wire  [3:0]        command ,

	input wire [9:0]       Data_len_Polynomial,
   input wire [63:0]      Data_Polynomial	
    );

  wire [1:0] byte_pos_A,byte_pos_B,byte_pos_C,byte_pos_D;
  wire [2:0] b_adbus_A,b_adbus_B,b_adbus_C,b_adbus_D;
  wire [(DATA-1):0] b_data_out_A,b_data_out_B,b_data_out_C,b_data_out_D;
  
  wire [127:0] Core_Lsb,Data_64_2_Chunk;
  wire [135:0] Core_Msb;
  wire [2:0] select_line;
 
  
  
  wire [(DATA-1):0] C_data_in1,D_data_in1,A_data_in1,B_data_in1;
  wire [135:0] Core_A,Core_B;
  reg byte_pos_Reduction;
  wire cmd_sqr,cmd_red,cmd_mul;
  wire b_w_A,b_w_B,b_w_C,b_w_D;
			
	dma_module_code dma (
	
		.clk(clk), 
		.a_w(a_w), 
		.a_adbus(a_adbus), 
		.a_data_in(a_data_in), 
		.a_data_out(a_data_out), 
		
		.b_w_A(b_w_A), 
		.b_adbus_A(b_adbus_A), 
		.byte_pos_A(byte_pos_A), 
		.b_data_out_A(b_data_out_A),
		.b_data_in_A(A_data_in1),
		
		.b_w_B(b_w_B), 
		.b_adbus_B(b_adbus_B), 
		.byte_pos_B(byte_pos_B), 
		.b_data_out_B(b_data_out_B), 
		.b_data_in_B(B_data_in1),
		
		.b_w_C(b_w_C), 
		.b_adbus_C(b_adbus_C), 
		.byte_pos_C(byte_pos_C), 
		.b_data_in_C(C_data_in1),
		.b_data_out_C(b_data_out_C), 
		
		.b_w_D(b_w_D), 
		.b_adbus_D(b_adbus_D), 
		.byte_pos_D(byte_pos_D),
       .b_data_in_D(D_data_in1),		
		.b_data_out_D(b_data_out_D),
		 
		 .start_addr(start_addr),
		/*core variable*/
		.A1(Core_A), 
		.B1(Core_B), 
		.select_line(select_line), 
		.C_Out1(Core_Msb),
		.D_Out1(Core_Lsb), 
		
		.command(command),
		.b_command(b_command),     //address bus for command
		
		.cmd_red(cmd_red),
		.cmd_mul(cmd_mul),
		.cmd_sqr(cmd_sqr),
		.cmd_swap(cmd_swap),
		.cmd_inv(cmd_inv),
		.cmd_xor(cmd_Xor),

		.select_Ram_C(select_Ram_C_DMA),
		.select_Ram_D(select_Ram_D_DMA)
	);
	
	wire [2:0] b_adbus_A_sqr,b_adbus_C_sqr,b_adbus_D_sqr;
	wire  byte_pos_A_sqr,byte_pos_C_sqr;
	wire b_w_C_sqr,b_w_D_sqr;
	wire [2:0] select_line_sqr;
	
	
	Square_571 sequential_square (
	      .clk(clk), 
			.b_adbus_A(b_adbus_A_sqr), 
			.byte_pos_A(byte_pos_A_sqr),
			
			.b_w_C(b_w_C_sqr), 
			.b_adbus_C(b_adbus_C_sqr), 
			.byte_pos_C(byte_pos_C_sqr),
			
			.b_w_D(b_w_D_sqr), 
			.b_adbus_D(b_adbus_D_sqr), 
			
			.command(command),
			.cmd_sqr(cmd_sqr),
			
			.start_addr(start_addr),
			.select_line(select_line_sqr),
			.interupt(interupt_sqr),
			
			.Data_len_Polynomial (Data_len_Polynomial)  //register for length of a polynomial
		);
		
		
	wire [2:0] b_adbus_B_red,b_adbus_C_red,b_adbus_D_red;
	wire [1:0] byte_pos_C_red;
	wire [255:0] b_data_in_C_red,b_data_in_D_red;
	wire b_w_C_red,b_w_D_red;
	wire [135:0] A1_red,B1_red;
	wire [2:0] select_line_red;
	
	reduction_256_module seq_reduction ( 
		 .Data_Polynomial(Data_Polynomial),
		
		.b_w_C(b_w_C_red), 
		.b_adbus_C(b_adbus_C_red), 
		.b_data_out_C(b_data_out_C), 
		
		.b_data_in_C(b_data_in_C_red), 
		.b_w_D(b_w_D_red), 
		.b_adbus_D(b_adbus_D_red), 
		.b_data_in_D(b_data_in_D_red), 
		.b_data_out_D(b_data_out_D), 
		
		.clk(clk), 
		.start_addr(start_addr), 
		
		.A1(A1_red), 
		.B1(B1_red), 
		.select_line(select_line_red), 
		.D_Out1(Core_Msb), 
		.command(command),
		.cmd_red(cmd_red),
		
		.interupt(interupt_red)
	);
	
	wire [2:0] b_adbus_A_mul,b_adbus_B_mul,b_adbus_C_mul,b_adbus_D_mul;
	wire b_w_C_mul,b_w_D_mul;
	wire [2:0] select_line_mul;
	wire [127:0] A1_mul,B1_mul;
	wire [255:0] b_data_in_C_mul,b_data_in_D_mul;
	
	multiplication_recursive_module seq_multiplication (
		.clk(clk), 
		.b_data_out_A(b_data_out_A), 
		.b_data_out_B(b_data_out_B), 
		
		.Mul_A(A1_mul), 
		.Mul_B(B1_mul), 
		
		.Mul_out_lsb(Core_Lsb), 
		.Mul_out_msb(Core_Msb[127:0]),
		
		.command(command),
		.cmd_mul(cmd_mul),
		
		.start_addr(start_addr), 
		.select_line(select_line_mul), 
		.b_adbus_A(b_adbus_A_mul), 
		.b_adbus_B(b_adbus_B_mul), 
		.b_adbus_C(b_adbus_C_mul), 
		.b_adbus_D(b_adbus_D_mul), 
		
		.b_data_in_D(b_data_in_D_mul), 
		.b_data_in_C(b_data_in_C_mul), 
		
		.b_w_C(b_w_C_mul), 
		.b_w_D(b_w_D_mul),
		.interupt(interupt_mul),
		.Data_len_Polynomial (Data_len_Polynomial)
	);
 		
	wire [2:0] b_adbus_C_swap,b_adbus_D_swap,b_adbus_A_swap,b_adbus_B_swap;
	wire      cmd_swap,cmd_Xor;
		
   Ram_data_swaping_module Ram_swap (
		.clk(clk), 
		
		.read_addr(start_addr),
		.write_addr(write_addr),
		
		.numbr_of_chunk(numbr_of_chunk), 
		.select_Ram_C_Or_D(select_Ram_C_Or_D), 		
		.select_Ram_A_Or_B(select_Ram_A_Or_B),
		
		.b_w_A(b_w_A), 
		.b_adbus_A(b_adbus_A_swap), 
		
		.b_w_B(b_w_B), 
		.b_adbus_B(b_adbus_B_swap), 
		
		.b_adbus_C(b_adbus_C_swap), 
		.b_adbus_D(b_adbus_D_swap),
		
		.interupt(interupt_swap),
      .command(command),
		.cmd_swap(cmd_swap),
		
      .select_Ram_D_DMA(select_Ram_D_DMA),
      .select_Ram_C_DMA(select_Ram_C_DMA)
		//.select_Ram_A_Or_B_DMA(select_Ram_A_Or_B_DMA)		

	);	
	 
	 
	 wire b_w_C_Xor,b_w_D_Xor;
	 wire [2:0] b_adbus_A_Xor,b_adbus_B_Xor,b_adbus_C_Xor,b_adbus_D_Xor;
	 wire [2:0] select_line_Xor;
	 wire select_Ram_C_DMA,select_Ram_D_DMA;
	
	Sequntial_Xor  Sequential_Xor (
		.clk(clk), 
		.command(command), 
		.start_addr(start_addr), 
		.b_adbus_A(b_adbus_A_Xor), 
		.b_adbus_B(b_adbus_B_Xor), 
		.cmd_Xor(cmd_Xor), 
		.interupt_Xor(interupt_Xor), 
		.b_w_C(b_w_C_Xor), 
		.b_w_D(b_w_D_Xor), 
		.b_adbus_C(b_adbus_C_Xor), 
		.b_adbus_D(b_adbus_D_Xor), 
		.select_line(select_line_Xor), 
		
		.Data_len_Polynomial(Data_len_Polynomial)
	);
	
	
	
	
	
	
		assign b_adbus_A = cmd_swap?(b_adbus_A_swap):cmd_sqr?b_adbus_A_sqr:cmd_mul?b_adbus_A_mul:
		                   cmd_Xor?b_adbus_A_Xor:3'hz; 
		assign byte_pos_A = cmd_sqr?byte_pos_A_sqr:1'hz;  
		assign b_adbus_B = cmd_swap?b_adbus_B_swap:(cmd_red?b_adbus_B_red:cmd_mul?b_adbus_B_mul:
		                   cmd_Xor?b_adbus_B_Xor:3'hz); 
		 
		assign b_w_C = cmd_red?b_w_C_red:cmd_sqr?b_w_C_sqr:cmd_mul?b_w_C_mul:
		               cmd_Xor?b_w_C_Xor:1'hz;		
							
		assign b_adbus_C = cmd_swap?b_adbus_C_swap:cmd_red?b_adbus_C_red:(cmd_sqr?b_adbus_C_sqr:cmd_mul?b_adbus_C_mul:
		                   cmd_Xor?b_adbus_C_Xor:3'hz); 
								 
		assign byte_pos_C = cmd_red?byte_pos_C_red:cmd_sqr?byte_pos_C_sqr:1'hz; 
		
		assign C_data_in1= cmd_red?b_data_in_C_red:cmd_mul?b_data_in_C_mul:256'hz; 
		
		assign b_w_D = cmd_red?b_w_D_red:cmd_sqr?b_w_D_sqr:cmd_mul?b_w_D_mul:
		               cmd_Xor?b_w_D_Xor:1'hz; 
							
		assign b_adbus_D = cmd_swap?b_adbus_D_swap:(cmd_red?b_adbus_D_red:cmd_sqr?b_adbus_D_sqr:cmd_mul?b_adbus_D_mul:
		                   cmd_Xor?b_adbus_D_Xor:3'hz); 
								 
		assign D_data_in1= cmd_red?b_data_in_D_red:cmd_mul?b_data_in_D_mul:256'hz; 
			
		assign Core_A = cmd_red?A1_red:cmd_mul?{4'h0,A1_mul}:136'hz;
		
		assign Core_B=  cmd_red?B1_red:cmd_mul?{4'h0,B1_mul}:136'hz; 
		
		
		assign select_line = cmd_red?select_line_red:cmd_sqr?select_line_sqr:cmd_mul?select_line_mul:
		                     cmd_Xor?select_line_Xor:3'hz; 	
										 
										 
 
										 
    									
	
	endmodule
