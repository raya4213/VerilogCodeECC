`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: BARC	
// Engineer: Deepak
// 
// Create Date:    17:05:25 07/21/2014 
// Design Name: 
// Module Name:    alignment_module 
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

                      /*770 Slice Lut*/

module LOOK_UP_module#(
parameter IS_ZERO_POS=3'b011
)(
	input [63:0] A_Poly,               //frst chunk [19:12] scnd chunk [7:0]
	input [63:0] B,
	output wire [127:0] D_out_1,     //frst chunk lut[255:128] secnd chunk Lut[127:0]
	output wire [127:0] D_out_2
	);

	
	wire [63:0] D,var;
	wire [15:0] A_26,B_16,C_16,C_16_XOR;
	wire [7:0] A_1,A_2;
	wire [3:0] byte_pos_1,byte_pos_2;
	
	wire [7:0] C_Out1_1,C_Out1_2,C_Out1_3,C_Out1_4,C_Out1_5,C_Out1_6,C_Out1_7;
   wire [7:0] C_Out2_1,C_Out2_2,C_Out2_3,C_Out2_4,C_Out2_5,C_Out2_6,C_Out2_7;

	wire [127:0] Lut_Out, Lut_Out_2;	
   
	//assign D_Out={D_out_1,D_out_2};
	
   assign D_out_1=(byte_pos_1==7)?({Lut_Out[127:120],C_Out1_1,C_Out1_2,C_Out1_3,C_Out1_4,C_Out1_5,C_Out1_6,C_Out1_7,Lut_Out[7:0],56'b0}):
	((byte_pos_1==6)?({8'h0,Lut_Out[127:120],C_Out1_1,C_Out1_2,C_Out1_3,C_Out1_4,C_Out1_5,C_Out1_6,C_Out1_7,Lut_Out[7:0],48'b0}):((byte_pos_1==5)?({16'h0,Lut_Out[127:120],C_Out1_1,C_Out1_2,C_Out1_3,C_Out1_4,C_Out1_5,C_Out1_6,C_Out1_7,Lut_Out[7:0],40'b0}):((byte_pos_1==4)?({24'h0,Lut_Out[127:120],C_Out1_1,C_Out1_2,C_Out1_3,C_Out1_4,C_Out1_5,C_Out1_6,C_Out1_7,Lut_Out[7:0],32'b0}):((byte_pos_1==3)?({32'h0,Lut_Out[127:120],C_Out1_1,C_Out1_2,C_Out1_3,C_Out1_4,C_Out1_5,C_Out1_6,C_Out1_7,Lut_Out[7:0],24'b0}):
	((byte_pos_1==2)?{40'h0,Lut_Out[127:120],C_Out1_1,C_Out1_2,C_Out1_3,C_Out1_4,C_Out1_5,C_Out1_6,C_Out1_7,Lut_Out[7:0],16'b0}:
	((byte_pos_1==1)?{48'h0,Lut_Out[127:120],C_Out1_1,C_Out1_2,C_Out1_3,C_Out1_4,C_Out1_5,C_Out1_6,C_Out1_7,Lut_Out[7:0],8'h0}:
	({56'h0,Lut_Out[127:120],C_Out1_1,C_Out1_2,C_Out1_3,C_Out1_4,C_Out1_5,C_Out1_6,C_Out1_7,Lut_Out[7:0]})))))));
	
	
	 assign D_out_2=(byte_pos_2==7)?({Lut_Out_2[127:120],C_Out2_1,C_Out2_2,C_Out2_3,C_Out2_4,C_Out2_5,C_Out2_6,C_Out2_7,Lut_Out_2[7:0],56'b0}):
	((byte_pos_2==6)?({8'h0,Lut_Out_2[127:120],C_Out2_1,C_Out2_2,C_Out2_3,C_Out2_4,C_Out2_5,C_Out2_6,C_Out2_7,Lut_Out_2[7:0],48'b0}):((byte_pos_2==5)?({16'h0,Lut_Out_2[127:120],C_Out2_1,C_Out2_2,C_Out2_3,C_Out2_4,C_Out2_5,C_Out2_6,C_Out2_7,Lut_Out_2[7:0],40'b0}):((byte_pos_2==4)?({24'h0,Lut_Out_2[127:120],C_Out2_1,C_Out2_2,C_Out2_3,C_Out2_4,C_Out2_5,C_Out2_6,C_Out2_7,Lut_Out_2[7:0],32'b0}):((byte_pos_2==3)?({32'h0,Lut_Out_2[127:120],C_Out2_1,C_Out2_2,C_Out2_3,C_Out2_4,C_Out2_5,C_Out2_6,C_Out2_7,Lut_Out_2[7:0],24'b0}):
	((byte_pos_2==2)?{40'h0,Lut_Out_2[127:120],C_Out2_1,C_Out2_2,C_Out2_3,C_Out2_4,C_Out2_5,C_Out2_6,C_Out2_7,Lut_Out_2[7:0],16'b0}:
	((byte_pos_2==1)?{48'h0,Lut_Out_2[127:120],C_Out2_1,C_Out2_2,C_Out2_3,C_Out2_4,C_Out2_5,C_Out2_6,C_Out2_7,Lut_Out_2[7:0],8'h0}:
	({56'h0,Lut_Out_2[127:120],C_Out2_1,C_Out2_2,C_Out2_3,C_Out2_4,C_Out2_5,C_Out2_6,C_Out2_7,Lut_Out_2[7:0]})))))));
	
	
	assign A_1=A_Poly[19:12];
	assign byte_pos_1=A_Poly[23:20];
	
	assign A_2=A_Poly[7:0];
	assign byte_pos_2=A_Poly[11:8];

	LUT look_up_table1 (
		.A(A_1), 
		.B(B[63:56]), 
		.C(Lut_Out[127:112])
	);
	
	LUT look_up_table2 (
		.A(A_1), 
		.B(B[55:48]), 
		.C(Lut_Out[111:96])
	);
	LUT look_up_table3 (
		.A(A_1), 
		.B(B[47:40]), 
		.C(Lut_Out[95:80])
	);
	LUT look_up_table4 (
		.A(A_1), 
		.B(B[39:32]), 
		.C(Lut_Out[79:64])
	);
	LUT look_up_table5 (
		.A(A_1), 
		.B(B[31:24]), 
		.C(Lut_Out[63:48])
	);
	LUT look_up_table6 (
		.A(A_1), 
		.B(B[23:16]), 
		.C(Lut_Out[47:32])
	);
	LUT look_up_table7 (
		.A(A_1), 
		.B(B[15:8]), 
		.C(Lut_Out[31:16])
	);
	LUT look_up_table8 (
		.A(A_1), 
		.B(B[7:0]), 
		.C(Lut_Out[15:0])
	);
	

////////Second byte reduce table////////
LUT look_up_table9 (
		.A(A_2), 
		.B(B[63:56]), 
		.C(Lut_Out_2[127:112])
	);
	
	LUT look_up_table10 (
		.A(A_2), 
		.B(B[55:48]), 
		.C(Lut_Out_2[111:96])
	);
	LUT look_up_table11 (
		.A(A_2), 
		.B(B[47:40]), 
		.C(Lut_Out_2[95:80])
	);
	LUT look_up_table12 (
		.A(A_2), 
		.B(B[39:32]), 
		.C(Lut_Out_2[79:64])
	);
	LUT look_up_table13 (
		.A(A_2), 
		.B(B[31:24]), 
		.C(Lut_Out_2[63:48])
	);
	LUT look_up_table14 (
		.A(A_2), 
		.B(B[23:16]), 
		.C(Lut_Out_2[47:32])
	);
	LUT look_up_table15 (
		.A(A_2), 
		.B(B[15:8]), 
		.C(Lut_Out_2[31:16])
	);
	LUT look_up_table16 (
		.A(A_2), 
		.B(B[7:0]), 
		.C(Lut_Out_2[15:0])
	);
	

	XOR Xor_16_1 (
		.A(Lut_Out[119:112]), 
		.B(Lut_Out[111:104]), 
		.C(C_Out1_1)
	);
	XOR Xor_16_2 (
		.A(Lut_Out[103:96]), 
		.B(Lut_Out[95:88]), 
		.C(C_Out1_2)
	);
		XOR Xor_16_3 (
		.A(Lut_Out[87:80]), 
		.B(Lut_Out[79:72]), 
		.C(C_Out1_3)
	);
		XOR Xor_16_4 (
		.A(Lut_Out[71:64]), 
		.B(Lut_Out[63:56]), 
		.C(C_Out1_4)
	);
		XOR Xor_16_5 (
		.A(Lut_Out[55:48]), 
		.B(Lut_Out[47:40]), 
		.C(C_Out1_5)
	);
	
		XOR Xor_16_6 (
		.A(Lut_Out[39:32]), 
		.B(Lut_Out[31:24]), 
		.C(C_Out1_6)
	);
		XOR Xor_16_7 (
		.A(Lut_Out[23:16]), 
		.B(Lut_Out[15:8]), 
		.C(C_Out1_7)
	);

	XOR Xor_16_8 (
		.A(Lut_Out_2[119:112]), 
		.B(Lut_Out_2[111:104]), 
		.C(C_Out2_1)
	);
	XOR Xor_16_9 (
		.A(Lut_Out_2[103:96]), 
		.B(Lut_Out_2[95:88]), 
		.C(C_Out2_2)
	);
		XOR Xor_16_10 (
		.A(Lut_Out_2[87:80]), 
		.B(Lut_Out_2[79:72]), 
		.C(C_Out2_3)
	);
		XOR Xor_16_11 (
		.A(Lut_Out_2[71:64]), 
		.B(Lut_Out_2[63:56]), 
		.C(C_Out2_4)
	);
		XOR Xor_16_12 (
		.A(Lut_Out_2[55:48]), 
		.B(Lut_Out_2[47:40]), 
		.C(C_Out2_5)
	);
	
		XOR Xor_16_13 (
		.A(Lut_Out_2[39:32]), 
		.B(Lut_Out_2[31:24]), 
		.C(C_Out2_6)
	);
		XOR Xor_16_14 (
		.A(Lut_Out_2[23:16]), 
		.B(Lut_Out_2[15:8]), 
		.C(C_Out2_7)
	);
		

	
	
	endmodule


