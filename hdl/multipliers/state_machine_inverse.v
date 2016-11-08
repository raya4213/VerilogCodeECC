`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  BARC 
// Engineer: Deepak 
// 
// Create Date:    23:57:09 09/15/2014 
// Design Name: 
// Module Name:    state_machine_inverse 
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
module state_machine_ECC_primitive#(
parameter DATA=256)(

		input  wire              clk,
		input  wire              a_w,                               
		input	 wire [5:0]        a_adbus,
		input  wire [(DATA-1):0] a_data_in, 
		output wire	[(DATA-1):0] a_data_out,
		
		input wire [3:0]         command_ECC,	
		input wire  [2:0]	       start_addr,
		output wire              interupt_sqr,
		output wire              interupt_red,
		output wire              interupt_swap,
		output wire              interupt_inv,
		output wire              interupt_mul,
		output wire              interupt_Xor,
		input wire [9:0]         Data_len_Polynomial,
      input wire [63:0]        Data_Polynomial	
    );

			wire        select_Ram_A_Or_B,select_Ram_C_Or_D,cmd_inv;
			wire [1:0]  numbr_of_chunk;
			wire [2:0]  write_addr_inv,read_addr_inv,read_addr_seq,write_addr_seq,b_adbus_A;
			wire [3:0]  b_command_inv,b_command_seq,  command;
			
			

			sequential_state_module sequential_module (
				.clk(clk), 
				.a_w(a_w), 
				.a_adbus(a_adbus), 
				.a_data_in(a_data_in), 
				
				.a_data_out(a_data_out),				
				.start_addr(read_addr_seq),
				.write_addr(write_addr_seq),
				.b_command(b_command_seq),	
				
				.interupt_sqr(interupt_sqr), 
				.interupt_red(interupt_red), 
				.interupt_swap(interupt_swap),				
				.interupt_mul(interupt_mul),
             .interupt_Xor(interupt_Xor), 				
				
				.select_Ram_C_Or_D(select_Ram_C_Or_D), 
				.select_Ram_A_Or_B(select_Ram_A_Or_B), 
				.numbr_of_chunk(numbr_of_chunk),
				
				.cmd_inv(cmd_inv),
				.command (command),
				
		      .Data_len_Polynomial (Data_len_Polynomial),
			    .Data_Polynomial(Data_Polynomial)
				);


			inverse_itoha_tsuji_module inverse (
				.clk(clk), 
				
				.read_addr_inv(read_addr_inv),    //give addr for square mul reduction
				.write_addr_inv(write_addr_inv),
            .start_addr(start_addr),				
				.b_command(b_command_inv), 
				
				.interupt_sqr(interupt_sqr), 
				.interupt_red(interupt_red), 
				.interupt_swap(interupt_swap), 
				.interupt_mul(interupt_mul),
				.interupt(interupt_inv),
				
				.select_Ram_C_Or_D(select_Ram_C_Or_D), 
				.select_Ram_A_Or_B(select_Ram_A_Or_B), 
				.numbr_of_chunk(numbr_of_chunk),
				.cmd_inv(cmd_inv),
				.command (command),
		      .Data_len_Polynomial (Data_len_Polynomial)
				);
	 
    assign b_command_seq=(cmd_inv)?b_command_inv:command_ECC;
    assign read_addr_seq=(cmd_inv)?read_addr_inv:start_addr;
	 assign write_addr_seq=(cmd_inv)?write_addr_inv:start_addr;

endmodule
