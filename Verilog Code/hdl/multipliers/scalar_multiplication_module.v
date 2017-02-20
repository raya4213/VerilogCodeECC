`timescale 1ns / 1ps

/*In this program the first five case are used for sending x1,x2,y1,y2,a into inner ram*/
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Rahul
// 
// Create Date:    15:48:45 10/17/2014 
// Design Name: 
// Module Name:    scalar_multiplication_module 
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
module scalar_multiplication_module(

		input  wire       clk,
		input  wire       interupt_point_add,
		input  wire       interupt_point_double,
		input  wire       interupt_ram_transfer,
		input  wire       command_scalar_multiplication,
		
		output reg        read_write_command,
		output reg [5:0]  read_address,       //Read Address where to read from
		output reg [5:0]  write_address,      //Write Address where to write from
		output reg        interupt_scalar_mul,
		output reg        cmd_transfer,       //for initiating transfer operation		
		output reg  [1:0] command_add_double,
		//input  wire [1:0]     no_of_chunks_frm_tb,
		input wire   [575:0]  scalar_multiplication       
		//input private key
    );
		
		 reg [4:0] fsm;
		 reg command_strt;
		 reg [4:0]count;
		 reg [575:0] private_key;
		 reg [3:0] count_check_one;  //1024 bit number can have atmost 11 ones
		 reg check_one;
		 reg frst_check_one;
		 reg frst_check,var;
		 
	 initial begin
	
		//private_key <= random_number;
		interupt_scalar_mul <= 1'h0;
		end
	 
	 always @(posedge clk) begin

	//scalar multiplication starts here
	if (command_scalar_multiplication)begin
		fsm <= 5'h1;	
		end
		
	case (fsm)
		
		5'h1:begin
			fsm <= 5'h2;                   //sending x1 into addr 3 of inner ram
			read_write_command <= 1'h0;
			read_address <= 6'h3;
			write_address <= 6'h3; 
			cmd_transfer <= 1'h1;    

			private_key <= scalar_multiplication;
		
		end
		
		5'h2:begin
			if (interupt_ram_transfer)begin
				fsm <= 5'h3;                     //sending y1 into addr 6 of inner ram
				read_write_command <= 1'h0;
				read_address <= 6'h6;
				write_address <= 6'h6; 
				cmd_transfer <= 1'h1;
				end
			else
			cmd_transfer<=1'h0;
		end
		
		5'h3:begin
			if (interupt_ram_transfer)begin
				fsm <= 5'h4;                         //writing a into addr 9 of inner ram
				read_write_command <= 1'h0;
				read_address <= 6'h9;
				write_address <= 6'h9; 
				cmd_transfer <= 1'h1;
				private_key <= private_key/2'h2;
				check_one <=  private_key[0];
				frst_check <= private_key[0];
				var<=private_key[0];
				end
			else
				cmd_transfer<=1'h0;
		end
		
		5'h4:begin			 
			if (interupt_ram_transfer)begin   //sending x1 into addr 33 of inner ram(point_add)
				
				if (check_one)begin
					fsm <= 5'h5;
					read_write_command <= 1'h0;
					read_address <= 6'h19;
					write_address <= 6'h21; 
					cmd_transfer <= 1'h1;    
					end
				else
					fsm <= 5'h7;
				end
			else
				cmd_transfer<=1'h0;
		end
		
		5'h5:begin
			if (interupt_ram_transfer)begin
				fsm <= 5'h6;                     //sending y1 into addr 39 of inner ram(point_add)
				read_write_command <= 1'h0;
				read_address <= 6'h1c;
				write_address <= 6'h27; 
				cmd_transfer <= 1'h1;
				end
			else
				cmd_transfer<=1'h0;
		end
		
		
		5'h6:begin
			if (interupt_ram_transfer)begin
				fsm <= 5'h7;
				end
			else
				cmd_transfer<=1'h0;
		end
		
		5'h7:begin
			
				private_key <= private_key/2'h2;
				check_one <= private_key[0];
				if (private_key != 576'h0)begin 
					command_add_double <= 2'h2;
					fsm <= 5'h8;
					end
				else begin
					if(var) begin
						command_add_double <= 2'h1;
						fsm<=5'ha;
						end
					else
						fsm<=5'hb;
					end
		end
		
		5'h8:begin
			if (interupt_point_double) begin
			
				if(!frst_check && check_one) begin
					fsm<=5'hc;
					frst_check<=1'h1;
					end
				else begin
					if (check_one)begin
						//var<=1'h1;
						command_add_double <= 2'h1;
						fsm <= 5'h9;
						end
					else
						fsm<=5'h7;
					end
			end
			else
				command_add_double <= 2'h0;
		end
			
		5'h9:begin			
			if (interupt_point_add)begin
				fsm <= 5'h7;
				end
			else
				command_add_double <= 2'h0;
		end
		
		5'ha:begin
					if(interupt_point_add)begin
						fsm <= 5'hb;                         //writing x1 into addr 33 of outer ram
						end
					else
						command_add_double<=2'h0;
					
			end
				
			
			5'hc:begin
				fsm <= 5'hd;                         //writing x1 into addr 33 of outer ram
				read_write_command <= 1'h1;
				read_address <= 6'h3;
				write_address <= 6'h21; 
				cmd_transfer <= 1'h1;
			end
			
			5'hd:begin
				if (interupt_ram_transfer)begin
					fsm <= 5'he;                         //writing y1 into addr 39 of outer ram
					read_write_command <= 1'h1;
					read_address <= 6'h6;
					write_address <= 6'h27; 
					cmd_transfer <= 1'h1;
					end
				else
					cmd_transfer <= 1'h0;
			end
			
			5'he:begin
				if (interupt_ram_transfer)begin
					fsm <= 5'hf;                         //writing x1 into addr 33 of inner ram
					read_write_command <= 1'h0;
					read_address <= 6'h21;
					write_address <= 6'h21; 
					cmd_transfer <= 1'h1;
					end
				else
					cmd_transfer <= 1'h0;
			end
			
			5'hf:begin
				if (interupt_ram_transfer)begin
					fsm <= 5'h10;                         //writing y1 into addr 39 of inner ram
					read_write_command <= 1'h0;
					read_address <= 6'h27;
					write_address <= 6'h27; 
					cmd_transfer <= 1'h1;
					end
				else
					cmd_transfer <= 1'h0;
			end
			
			5'h10:begin
				if (interupt_ram_transfer)begin
					fsm <= 5'h7;
				end
				else
					cmd_transfer<=1'h0;
			end
			
			
			5'hb:begin
						fsm<=5'h11;
						read_write_command <= 1'h1;
						read_address <= 6'h21;
						write_address <= 6'h21; 
						cmd_transfer <= 1'h1;
						end
			
			5'h11:begin	
				if(interupt_ram_transfer)begin
						fsm <= 5'h12;                         //writing y1 into addr 39 of outer ram
						read_write_command <= 1'h1;
						read_address <= 6'h27;
						write_address <= 6'h27; 
						cmd_transfer <= 1'h1;
						end
					else
						cmd_transfer <= 1'h0;
			end
			
			5'h12:begin
				if(interupt_ram_transfer) begin	
					interupt_scalar_mul <= 1'h1;
					fsm <= 5'h13;
					end
				else
					cmd_transfer <= 1'h0;
			end
			
			5'h13:begin
				interupt_scalar_mul <= 1'h0;
			end
			
		endcase
	 end
endmodule


