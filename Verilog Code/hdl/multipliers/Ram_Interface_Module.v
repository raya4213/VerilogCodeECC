`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Barc	
// Engineer: Deepak Kapoor (modified)
// 
// Create Date:    22:42:05 08/15/2014 
// Design Name: 
// Module Name:    Ram_Interface_Module 
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
module Ram_Interface_Module#(   
parameter DATA = 256,
parameter ADDR = 3
)(
	input clk,
	input a_w,                               
	input			[5:0] a_adbus,
	input  wire [(DATA-1):0] a_data_in, 
	output wire 	[(DATA-1):0] a_data_out,  
	
	input        b_w_A,  
	
	/*For simultaneous Read address Port must be differnt */
	input wire  [(ADDR-1):0] b_adbus_A,
	input  wire	[(DATA-1):0] b_data_in_A,	
	output wire 	[(DATA-1):0] b_data_out_A,
	
	input          b_w_B,  
	input wire     [(ADDR-1):0] b_adbus_B,
	input  wire	   [(DATA-1):0] b_data_in_B,	
	output wire 	[(DATA-1):0] b_data_out_B,
	
	input          b_w_C,  
	input wire     [(ADDR-1):0] b_adbus_C,
	input  wire	   [(DATA-1):0] b_data_in_C,	
	output wire 	[(DATA-1):0] b_data_out_C,
	
	input          b_w_D,  
	input  wire    [(ADDR-1):0] b_adbus_D,
	input  wire	   [(DATA-1):0] b_data_in_D,	
	output wire 	[(DATA-1):0] b_data_out_D,
	input  wire	[3:0] b_command ,//address bus

	output wire 	[3:0] command        //command reg
              
    );
	 
			wire [255:0] a_data_in_A,a_data_in_B,a_data_in_C,a_data_in_D;
			wire [2:0]   a_adbus_A,a_adbus_B,a_adbus_C,a_adbus_D;
			wire [255:0] a_data_out_A,a_data_out_B,a_data_out_C,a_data_out_D;
			reg [3:0] command1;
			
			assign command = command1;
			
			assign a_data_in_A=(a_adbus[5:3]==3'b001)?a_data_in:255'hz;
			assign a_adbus_A=(a_adbus[5:3]==3'b001)?a_adbus[2:0]:3'hz;

			assign a_data_in_B=(a_adbus[5:3]==3'b010)?a_data_in:255'hz;
			assign a_adbus_B=(a_adbus[5:3]==3'b010)?a_adbus[2:0]:3'hz;

			assign a_data_in_C=(a_adbus[5:3]==3'b011)?a_data_in:255'hz;
			assign a_adbus_C=(a_adbus[5:3]==3'b011)?a_adbus[2:0]:3'hz;

			assign a_data_in_D=(a_adbus[5:3]==3'b100)?a_data_in:255'hz;
			assign a_adbus_D=(a_adbus[5:3]==3'b100)?a_adbus[2:0]:3'hz;


			assign a_data_out=(a_adbus[5:3]==3'b001)?a_data_out_A:
			                 ((a_adbus[5:3]==3'b010)?a_data_out_B:
								((a_adbus[5:3]==3'b011)?a_data_out_C:
								 ((a_adbus[5:3]==3'b100)?a_data_out_D:a_data_out)));



			Ram_Module Ram_A (
			.clk(clk), 
			.a_w(a_w), 
			.b_w(b_w_A), 
			.a_adbus(a_adbus_A), 
			.a_data_in(a_data_in_A), 
			.a_data_out(a_data_out_A), 
			.b_adbus(b_adbus_A), 
			.b_data_in(b_data_in_A), 
			.b_data_out(b_data_out_A)
			);

			Ram_Module Ram_B (
			.clk(clk), 
			.a_w(a_w), 
			.b_w(b_w_B), 
			.a_adbus(a_adbus_B), 
			.a_data_in(a_data_in_B), 
			.a_data_out(a_data_out_B), 
			.b_adbus(b_adbus_B), 
			.b_data_in(b_data_in_B), 
			.b_data_out(b_data_out_B)
			);


			Ram_Module Ram_C (
			.clk(clk), 
			.a_w(a_w), 
			.b_w(b_w_C), 
			.a_adbus(a_adbus_C), 
			.a_data_in(a_data_in_C), 
			.a_data_out(a_data_out_C), 
			.b_adbus(b_adbus_C), 
			.b_data_in(b_data_in_C), 
			.b_data_out(b_data_out_C)
			);


			Ram_Module Ram_D (
			.clk(clk), 
			.a_w(a_w), 
			.b_w(b_w_D), 
			.a_adbus(a_adbus_D), 
			.a_data_in(a_data_in_D), 
			.a_data_out(a_data_out_D), 
			.b_adbus(b_adbus_D), 
			.b_data_in(b_data_in_D), 
			.b_data_out(b_data_out_D)
			);
			always @(posedge clk)begin	 
				if (a_w && a_adbus == 4'b0001) begin
					command1 <= a_data_in[3:0];
				end
		   else
			   command1<=b_command;
		

			end
endmodule
