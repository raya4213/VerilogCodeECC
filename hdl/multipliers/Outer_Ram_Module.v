`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: BARC
// Engineer: Rahul and Deepak
// 
// Create Date:    05:37:33 01/01/2009 
// Design Name: 
// Module Name:    Outer_Ram_Module 
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
module Ram_Module_1#(
   parameter DATA = 256,
	parameter ADDR = 6)(                               
	input clk,
	input a_w,
	input b_w,                               
	input	 wire	[(ADDR-1):0] a_adbus,
	input  wire [(DATA-1):0] a_data_in, 
	output reg	[(DATA-1):0] a_data_out,
	input  wire	[(ADDR-1):0] b_adbus,
	input  wire [(DATA-1):0] b_data_in, 
	output reg	[(DATA-1):0] b_data_out
	);


	reg [(DATA-1):0]memory [0:47];      //Declaring Memory
	reg [(DATA-1):0] b_data_out1,a_data_out1;
	
	
	always @(posedge clk) begin
		if( a_w ) begin
				memory[a_adbus] <= a_data_in;
			end
				a_data_out<=memory[a_adbus];	
end

    	always @(posedge clk) begin
		if( b_w ) begin
				memory[b_adbus] <= b_data_in;
			end
				b_data_out<=memory[b_adbus];	

	end//end of always module


endmodule
