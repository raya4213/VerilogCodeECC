`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:13:08 09/20/2014 
// Design Name: 
// Module Name:    Xor_256_module 
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
module Xor_256_module(
	input wire  [255:0] A,
	input wire  [255:0] B,
	output wire [255:0] C
    );

	assign C = A^B;

endmodule
