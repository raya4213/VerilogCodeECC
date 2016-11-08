`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Deepak Kapoor
// 
// Create Date:    11:43:05 07/23/2014 
// Design Name: 
// Module Name:    lower_bit_implementation 
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


module lower_bit_implementation#(
	parameter param=7,
	parameter SIZE=64,
	parameter MUL=3'b001,
	parameter SQR=3'b010,
	//parameter IS_ZERO_POS=3'b11,
	//parameter SHIFT_RIGHT=3'b100,
	parameter Xor_256=3'b101,
	//parameter SHIFT_LEFT=3'b110,
	parameter XOR=3'b111
	)(
	
   //INPUTS
	input wire [255:0] A,                 
	input wire [255:0] B,                      //change
	input wire [2:0] select_line,
	
	//OUTPUT
	output[135:0] C_Out,
	output[127:0] D_Out
	
	);
	
	//OUTPUT PORTS
	wire [135:0] Data_C_Out[param:0];
	wire [127:0] Data_D_Out[param:0];
    
	//INPUT PORTS
	wire [((2*SIZE)-1):0] Data_A_MUL,Data_B_MUL;
	wire [135:0] Data_A_XOR,Data_B_XOR;
//	wire [(SIZE-1):0] Data_A_IS_ZERO_POS,Data_B_SHIFT_RIGHT;
	//wire [(2*SIZE-1):0] Data_A_SHIFT_RIGHT;
	//wire [(3*SIZE-1):0] Data_A_SHIFT_LEFT,Data_B_SHIFT_LEFT;
	wire [(2*SIZE-1):0] Data_A_SQR;
	
	wire [255:0] Data_A_XOR_256 ;
	wire [255:0] Data_B_XOR_256 ;


		assign Data_A_MUL =(select_line==MUL)?A[127:0]:128'hzz;
		assign  Data_B_MUL=(select_line==MUL)?B[127:0]:128'hzz;
		
		assign Data_A_XOR =(select_line==XOR)?A[135:0]:135'hzz;
		assign Data_B_XOR =(select_line==XOR)?B[135:0]:135'hzz;
		
		
		assign Data_A_XOR_256 =(select_line==Xor_256)?A[255:0]:255'hzz;
		assign Data_B_XOR_256 =(select_line==Xor_256)?B[255:0]:255'hzz;
	
	
		//assign Data_A_SHIFT_RIGHT  =(select_line==SHIFT_RIGHT)?{64'h0,A[63:0]}:128'h0;
	//	assign Data_B_SHIFT_RIGHT =(select_line==SHIFT_RIGHT)?B[63:0]:128'h0;
		
		//assign Data_A_SHIFT_LEFT  =(select_line==SHIFT_LEFT)?A:(select_line==SHIFT_LEFT_128)?{64'h00,A}:128'hzz;
	//	assign Data_B_SHIFT_LEFT =(select_line==SHIFT_LEFT)?B:(select_line==SHIFT_LEFT_128)?B[63:0]:64'hzz;
		
		
		assign Data_A_SQR =(select_line==SQR)?A[127:0]:128'hzz;
		
		//assign Data_A_IS_ZERO_POS =(select_line==IS_ZERO_POS)?A[63:0]:64'hzz;
		//assign Data_D_Out[SHIFT_LEFT_128]=Data_D_Out[SHIFT_LEFT];
		//assign Data_C_Out[SHIFT_LEFT_128]=Data_C_Out[SHIFT_LEFT];
      
	   mul_128_module mul_128(
			.A(Data_A_MUL),
			.B(Data_B_MUL),
			.mul_128({Data_C_Out[MUL],Data_D_Out[MUL]})
		);
	
		
		Xor_module xor_135(
			.A(Data_A_XOR),
			.B(Data_B_XOR),
			.C(Data_C_Out[XOR])
		);
		
		
		
		
			Xor_256_module xor_256(
			.A(Data_A_XOR_256),
			.B(Data_B_XOR_256),
			.C({Data_C_Out[Xor_256],Data_D_Out[Xor_256]})
		);
		
		
		
	
		sqr_128_module square_128(
			.A(Data_A_SQR),
			.Out({Data_C_Out[SQR],Data_D_Out[SQR]})
		);

		/*pos_of_one utt5(
			.A(Data_A_IS_ZERO_POS),
			.C(Data_D_Out[IS_ZERO_POS])
		);*/
		
		
		/*shift uut3(
			.A(Data_A_SHIFT_RIGHT),
			.arg(Data_B_SHIFT_RIGHT),
			.Out({Data_D_Out[SHIFT_RIGHT]})
		);*/
		
	/*	shift_left uut6(
			.A(Data_A_SHIFT_LEFT),
			.arg(Data_B_SHIFT_LEFT),
			.Out({Data_C_Out[SHIFT_LEFT],Data_D_Out[SHIFT_LEFT]})
		);
		*/
		assign C_Out=Data_C_Out[select_line];
		assign D_Out=Data_D_Out[select_line];

endmodule	


