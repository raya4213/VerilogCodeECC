`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:31:25 07/21/2014 
// Design Name: 
// Module Name:    Xor_module 
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
module Xor_module(     // 32 slices in 64 and 64 slices in 128
input[135:0] A,
input[135:0] B,
output[135:0] C
);

	assign C[135:0]=A[135:0]^B[135:0];
endmodule
