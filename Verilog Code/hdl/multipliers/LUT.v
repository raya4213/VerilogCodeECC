`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:27:02 07/09/2014 
// Design Name: 
// Module Name:    LUT 
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

//A  reduction Polynomial
//B= input polynomial

module LUT(input[7:0] A,                         
input[7:0] B,
output[15:0] C
    );
wire[15:0] d,d2,d3,d4,d5,d6,d7, d1;
assign d[15:8]=A[7:0];
assign d[7:0]=8'b0;
assign d1=B[7]?d:16'b0;
assign d2=B[6]?d1^d>>1:d1;
assign d3=B[5]?d2^d>>2:d2;
assign d4=B[4]?d3^d>>3:d3;
assign d5=B[3]?d4^d>>4:d4;
assign d6=B[2]?d5^d>>5:d5;
assign d7=B[1]?d6^d>>6:d6;
assign C[15:0]=B[0]?d7^d>>7:d7;
endmodule


