	`timescale 1ns / 1ps
	//////////////////////////////////////////////////////////////////////////////////
	// Company: 
	// Engineer: 
	// 
	// Create Date:    09:51:19 06/27/2014 
	// Design Name: 
	// Module Name:    testt 
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
	/*module mul_2_module(
		 input[1:0] A,
		 input[1:0] B,
		 output[3:0] mul_2
		 );
		 //assign mul_2[0] = A[0]&B[0];
		 //assign mul_2[2] = A[1]&B[1];
		 assign mul_2[2:0] = { A[1]&B[1],(A[0]^A[1])&(B[0]^B[1]) ^ mul_2[0] ^ mul_2[2],A[0]&B[0]};
	endmodule*/

	module mul_2_module( 
		input	[1:0] A,
		input	[1:0] B,
		output reg[3:0] C
	);
	always @(A or B)
	begin
		case ({A,B})
		4'b0000:
			C=0;
		4'b0001:
			C=0;
		4'b0010:
			C=0;
		4'b0011:
			C=0;
		4'b0100:
			C=0;
		4'b0101:
			C=4'b0001;
		4'b0110:
			C=4'b0010;
		4'b0111:
			C=4'b0011;
		4'b1000:
			C=4'b0;
		4'b1001:
			C=4'b0010;
		4'b1010:
			C=4'b0100;
		4'b1011:
			C=4'b0110;
		4'b1100:
			C=4'b0;
		4'b1101:
			C=4'b0011;
		4'b1110:
			C=4'b0110;
		4'b1111:
			C=4'b0101;
			endcase
end
 endmodule

	module mul_4_module(
		 input[3:0] A,
		 input[3:0] B,
		 output[7:0] mul_4
		 );
		// reg[7:0] mul_4;
 wire[3:0] d0,d1,d2,d7;
	mul_2_module uut0((A[1:0]),(B[1:0]),(d0));
	mul_2_module uut1((A[1:0]^A[3:2]),(B[1:0]^B[3:2]),(d1));
	mul_2_module uut2(A[3:2],B[3:2],(d2));
	assign d7 = d1^d2^d0;
	assign mul_4[7:4]= {d2[3:2],((d2[1:0])^(d7[3:2]))};
	assign mul_4[3:0]= {((d0[3:2])^(d7[1:0])),d0[1:0]};
assign mul_4[7:0]= {d2[3:2],((d2[1:0])^(d7[3:2])),((d0[3:2])^(d7[1:0])),d0[1:0]};

	endmodule


	module mul_8_module(
		 input[7:0] A,
		 input[7:0] B,
		 output[15:0] mul_8
		 );
	wire[7:0] d0,d1,d2,d7, d8,d4;//;wire[5:0] d7;wire[7:0] d2;
	mul_4_module uut5((A[3:0]),(B[3:0]),(d0));
	mul_4_module uut6((A[3:0]^A[7:4]),(B[3:0]^B[7:4]),(d1));
	mul_4_module uut7(A[7:4],B[7:4],(d2));
	assign d7 = d1^d2^d0;
	//assign mul_8[15:8] = {d2[7:4],((d2[3:0])^(d7[7:4]))};
	//assign mul_8[7:0]= {((d0[7:4])^(d7[3:0])),d0[3:0]};
	
	
	assign mul_8[15:0] = {d2[7:4],((d2[3:0])^(d7[7:4])),((d0[7:4])^(d7[3:0])),d0[3:0]};

	endmodule
  /*module mul_16_module(
		 input[15:0] A,
		 input[15:0] B,
		 output[31:0] mul_16
		 );
	wire[15:0] d0,d1,d2,d7, d8,d4;//;wire[5:0] d7;wire[7:0] d2;
	mul_8_module uut5((A[7:0]),(B[7:0]),(d0));
	mul_8_module uut6((A[7:0]^A[15:8]),(B[7:0]^B[15:8]),(d1));
	mul_8_module uut7(A[15:8],B[15:8],(d2));
	assign d7 = d1^d2^d0;
	//assign mul_16[31:16] = {d2[15:8],((d2[7:0])^(d7[15:8]))};
	//assign mul_16[15:0]= {((d0[15:8])^(d7[7:0])),d0[7:0]};
	assign mul_16[31:0] = {d2[15:8],((d2[7:0])^(d7[15:8])),((d0[15:8])^(d7[7:0])),d0[7:0]};
	endmodule
	
	
	
	module mul_32_module(
		 input[31:0] A,
		 input[31:0] B,
		 output[63:0] mul_32
		 );
	wire[31:0] d0,d1,d2,d7, d8,d4;//;wire[5:0] d7;wire[7:0] d2;
	mul_16_module uut5((A[15:0]),(B[15:0]),(d0));
	mul_16_module uut6((A[15:0]^A[31:16]),(B[15:0]^B[31:16]),(d1));
	mul_16_module uut7(A[31:16],B[31:16],(d2));
	assign d7 = d1^d2^d0;
	//assign mul_32[63:32] = {d2[31:16],((d2[15:0])^(d7[31:16]))};
	//assign mul_32[31:0]= {((d0[31:16])^(d7[15:0])),d0[15:0]};
	assign mul_32[63:0] = {d2[31:16],((d2[15:0])^(d7[31:16])),((d0[31:16])^(d7[15:0])),d0[15:0]};
	endmodule*/
	module mul_32_module(
		 input[31:0] A,
		 input[31:0] B,
		 output[63:0] mul_32
		 );
	wire[15:0] d0,d1,d2,d3,f1,f0,f,c0,c1,c2,c3,c5,c4,c6,g1,g2,g3,g4,g5,g6;//;wire[5:0] d7;wire[7:0] d2;
	mul_8_module uut1((A[7:0]),(B[7:0]),(d0));
	mul_8_module uut2((A[15:8]),(B[15:8]),(d1));
	mul_8_module uut3((A[23:16]),(B[23:16]),(d2));
	mul_8_module uut4((A[31:24]),(B[31:24]),(d3));
	assign f1 = d3^d2;
	assign  f0 = d1^d0;
	assign c6=d3;
	//assign f=f1^f0;
	mul_8_module uut5((A[31:24])^A[23:16],(B[31:24])^B[23:16],g5);
	assign c5=g5^f1;
	mul_8_module uut6((A[15:8])^A[31:24],(B[15:8])^B[31:24],g4);
	assign c4=g4^f1^d1;

	mul_8_module uut7((A[7:0])^A[23:16],(B[7:0])^B[23:16],g2);
	assign c2=g2^f0^d2;

	mul_8_module uut8((A[7:0])^A[15:8],(B[7:0])^B[15:8],g1);
	assign c1 =g1^f0;
	assign c0=d0;

	mul_8_module uut9(A[7:0]^A[23:16]^A[31:24]^A[15:8],B[7:0]^B[23:16]^B[31:24]^B[15:8],g3);
	assign c3=g3^c1^c2^c4^c5^c6^c0;


	assign mul_32 = {c6[15:8],c6[7:0]^c5[15:8],c5[7:0]^c4[15:8],c4[7:0]^c3[15:8],c3[7:0]^c2[15:8],c2[7:0]^c1[15:8],c1[7:0]^c0[15:8],c0[7:0]};     
	endmodule
	
	
	module mul_64_module(
		 input[63:0] A,
		 input[63:0] B,
		 output[127:0] mul_64
		 );
	wire[63:0] d0,d1,d2,d7;//;wire[5:0] d7;wire[7:0] d2;
	mul_32_module uut5((A[31:0]),(B[31:0]),(d0));
	mul_32_module uut6((A[31:0]^A[63:32]),(B[31:0]^B[63:32]),(d1));
	mul_32_module uut7(A[63:32],B[63:32],(d2));
	assign d7 = d1^d2^d0;
		assign mul_64[127:0] = {d2[63:32],((d2[31:0])^(d7[63:32])),((d0[63:32])^(d7[31:0])),d0[31:0]};
	
	endmodule
	
	
	
	
	module mul_128_module(
		 input[127:0] A,
		 input[127:0] B,
		 output[255:0] mul_128
		 );
	wire[127:0] d0,d1,d2,d7;//;wire[5:0] d7;wire[7:0] d2;
	mul_64_module mul_641((A[63:0]),(B[63:0]),(d0));
	mul_64_module mul_642((A[63:0]^A[127:64]),(B[63:0]^B[127:64]),(d1));
	mul_64_module mul_643(A[127:64],B[127:64],(d2));
	assign d7 = d1^d2^d0;
		assign mul_128[255:0] = {d2[127:64],((d2[63:0])^(d7[127:64])),((d0[127:64])^(d7[63:0])),d0[63:0]};
	
	endmodule

