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
module Ram_transfer_scalar_mul#(
parameter Data=255)(

		input wire clk, 
		//Port of 1 Ram   outer Ram
		output reg b_w, 
		output reg [5:0]   b_adbus, 				
		output reg [Data:0] b_data_in, 
		input wire [Data:0] b_data_out,
		
	//port f 2nd Ram	 inner Ram
		output reg          a_w, 
		output reg [5:0]    a_adbus, 
		output reg [Data:0] a_data_in, 
		input wire [Data:0] a_data_out,
		
		input wire       read_write_command, //command for reading from 1 Ram or 2 Ram
		
		input wire [5:0] read_address,       //Read Address where to read from
		input wire [5:0] write_address,      //Write Addree where to write from
		input wire [1:0] no_of_chunks,     //Number of chunks to be write to anothr Ram
		input wire       command_transfer,           //command to perform or not transfer
		output reg       interupt_transfer,              //generate interupt on completion
		output reg       transfer_running
	                    //????????????????

    );
     
	reg [3:0] fsm;

	
	initial begin
		interupt_transfer<=1'h0;
		transfer_running <= 1'h0;
		end
	
	always @(posedge clk)begin
		
		
		if (command_transfer)begin
			fsm <= 4'h1;			
			end
			
		case (fsm)
		4'h1:begin 
		         transfer_running <= 1'h1;
					fsm<=4'h2;
				if (read_write_command)begin  //read					
					a_adbus<=read_address;
					end
				else begin 
					b_adbus<=read_address;
				end	
       end				
		
		4'h2:begin
				 fsm<=4'h3;
             if (read_write_command)begin  //read
					a_adbus<=read_address+1'h1;
					end
				else begin 
					b_adbus<=read_address+1'h1;
				end					 
				 end
			  
		4'h3:begin             		  
			if(no_of_chunks[1]) begin
				   fsm <= 4'h4;
					end
				 else begin
               fsm<=4'h7;
					interupt_transfer<=1'h1;
					end	
         if (read_write_command) begin       //WRITE
			      b_w<=1'h1;
					b_data_in<=a_data_out;
					b_adbus<=write_address;
					end
					
				else begin
					a_w<=1'h1;
					a_data_in<=b_data_out;	
			      a_adbus<=write_address;
					end
		end			
					
		4'h4:begin       								  			  
			fsm<=4'h5;
			if (read_write_command)  begin      //WRITE
					b_data_in<=a_data_out;
					b_adbus<=write_address+1'h1;
					end
				else begin
					a_data_in<=b_data_out;
					a_adbus<=write_address+1'h1;
					end
			
			
			 if (read_write_command)begin //read
					a_adbus<=read_address+2'h2;
					end
				else begin 
					b_adbus<=read_address+2'h2;
			  end
			end
				
		4'h5:begin
				
				if(no_of_chunks[0]) begin
					fsm <= 4'h6;
					end
				else begin
					fsm<=4'h7;
					interupt_transfer<=1'h1;
					end
										
			
       end
		 
		 4'h6:begin
				fsm<=4'h7;
				interupt_transfer<=1'h1;
				if (read_write_command)begin       //write
					b_data_in<=a_data_out;
					b_adbus<=write_address+2'h2;
					end
				else  begin
					a_data_in<=b_data_out;
					a_adbus<=write_address+2'h2;
					end
				end
						 		 
    4'h7:begin
			a_w<=1'h0;
			b_w<=1'h0;
			interupt_transfer<=1'h0;
			//transfer_running<=1'h0;
			fsm <= 4'h8;
			end
      		
	endcase
	
	end

endmodule
