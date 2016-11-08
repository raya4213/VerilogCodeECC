`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: BARC	
// Engineer: Rahul
// 
// Create Date:    13:18:11 09/22/2014 
// Design Name: 
// Module Name:    Ram_data_transfer 
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
module Ram_data_transfer#(
parameter Data=255)(

		input wire clk, 
		//Port of 1 Ram   outer Ram
		output reg          w_RAM, 
		output reg [5:0]    adbus_RAM, 				
		output reg [Data:0] data_in_RAM, 
		input wire [Data:0] data_out_RAM,
		
	//port f 2nd Ram	 inner Ram
		output reg          w_ECC, 
		output reg [5:0]    adbus_ECC, 
		output reg [Data:0] data_in_ECC, 
		input wire [Data:0] data_out_ECC,
	
		
		input wire       read_write_command, //command for reading from 1 Ram or 2 Ram
		
		input wire [5:0] read_address,       //Read Address where to read from
		input wire [5:0] write_address,      //Write Addree where to write from
		input wire [1:0] no_of_chunks,     //Number of chunks to be write to anothr Ram
		input wire       command,           //command to perform or not transfer
		output reg       interupt              //generate interupt on completi
    );
     
	reg [3:0] fsm;
	
	initial begin
		interupt<=1'h0;
		//transfer_running <= 1'h0;
		end
		
	always @(posedge clk)begin
		if (command) begin
			fsm<=4'h1;
			//transfer_running <= 1'h1;
		end
	 	
		case (fsm)
		4'h1:begin 
					
			
					fsm<=4'h2;
				if (read_write_command)begin  //read					
					adbus_ECC<=read_address;
					end
				else begin 
					adbus_RAM<=read_address;
				end	
       end				
		
		4'h2:begin
				 fsm<=4'h3;
             	 
				 end
			  
		4'h3:begin             		  
			if(no_of_chunks[1]) begin
				   fsm <= 4'h4;
					end
				 else begin
               fsm<=4'h9;
					interupt<=1'h1;
					end	
         if (read_write_command) begin       //WRITE
			      w_RAM<=1'h1;
					data_in_RAM<=data_out_ECC;
					adbus_RAM<=write_address;
					end
				else begin
					w_ECC<=1'h1;
					data_in_ECC<=data_out_RAM;	
			      adbus_ECC<=write_address;
					end
					
					
		   if (read_write_command)begin  //read
						if(read_address[5])
							adbus_ECC<=(read_address-4'h8)-1'h1;
						else
							adbus_ECC<=read_address+4'h8;
					end
				else begin 
					adbus_RAM<=read_address+1'h1;
				end				
		end			
					
		4'h4:begin
				fsm<=4'h5;
				end
					
		4'h5:begin       								  			  
			fsm<=4'h6;
			if (read_write_command)  begin      //WRITE
					data_in_RAM<=data_out_ECC;
					adbus_RAM<=write_address+1'h1;
					end
				else begin
					data_in_ECC<=data_out_RAM;
					adbus_ECC<=write_address-1'h1;
					end
			
			
			 if (read_write_command)begin //read
					adbus_ECC<=read_address-1'h1;
					end
				else begin 
					adbus_RAM<=read_address+2'h2;
			  end
			end
				
		4'h6:begin
				
				if(no_of_chunks[0]) begin
					fsm <= 4'h8;
					end
				else begin
					fsm<=4'h9;
					interupt<=1'h1;
					end
										
			
       end
		 
		 4'h8:begin
				fsm<=4'h9;
				interupt<=1'h1;
				if (read_write_command)begin       //write
					data_in_RAM<=data_out_ECC;
					adbus_RAM<=write_address+2'h2;
					end
				else  begin
					data_in_ECC<=data_out_RAM;
					adbus_ECC<=write_address+2'h2;
					end
				end
		
	
						 		 
    4'h9:begin
			w_ECC<=1'h0;
			w_RAM<=1'h0;
			interupt<=1'h0;
			end
      		
	endcase
	
	end

endmodule
