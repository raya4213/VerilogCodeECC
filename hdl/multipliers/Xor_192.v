`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:09:30 08/26/2014 
// Design Name: 
// Module Name:    Xor_192 
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
module Xor_256(
	 input [255:0] A,
	 input [255:0] B,
	 output [255:0] Out
    );
	
	assign Out=A^B;
		
	
	/*
	assign Out[7] = A[7]?(B[7]?1'h0:1'h1):1'h0;
	assign Out[6] = A[6]?(B[6]?1'h0:1'h1):1'h0;
	assign Out[5] = A[5]?(B[5]?1'h0:1'h1):1'h0;
	assign Out[4] = A[4]?(B[4]?1'h0:1'h1):1'h0;
	assign Out[3] = A[3]?(B[3]?1'h0:1'h1):1'h0;
	assign Out[2] = A[2]?(B[2]?1'h0:1'h1):1'h0;
	assign Out[1] = A[1]?(B[1]?1'h0:1'h1):1'h0;
	assign Out[0] = A[0]?(B[0]?1'h0:1'h1):1'h0;
	*/
	
endmodule
