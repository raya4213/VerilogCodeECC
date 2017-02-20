`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:39:38 07/24/2014 
// Design Name: 
// Module Name:    Xor_16_bit 
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
module XOR(
 input[7:0] A,
input[7:0] B,
output[7:0] C
);

assign C=A^B;
endmodule

