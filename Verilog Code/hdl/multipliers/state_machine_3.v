`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: BARC
// Engineer: Deepak
// 
// Create Date:    13:02:01 09/22/2014 
// Design Name: 
// Module Name:    state 
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
module state_machine_point_add#(
	 parameter Data=255,
	 parameter Addr=5)(
		input  wire            clk,		
		input  wire            w_RAM_outer_PORT,
		input  wire  [Addr:0]  adbus_RAM_outer_PORT,           //Address Bus
		input  wire  [Data:0]  data_in_RAM_outer_PORT,         //Data bus for taking input
		output wire  [Data:0]  data_out_RAM_outer_PORT,         //Data bus for taking output
	
		input  wire  [1:0]     command,   //command to perform point addition and doubling
		input  wire  [1:0]     no_of_chunks,
		input  wire  [255:0]   Data_Polynomial,
		input  wire  [9:0]     Data_len_Polynomial,
		
		output wire            interupt_point_double,	
		output wire            interupt_point_addition	
	
    );
	 
			reg  [Addr:0]  address_bus;
			reg            a_w1;
			reg [Addr:0]   a_adbus1;
			reg [Data:0]   a_data_in1;	

			wire [Data:0]   data_in_ECC,data_in_ECC_transfer,data_out_ECC,data_in_RAM_inner_PORT,data_out_RAM_inner_PORT;
			wire [Addr:0]   adbus_ECC,adbus_ECC_transfer,adbus_RAM_inner_PORT;
			wire [3:0]      command_ECC,command_ECC_addition,command_ECC_double;
			wire [2:0]      start_addr,start_addr_addition,start_addr_double;
			wire interupt_sqr,interupt_red,interupt_inv,interupt_swap,interupt_Xor,interupt_mul;		

			state_machine_ECC_primitive ECC_primitive_state_machine (
				.clk(clk), 
				
				.a_w(w_ECC), 
				.a_adbus(adbus_ECC), 
				.a_data_in(data_in_ECC), 
				.a_data_out(data_out_ECC),
				
				.command_ECC(command_ECC), 
				.start_addr(start_addr), 
				
				.interupt_sqr(interupt_sqr), 
				.interupt_red(interupt_red), 
				.interupt_swap(interupt_swap), 
				.interupt_inv(interupt_inv), 
				.interupt_mul(interupt_mul),
				.interupt_Xor(interupt_Xor),
				
			   .Data_len_Polynomial(Data_len_Polynomial),
				.Data_Polynomial(Data_Polynomial[63:0])
	          );
	
			wire [Addr:0]  read_address,read_address_addition,read_address_double, write_address , adbus_outer_transfer,
								write_address_addition ,write_address_double ;
			wire           read_write_command ,interupt_transfer,command_transfer;	  

			wire [Data:0]  data_in_outer_transfer;
			wire           cmd_double,cmd_addition;
			wire           w_ECC,w_RAM_inner_PORT;
   //Ram transfer module for transferring Data from outer to ECC primivtive Ram      			
		 Ram_data_transfer Ram_transfer (
				.clk(clk), 
				
			   .w_RAM(w_RAM_inner_PORT), 
				.adbus_RAM(adbus_RAM_inner_PORT), 				        //port for  Ram in this layer
				.data_in_RAM(data_in_RAM_inner_PORT), 
				.data_out_RAM(data_out_RAM_inner_PORT),

				.w_ECC(w_ECC),                             				//port for inner Ram
				.adbus_ECC(adbus_ECC), 
				.data_in_ECC(data_in_ECC), 
				.data_out_ECC(data_out_ECC),			
				
				.read_write_command(read_write_command),    //port for performing operation
				.read_address(read_address),
				.write_address(write_address),
				.no_of_chunks(no_of_chunks),
				.command(command_transfer),
				
				.interupt(interupt_transfer)
			);		
								 
		//Ram interface Module	
			Outer_Ram_interface Ram_interface (
				.clk(clk), 
				.a_w(w_RAM_outer_PORT), 
				.a_adbus(adbus_RAM_outer_PORT),                        //Port to interface Outside
				.a_data_in(data_in_RAM_outer_PORT), 
				.a_data_out(data_out_RAM_outer_PORT), 
				
				.b_w(w_RAM_inner_PORT), 
				.b_adbus(adbus_RAM_inner_PORT),             //Port for interfacing inside 
				.b_data_in(data_in_RAM_inner_PORT), 
				.b_data_out(data_out_RAM_inner_PORT)
			);	
	
		wire command_transfer_double, command_transfer_addition;
		wire read_write_command_double,read_write_command_addition;

    	point_addition_module point_addition (
		.clk(clk), 
		.interupt_sqr(interupt_sqr), 
		.interupt_red(interupt_red), 
		.interupt_swap(interupt_swap), 
		.interupt_inv(interupt_inv), 
		.interupt_mul(interupt_mul), 
		.interupt_Xor(interupt_Xor), 
		.interupt_transfer(interupt_transfer),
		
		.start_addr(start_addr_addition), 
		.command_ECC(command_ECC_addition),
		
		.interupt(interupt_point_addition),
		.cmd_addition(cmd_addition),
		
		.read_write_command(read_write_command_addition),
		.read_address(read_address_addition),
		.write_address(write_address_addition),
		.Data_len_Polynomial(Data_len_Polynomial),
		
		.command_transfer(command_transfer_addition),
		.command(command)                  //comand to perform point addition
	);	
	
		
	point_double_module point_double (
		.clk(clk), 
		.interupt_sqr(interupt_sqr), 
		.interupt_red(interupt_red), 
		.interupt_swap(interupt_swap), 
		.interupt_inv(interupt_inv), 
		.interupt_mul(interupt_mul), 
		.interupt_Xor(interupt_Xor), 
		.interupt_transfer(interupt_transfer),
		
		.start_addr(start_addr_double),            //start_addr where to start ECC primitive operation 
		.command_ECC(command_ECC_double),               //command to perform ECC primitive
		.interupt(interupt_point_double),
		.cmd_double(cmd_double),             //enable to perform doubling operation
		
		.read_write_command(read_write_command_double),
		.read_address(read_address_double),
		.write_address(write_address_double),
		
		.command_transfer(command_transfer_double),
		.Data_len_Polynomial(Data_len_Polynomial),
		.command(command)                   //command to perform point doubling
	);	


	assign start_addr=cmd_addition?start_addr_addition:
                     cmd_double?start_addr_double:start_addr;



	assign command_ECC=cmd_addition?command_ECC_addition:
                      cmd_double?command_ECC_double:command_ECC;

	assign read_write_command=cmd_double?read_write_command_double:
	                          cmd_addition?read_write_command_addition:1'hz;
									  
	assign read_address=cmd_double?read_address_double:
	                    cmd_addition?read_address_addition:read_address;
	
	assign write_address=cmd_double?write_address_double:
	                     cmd_addition?write_address_addition:write_address;
								
	assign command_transfer=cmd_double?command_transfer_double:
	                        cmd_addition?command_transfer_addition:1'h0;   
endmodule
