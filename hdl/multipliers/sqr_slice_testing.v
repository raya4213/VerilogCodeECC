`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:04:41 06/30/2014 
// Design Name: 
// Module Name:    sqr_slice_testing 
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
////////////////////////////////////////////////////////////////////////////////////
//module sqr_slice_testing(

module sqr_4_module(
    input[3:0] A,
    output wire[7:0] Out_4
    );
	// reg[7:0] Out_4;
	/*		always @(A)
			begin
				case (A)
				4'b0000:Out_4=8'h00;
				4'b0001:Out_4=8'h01;
				4'b0010:Out_4=8'h04;
				4'b0011:Out_4=8'h05;
				4'b0100:Out_4=8'h10;
				4'b0101:Out_4=8'h11;
				4'b0110:Out_4=8'h14;
				4'b0111:Out_4=8'h15;
				4'b1000:Out_4=8'h40;
				4'b1001:Out_4=8'h41;
				4'b1010:Out_4=8'h44;
				4'b1011:Out_4=8'h45;
				4'b1100:Out_4=8'h50;
				4'b1101:Out_4=8'h51;
				4'b1110:Out_4=8'h54;
				4'b1111:Out_4=8'h55;
				endcase
			end*/
	assign Out_4 = {1'b0,A[3],1'b0,A[2],1'b0,A[1],1'b0,A[0]};
endmodule

module sqr_128_module(
    input[127:0] A,
    output[255:0] Out
    );
			wire [7:0] d1,d0,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20,d21,d22,d23,d24,d25,d26,d27,d28,d29,d30,d31;
			
			sqr_4_module uut1(
				.A(A[3:0]),
				.Out_4(d0));
			
			sqr_4_module uut (
				.A(A[7:4]),
				.Out_4(d1));
			
			sqr_4_module uut2 (
				.A(A[11:8]),
				.Out_4(d2));
			
			sqr_4_module uut3(
				.A(A[15:12]),
				.Out_4(d3));
			
			sqr_4_module uut4 (
				.A(A[19:16]),
				.Out_4(d4));
			
			sqr_4_module uut5(
				.A(A[23:20]),
				.Out_4(d5));
			
			sqr_4_module uut6 (
				.A(A[27:24]),
				.Out_4(d6));
			
			sqr_4_module uut7(
				.A(A[31:28]),
				.Out_4(d7));

			sqr_4_module uut8(
				.A(A[35:32]),
				.Out_4(d8));
			
			sqr_4_module uut9 (
				.A(A[39:36]),
				.Out_4(d9));

			sqr_4_module uut10 (
				.A(A[43:40]),
				.Out_4(d10));
			
			sqr_4_module uut11(
				.A(A[47:44]),
				.Out_4(d11));

			sqr_4_module uut12 (
				.A(A[51:48]),
				.Out_4(d12));
			
			sqr_4_module uut13(
				.A(A[55:52]),
				 .Out_4(d13));
			
			sqr_4_module uut14 (
				.A(A[59:56]),
				.Out_4(d14));
			
			sqr_4_module uut15(
				.A(A[63:60]),
				.Out_4(d15));
				
			sqr_4_module uut16 (
				.A(A[67:64]),
				.Out_4(d16));
			
			sqr_4_module uut17(
				.A(A[71:68]),
				.Out_4(d17));

			sqr_4_module uut18(
				.A(A[75:72]),
				.Out_4(d18));
			
			sqr_4_module uut19 (
				.A(A[79:76]),
				.Out_4(d19));

			sqr_4_module uut20 (
				.A(A[83:80]),
				.Out_4(d20));
			
			sqr_4_module uut21(
				.A(A[87:84]),
				.Out_4(d21));

			sqr_4_module uut22 (
				.A(A[91:88]),
				.Out_4(d22));
			
			sqr_4_module uut23(
				.A(A[95:92]),
				 .Out_4(d23));
			
			sqr_4_module uut24 (
				.A(A[99:96]),
				.Out_4(d24));
			
			sqr_4_module uut25(
				.A(A[103:100]),
				.Out_4(d25));	
				
				
			
			sqr_4_module uut26 (
				.A(A[107:104]),
				.Out_4(d26));
			
			sqr_4_module uut27(
				.A(A[111:108]),
				.Out_4(d27));

			sqr_4_module uut28(
				.A(A[115:112]),
				.Out_4(d28));
			
			sqr_4_module uut29 (
				.A(A[119:116]),
				.Out_4(d29));

			sqr_4_module uut30 (
				.A(A[123:120]),
				.Out_4(d30));
			
			sqr_4_module uut31(
				.A(A[127:124]),
				.Out_4(d31));
		   				
			
			assign Out[255:0]={d31,d30,d29,d28,d27,d26,d25,d24,d23,d22,d21,d20,d19,d18,d17,d16,d15,d14,d13,d12,d11,d10,d9,d8,d7,d6,d5,d4,d3,d2,d1,d0};

endmodule


	
	 
	 
	 
	 