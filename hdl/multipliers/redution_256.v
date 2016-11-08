`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:BARC
// Engineer:Deepak Kapoor  (Modified)
//
// Create Date:    12:43:52 08/01/2014
// Design Name:
// Module Name:    reduction_module
// Project Name:
// Target Devices:
// Tool versions:
// Description:
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module reduction_256_module#(
    parameter REDUCTION=3'b100,
     parameter addr = 3,
     parameter DATA = 256
)(
 
			input wire [63:0]            Data_Polynomial,

			output  reg                   b_w_C,
			output  reg [(addr-1):0]      b_adbus_C,
			input   wire  [(DATA-1):0]    b_data_out_C,
			output  reg [(DATA-1):0]      b_data_in_C,

			output  reg                  b_w_D,
			output  reg [(addr-1):0]     b_adbus_D,
			output  reg [(DATA-1):0]     b_data_in_D,
			input   wire[(DATA-1):0]     b_data_out_D,


			input   wire                 clk,
			input   wire [(addr-1):0]    start_addr,  
			output  reg [135:0]          A1,
			output  reg [135:0]          B1,
			output  reg [2:0]            select_line,

			input   wire   [135:0]       D_Out1,

			input wire  [3:0]            command,
			output reg                   cmd_red,
			output reg                   interupt
  
    );  
 
    reg [7:0]    frst_chunk,secnd_chunk,B_Mask_Pos,Lut_shift_data;
	 reg [9:0]    position_shift;
    reg [3:0]    Poly_len_Chunk,CHECK;    //check To check previous 64 is been reduced or not
    reg [2:0]    C_byte_Pos,D_byte_Pos,i,shift_check;
    reg [4:0]    byte_position_reduced;
    reg [4:0]    word_pos1,byte_pos1,word_pos2,byte_pos2,var_1,var_3;
    reg [3:0]    byte_pos_Reduction;
	 reg [2:0]    C_start_addr,D_start_addr;
    reg [63:0]   A_Red_Poly1,A_Poly1,last_byte,last_chunk,A_Mask,last_64_chunk;
    reg [2:0]    check,addr_affected_D_1,addr_affected_C_1,addr_affected_D_2,addr_affected_C_2,check_last_byte;
    reg [8:0]    Mod,count;
    
    wire [63:0]  A_Poly ,A_Red_Poly,Data_byte_C,Data_byte_D,Out_Mask;
    wire [135:0] Data_64_2_Chunk;
    wire [255:0] var_C_left,var_D_left;
	 wire [127:0] Lut_Out1,Lut_Out2;
    wire [135:0] Lut_Out_shift1,Lut_Out_shift2;	
    wire  [271:0]  Lut_Out_Shift;	 
    
    LOOK_UP_module uut4 (
        .A_Poly(A_Poly),
        .B(A_Red_Poly),
        .D_out_1(Lut_Out1),
		  .D_out_2(Lut_Out2)
    );
	 	 	 
	 Masking_Module uut (
		.A(A_Mask), 
		.B(B_Mask_Pos), 
		.Out(Out_Mask)
	);
 
    assign Data_64_2_Chunk=(byte_pos_Reduction==3'h0)?{b_data_out_D[7:0],b_data_out_C[255:128]}:
                           (byte_pos_Reduction==3'h1)?b_data_out_C[199:64]:
                           (byte_pos_Reduction==3'h2)?b_data_out_C[135:0]:
                           (byte_pos_Reduction==3'h3)?{b_data_out_C[71:0],b_data_out_D[255:192]}:
                           (byte_pos_Reduction==3'h4)?{b_data_out_C[7:0],b_data_out_D[255:128]}:
                           (byte_pos_Reduction==3'h5)?b_data_out_D[199:64]:
                           (byte_pos_Reduction==3'h6)?b_data_out_D[135:0]:
                           (byte_pos_Reduction==3'h7)?{b_data_out_D[71:0],b_data_out_C[255:192]}:136'hzz;
     
    assign var_C_left=(byte_pos_Reduction==3'h0)?{D_Out1[127:0],b_data_out_C[127:0]}:
                      (byte_pos_Reduction==3'h1)?{b_data_out_C[255:200],D_Out1,b_data_out_C[63:0]}:
                      (byte_pos_Reduction==3'h2)?{b_data_out_C[255:136],D_Out1}:
                      (byte_pos_Reduction==3'h3)?{b_data_out_C[255:72],D_Out1[135:64]}:
                      (byte_pos_Reduction==3'h7)?{D_Out1[63:0],b_data_out_C[191:0]}:
							 (byte_pos_Reduction==3'h4)?{b_data_out_C[255:8],D_Out1[135:128]}:b_data_out_C;
   
    assign var_D_left=(byte_pos_Reduction==3'h0)?{b_data_out_D[255:8],D_Out1[135:128]}:
	                   (byte_pos_Reduction==3'h3)?{D_Out1[63:0],b_data_out_D[191:0]}:
							 (byte_pos_Reduction==3'h4)?{D_Out1[127:0],b_data_out_D[127:0]}:
                      (byte_pos_Reduction==3'h5)?{b_data_out_D[255:200],D_Out1,b_data_out_D[63:0]}:
                      (byte_pos_Reduction==3'h6)?{b_data_out_D[255:136],D_Out1}:
                      (byte_pos_Reduction==3'h7)?{b_data_out_D[255:72],D_Out1[135:64]}:b_data_out_D;                           
                       
		assign Data_byte_C=(C_byte_Pos[2]?b_data_out_C[63:0]:((!C_byte_Pos[1])?b_data_out_C[255:192]:(C_byte_Pos[0]?b_data_out_C[127:64]:b_data_out_C[191:128])));                   
		assign Data_byte_D=(D_byte_Pos[2]?b_data_out_D[63:0]:((!D_byte_Pos[1])?b_data_out_D[255:192]:(D_byte_Pos[0]?b_data_out_D[127:64]:b_data_out_D[191:128])));
		
		assign A_Red_Poly=A_Red_Poly1;
		assign A_Poly    = A_Poly1;

      assign Lut_Out_Shift={Lut_Out_shift1,Lut_Out_shift2};
      assign Lut_Out_shift1=(Lut_shift_data==3'h1)?{Lut_Out1,1'h0}:
                           ((Lut_shift_data==3'h2)?{Lut_Out1,2'h0}:
                           ((Lut_shift_data==3'h3)?{Lut_Out1,3'h0}:
                       		((Lut_shift_data==3'h4)?{Lut_Out1,4'h0}:
                           ((Lut_shift_data==3'h5)?{Lut_Out1,5'h0}:
                           ((Lut_shift_data==3'h6)?{Lut_Out1,6'h0}:
                           ((Lut_shift_data==3'h7)?{1'h0,Lut_Out1,7'h0}:{8'h0,Lut_Out1}))))));								
    
	   assign Lut_Out_shift2=(Lut_shift_data==3'h1)?{Lut_Out2,1'h0}:
                           ((Lut_shift_data==3'h2)?{Lut_Out2,2'h0}:
                           ((Lut_shift_data==3'h3)?{Lut_Out2,3'h0}:
                       		((Lut_shift_data==3'h4)?{Lut_Out2,4'h0}:
                           ((Lut_shift_data==3'h5)?{Lut_Out2,5'h0}:
                           ((Lut_shift_data==3'h6)?{Lut_Out2,6'h0}:
                           ((Lut_shift_data==3'h7)?{1'h0,Lut_Out2,7'h0}:{8'h0,Lut_Out2}))))));	
	 
  initial begin
		cmd_red<=1'h0;
		count<=0;
		interupt<=1'h0;
   end
        always @(posedge clk)begin
        case(command)
                REDUCTION:begin
                count<=count+1'h1;
						Mod<=8'b0001;   
                  					
						end
        endcase       
     
        case(Mod)
            8'h1:begin
                Mod<=8'h2;
					 cmd_red<=1'h1;	
                i<=1'h0;					 
                             
                byte_position_reduced<=1'h0;  
                b_adbus_C<=start_addr;
					 C_start_addr<=start_addr;
					 D_start_addr<=start_addr;
					 C_byte_Pos<=1'h1;
                addr_affected_C_1<=start_addr;
                addr_affected_D_1<=start_addr;
                addr_affected_C_2<=start_addr;
                addr_affected_D_2<=start_addr;
                 end                
                
           8'h2:begin
              Mod<=8'h3;     
         end                    
              
		8'h3:begin
				Mod<=8'h4;
				frst_chunk<=Data_Polynomial[23:16];         //frst chunk of POlynomial
				secnd_chunk<=Data_Polynomial[7:0];
				
				position_shift<=9'h100-(Data_Polynomial[41:32]%9'h100);                //Extra bit need to be reduced
				Poly_len_Chunk<=(Data_Polynomial[41:32]/8'h80)+1'h1;         //no of 128 bit chunk
				//Poly_len<=b_data_out_B[41:32];
				Lut_shift_data<=3'h7-Data_Polynomial[41:32]%4'h8;	  
				/*word_pos1 is frst chunks word position*/
				/*byte_pos1 is frst chunks byte position*/

				word_pos1<=(byte_position_reduced+Data_Polynomial[31:24])/4'h8;       
				byte_pos1<=(byte_position_reduced+Data_Polynomial[31:24])%4'h8;
				var_1<=(byte_position_reduced+Data_Polynomial[31:24])/4'h8;
				var_3<=(byte_position_reduced+Data_Polynomial[15:8])/4'h8;

				word_pos2<=(byte_position_reduced+Data_Polynomial[15:8])/4'h8;
				byte_pos2<=(byte_position_reduced+Data_Polynomial[15:8])%4'h8;
				
				if((Data_Polynomial[15:8]/4'h8)==4'h8) begin
					addr_affected_D_2<=addr_affected_D_2-1'h1;
					addr_affected_C_2<=addr_affected_C_2-1'h1;
					end
				if(((Data_Polynomial[31:24])/4'h8)==4'h8) begin
					addr_affected_D_1<=addr_affected_D_1-1'h1;
					addr_affected_C_1<=addr_affected_C_1-1'h1;  
					end
		end
						  					          						
    
        8'h4:begin  
				check_last_byte<=position_shift/8'h40;  //byte to be reducd at last shift in 256 bit
				A_Poly1<={byte_pos1[3:0],frst_chunk,byte_pos2[3:0],secnd_chunk};

				if(Poly_len_Chunk[1]||Poly_len_Chunk[2]) begin	
				Mod<=8'h5;
				C_start_addr<=C_start_addr-1'h1;//reduce for next 256 byte


				b_w_C<=1'h0;
				A_Red_Poly1<=Data_byte_C;	 /*Acessing 64 chunk to be affected*/

				if(((word_pos1)==3'h7)) begin
					b_adbus_C<= addr_affected_C_1-1'h1;
					addr_affected_C_1<=addr_affected_C_1-1'h1;						 
					end

				else begin
					b_adbus_C<= addr_affected_C_1;
					end

				b_adbus_D<= addr_affected_D_1;
				byte_pos_Reduction<=word_pos1%8; 
				end

				else begin
					Mod<=8'h8f;        //go to last byte reduction of C chunk.
					check_last_byte<=position_shift/8'h40;	           //calculating last 64 chunk to be reduced						
					end				  
				end

        8'h5:begin
                 Mod<=8'h6;
					  word_pos1<=word_pos1%4'h8;
					  word_pos2<=word_pos2%4'h8;
                 end 
                              /*Xor respective byte with Lut*/            
        8'h6:begin
                 Mod<=8'h7;
                 A1<=Data_64_2_Chunk;           
                 B1<=Lut_Out_Shift[271:136];
                 select_line<=3'b111;                                                               
                 end
                 /*updating Memory Polynomial*/      
         8'h7:begin
                Mod<=8'h8;
                b_w_C<=1'h1;
                b_data_in_C<=var_C_left;
                b_w_D<=1'h1;
                b_data_in_D<=var_D_left;
                end
   /*Reducing second byte of reduction Polynomial*/
        8'h8:begin
				Mod<=8'h9;         
				b_w_C<=1'h0;
				b_w_D<=1'h0;                              
				if(word_pos2==3'h7) begin
						  b_adbus_C<= addr_affected_C_2-1'h1;
						  addr_affected_C_2<=addr_affected_C_2-1'h1;
							  end
				  else begin
							  b_adbus_C<= addr_affected_C_2;
						 end
					b_adbus_D<= addr_affected_D_2;
					byte_pos_Reduction<=word_pos2%8;
					  
					byte_position_reduced<=byte_position_reduced+1'h1;                            
						end
                    
         8'h9:begin
              Mod<=8'ha;
              word_pos1<=(var_1+byte_position_reduced)%4'h8;
              word_pos2<=(var_3+byte_position_reduced)%4'h8;
              end
                     
         8'ha:begin
                Mod<=8'hb;                                                             
                A1<=Data_64_2_Chunk;  
                B1<=Lut_Out_Shift[135:0];
                select_line<=3'b111;                           
                end
    /*update in memory the modified chunk*/                  
         8'hb:begin          
                  Mod<=8'hc;                  
                  b_w_C<=1'h1;
                  b_data_in_C<=var_C_left;
                  b_w_D<=1'h1;
                  b_data_in_D<=var_D_left;           
                  end
          
			8'hc:begin
					  Mod<=8'hd;
					  b_w_C<=1'h0;
					  b_adbus_C<=start_addr;
					  C_byte_Pos<=2;         
                 end
            
             8'hd:begin
						 Mod<=8'he;                    
								if(word_pos1==3'h7) begin
									b_adbus_C<= addr_affected_C_1-1'h1;
									addr_affected_C_1<=addr_affected_C_1-1'h1;
						 end
						 else begin
									b_adbus_C<= addr_affected_C_1;
						 end
						 b_adbus_D<= addr_affected_D_1;
						 byte_pos_Reduction<=word_pos1%4'h8; 
                   end
    
       8'he:begin
                Mod<=8'hf;
                b_w_C<=1'h0;        
                A_Red_Poly1<=Data_byte_C;                                                                                  
                end
        
        8'hf:begin
                 Mod<=8'h10;
                 A1<=Data_64_2_Chunk;           
                B1<=Lut_Out_Shift[271:136];
                 select_line<=3'b111;                                                               
                 end
                 /*updating Memory Polynomial*/      
         8'h10:begin
                 Mod<=8'h11;
                 b_w_C<=1'h1;
                 b_data_in_C<=var_C_left;
                 b_w_D<=1'h1;
                 b_data_in_D<=var_D_left;                                           
                 end
   /*Reducing second byte of reduction Polynomial*/
        8'h11:begin
                Mod<=8'h12;        
                b_w_C<=1'h0;
                b_w_D<=1'h0;                  

					 if(word_pos2==3'h7) begin
							b_adbus_C<= addr_affected_C_2-1'h1;
							addr_affected_C_2<=addr_affected_C_2-1'h1;
							end
					 else begin
							b_adbus_C<= addr_affected_C_2;
							end
					  b_adbus_D<= addr_affected_D_2;
					  byte_pos_Reduction<=word_pos2%4'h8;
					 
					  byte_position_reduced<=byte_position_reduced+1'h1;                                    
                end
                    
                    
        8'h12:begin
					 Mod<=8'h13;
					 word_pos1<=(var_1+byte_position_reduced)%4'h8;
					 word_pos2<=(var_3+byte_position_reduced)%4'h8;                 
				    end
                     
        8'h13:begin
                 Mod<=8'h14;
        /*XOR OF 128 BIT*/                                                                          
                 A1<=Data_64_2_Chunk;  
                 B1<=Lut_Out_Shift[135:0];
                 select_line<=3'b111;                       
                 end
    /*update in memory the modified chunk*/                  
         8'h14:begin          
					 Mod<=8'h15;  
					 b_w_C<=1'h1;
					 b_data_in_C<=var_C_left;
					 b_w_D<=1'h1;
					 b_data_in_D<=var_D_left;
                end
               
    /*SECOND Byte reduction*/
         8'h15:begin
					  Mod<=8'h16;
					  b_w_C<=1'h0;
					  b_adbus_C<=start_addr;
					  C_byte_Pos<=2'h3;                         
					  end
            
         8'h16:begin
             Mod<=8'h17;
             if(word_pos1==3'h7) begin                                
                    b_adbus_C<= addr_affected_C_1-1'h1;
                    addr_affected_C_1<=addr_affected_C_1-1'h1;
             end
             else begin
                    b_adbus_C<= addr_affected_C_1;
             end
             b_adbus_D<= addr_affected_D_1;
             byte_pos_Reduction<=word_pos1%8;
         end
            
    
       8'h17:begin
             Mod<=8'h18;
             b_w_C<=1'h0;        
             A_Red_Poly1<=Data_byte_C;       //third chunk to be reduced
                /*Accessing respective byte */                                                                                
              end
                    
        8'h18:begin
              Mod<=8'h19;
              A1<=Data_64_2_Chunk;           
              B1<=Lut_Out_Shift[271:136];
              select_line<=3'b111;                                                               
            end
                 /*updating Memory Polynomial*/      
         8'h19:begin
                Mod<=8'h20;
                b_w_C<=1'h1;
                b_data_in_C<=var_C_left;
                b_w_D<=1'h1;
                b_data_in_D<=var_D_left;                                           
         end
   /*Reducing second byte of reduction Polynomial*/
        8'h20:begin
               Mod<=8'h21;        
               b_w_C<=1'h0;
               b_w_D<=1'h0;                  
            
               if(word_pos2==3'h7) begin
                            b_adbus_C<= addr_affected_C_2-1'h1;
                            addr_affected_C_2<=addr_affected_C_2-1'h1;
                            end
                else begin
                        b_adbus_C<= addr_affected_C_2;
                        end
                b_adbus_D<= addr_affected_D_2;
                byte_pos_Reduction<=word_pos2%8;      
                byte_position_reduced<=byte_position_reduced+1'h1;                                    
                end
                    
                    
         8'h21:begin
              Mod<=8'h22;
              word_pos1<=(var_1+byte_position_reduced)%4'h8;
              word_pos2<=(var_3+byte_position_reduced)%4'h8;                 
					end
                     
				8'h22:begin
					Mod<=8'h23;
					/*XOR OF 128 BIT*/                                                            
					A1<=Data_64_2_Chunk;  
					B1<=Lut_Out_Shift[135:0];
					select_line<=3'b111;                       
					end
    /*update in memory the modified chunk*/                  
				8'h23:begin          
                Mod<=8'h24; 
                b_w_C<=1'h1;
                b_data_in_C<=var_C_left;
                b_w_D<=1'h1;
                b_data_in_D<=var_D_left;
					 end
//3rd byte reduction
         8'h24:begin
				  Mod<=8'h25;
				  b_w_C<=1'h0;
				  b_adbus_C<=start_addr;
				  C_byte_Pos<=3'h4;                         
				  end
            
             8'h25:begin
                 Mod<=8'h26;
             end
            
			8'h26:begin
            Mod<=8'h27;
            b_w_C<=1'h1;        
            b_data_in_C<=256'h00;    //update the whole reduced chunk to zeo
            C_byte_Pos<=4;
            //Data_256<=b_data_out_C;                       
				end
    
			8'h27:begin
                Mod<=8'h28;
                b_w_C<=1'h0;        
                A_Red_Poly1<=Data_byte_C;    
                if(word_pos1==3'h7) begin
                        b_adbus_C<= addr_affected_C_1-1'h1;
                        addr_affected_C_1<=addr_affected_C_1-1'h1;
                end
                else begin
                        b_adbus_C<= addr_affected_C_1;
                end
                b_adbus_D<= addr_affected_D_1;
                byte_pos_Reduction<=word_pos1%8;                                                                   
              end
            
         8'h28:begin
                Mod<=8'h29;
              end 
        
			8'h29:begin
                  Mod<=8'h2a;
                  A1<=Data_64_2_Chunk;           
                  B1<=Lut_Out_Shift[271:136];
                  select_line<=3'b111;                                                               
            end
                 /*updating Memory Polynomial*/      
         8'h2a:begin
                 Mod<=8'h2b;
                 b_w_C<=1'h1;
                 b_data_in_C<=var_C_left;
                 b_w_D<=1'h1;
                 b_data_in_D<=var_D_left;
         // byte_position_reduced<=byte_position_reduced+1'h1;                                 
         end
                   
           
   //*Reducing second byte chunkof reduction Polynomial ///
   
        8'h2b:begin
               Mod<=8'h2c;        
               b_w_C<=1'h0;
               b_w_D<=1'h0;                  
            
              if(word_pos2==3'h7) begin                                                
                     b_adbus_C<= addr_affected_C_2-1'h1;
                     addr_affected_C_2<=addr_affected_C_2-1'h1;
                     end
              else begin
                    b_adbus_C<= addr_affected_C_2;
                    end
                               
                b_adbus_D<= addr_affected_D_2;                    
                byte_pos_Reduction<=word_pos2%8;
                byte_position_reduced<=byte_position_reduced+1'h1;                                                                     
                end
                    
                    
         8'h2c:begin
              Mod<=8'h2d;
              word_pos1<=(var_1+byte_position_reduced)%8;
              word_pos2<=(var_3+byte_position_reduced)%8;                           
					end
                     
				8'h2d:begin
					Mod<=8'h2f;
					/*XOR OF 128 BIT*/                                                          
					A1<=Data_64_2_Chunk;  
					B1<=Lut_Out_Shift[135:0];
					select_line<=3'b111;                       
					end
    /*update in memory the modified chunk*/                  
			8'h2f:begin 
				Mod<=8'h30;                                      
				b_w_C<=1'h1;
				b_data_in_C<=var_C_left;
				b_w_D<=1'h1;
				b_data_in_D<=var_D_left;
				end
               
   /////////////////////////////Second 256 byte reduction/////////////////////////////

        8'h30:begin
		          if(Poly_len_Chunk[2]) begin
					    D_start_addr<=D_start_addr-1'h1;
						 Mod<=8'h31;        
						 b_w_C<=1'h0;
						 b_w_C<=1'h0;
					  
						if(word_pos1[2])
							addr_affected_C_1<=addr_affected_C_1-1'h1;
						if(word_pos2[2])
							addr_affected_C_2<=addr_affected_C_2-1'h1;    
								  
						 b_adbus_D<=start_addr;
						 D_byte_Pos<=1;
                   end
              else begin
                 Mod<=8'hc6;					        
					  end					  
					end
                
			8'h31:begin
				 Mod<=8'h35; 
				 if((word_pos1==3'h3)) begin
					 b_adbus_D<= addr_affected_D_1-1'h1;
					 addr_affected_D_1<=addr_affected_D_1-1'h1;
					end
				 else begin
						 b_adbus_D<= addr_affected_D_1;
					 end
				  b_adbus_C<= addr_affected_C_1;
				  byte_pos_Reduction<=word_pos1%8;                  
		        end                    
			  
    
       8'h35:begin       
            //Data_256<=b_data_out_D;
				Mod<=8'h37;
				b_w_D<=1'h0;
				A_Red_Poly1<=Data_byte_D;
				/*Acessing 64 chunk to be affected*/                                                                      
				end
            
        
                    /*Xor respective byte with Lut*/            
        8'h37:begin
              Mod<=8'h39;
              A1<=Data_64_2_Chunk;           
              B1<=Lut_Out_Shift[271:136];
              select_line<=3'b111;                                                               
					end
                 /*updating Memory Polynomial*/      
         8'h39:begin
				Mod<=8'h3a;
				b_w_C<=1'h1;
				b_data_in_C<=var_C_left;
				b_w_D<=1'h1;
				b_data_in_D<=var_D_left;                                                  
				end
   /*Reducing second byte of reduction Polynomial*/
			8'h3a:begin 
                Mod<=8'h3b;
                b_w_C<=1'h0;
                b_w_D<=1'h0;                  
                if((word_pos2==3'h3)) begin
                    b_adbus_D<= addr_affected_D_2-1'h1;
                    addr_affected_D_2<=addr_affected_D_2-1'h1;
                    end
                else begin
                    b_adbus_D<= addr_affected_D_2;
                    end
                b_adbus_C<= addr_affected_C_2;
                byte_pos_Reduction<=word_pos2%8;
                byte_position_reduced<=byte_position_reduced+1'h1;                            
                end

            8'h3b:begin
                Mod<=8'h3c;
                word_pos1<=(var_1+byte_position_reduced)%8;
                word_pos2<=(var_3+byte_position_reduced)%8;
                end

            8'h3c:begin
                Mod<=8'h3d;                                                                                        
                A1<=Data_64_2_Chunk;  
                B1<=Lut_Out_Shift[135:0];
                select_line<=3'b111;    
                end
    /*update in memory the modified chunk*/                  
         8'h3d:begin          
				Mod<=8'h3e;                                   
				b_w_C<=1'h1;
				b_data_in_C<=var_C_left;
				b_w_D<=1'h1;
				b_data_in_D<=var_D_left;
				end
     
         8'h3e:begin
				Mod<=8'h3f;
				b_w_D<=1'h0;
				b_adbus_D<=start_addr;
				D_byte_Pos<=2'h2;           
				end
            
         8'h3f:begin
				Mod<=8'h40;
				if(word_pos1==3'h3) begin
					b_adbus_D<= addr_affected_D_1-1'h1;
					addr_affected_D_1<=addr_affected_D_1-1'h1;
					end
				else begin
					b_adbus_D<= addr_affected_D_1;
					end
				b_adbus_C<= addr_affected_C_1;
				byte_pos_Reduction<=word_pos1%8;  
				end
            
    
       8'h40:begin
				Mod<=8'h42;
				b_w_C<=1'h0; 
				// Data_256<=b_data_out_D;                     
				A_Red_Poly1<=Data_byte_D;    
				end           
        
			8'h42:begin
              Mod<=8'h44;
              A1<=Data_64_2_Chunk;           
              B1<=Lut_Out_Shift[271:136];
              select_line<=3'b111;                                                               
					end
                 /*updating Memory Polynomial*/      
			8'h44:begin
				  Mod<=8'h45;
				  b_w_C<=1'h1;
				  b_data_in_C<=var_C_left;
				  b_w_D<=1'h1;
				  b_data_in_D<=var_D_left;                                           
					end
   /*Reducing second byte of reduction Polynomial*/
        8'h45:begin
				  Mod<=8'h46;        
				  b_w_C<=1'h0;
				  b_w_D<=1'h0;                  

				  if(word_pos2==3'h3) begin
						b_adbus_D<= addr_affected_D_2-1'h1;
						addr_affected_D_2<=addr_affected_D_2-1'h1;
						end
				  else begin
						b_adbus_D<= addr_affected_D_2;
						end
				  b_adbus_C<= addr_affected_C_2;
				  byte_pos_Reduction<=word_pos2%8;
		 
				  byte_position_reduced<=byte_position_reduced+1'h1;                                    
                end                    
                    
         8'h46:begin
              Mod<=8'h47;
              word_pos1<=(var_1+byte_position_reduced)%8;
              word_pos2<=(var_3+byte_position_reduced)%8;               
					end
                     
         8'h47:begin
				Mod<=8'h48;
				/*XOR OF 128 BIT*/          
				A1<=Data_64_2_Chunk;  
				B1<=Lut_Out_Shift[135:0];
				select_line<=3'b111;                       
				end
    /*update in memory the modified chunk*/                  
         8'h48:begin          
                Mod<=8'h49;               
                b_w_C<=1'h1;
                b_data_in_C<=var_C_left;
                b_w_D<=1'h1;
                b_data_in_D<=var_D_left;
                end
    /*SECOND Byte reduction*/
         8'h49:begin
					Mod<=8'h4a;
					b_w_D<=1'h0;
					b_adbus_D<=start_addr;
					D_byte_Pos<=2'h3;                         
					end
        
         8'h4a:begin
             Mod<=8'h4b;
              if(word_pos1==3'h3) begin                                
                        b_adbus_D<= addr_affected_D_1-1'h1;
                        addr_affected_D_1<=addr_affected_D_1-1'h1;
             end
             else begin
                        b_adbus_D<= addr_affected_D_1;
             end
             b_adbus_C<= addr_affected_C_1;
             byte_pos_Reduction<=word_pos1%8; 
					end
           
    
			 8'h4b:begin
					Mod<=8'h4d;
					// Data_256<=b_data_out_D;    
					b_w_D<=1'h0;        
					A_Red_Poly1<=Data_byte_D;     //third chunk to be reduced                                                                                      
					end
                             
				8'h4d:begin
                 Mod<=8'h4f;
                 A1<=Data_64_2_Chunk;           
                 B1<=Lut_Out_Shift[271:136];
                 select_line<=3'b111;                                                               
					end
                 /*updating Memory Polynomial*/      
			8'h4f:begin
				Mod<=8'h50;
				b_w_C<=1'h1;
				b_data_in_C<=var_C_left;
				b_w_D<=1'h1;
				b_data_in_D<=var_D_left;                                                          
				end
   /*Reducing second byte of reduction Polynomial*/
			8'h50:begin
               Mod<=8'h51;        
               b_w_C<=1'h0;
               b_w_D<=1'h0;                  
            
               if(word_pos2==3'h3) begin
                            b_adbus_D<= addr_affected_D_2-1'h1;
                            addr_affected_D_2<=addr_affected_D_2-1'h1;
                            end
                else begin
                        b_adbus_D<= addr_affected_D_2;
                        end
                b_adbus_C<= addr_affected_C_2;
                byte_pos_Reduction<=word_pos2%8;       
                byte_position_reduced<=byte_position_reduced+1'h1;                                    
                end
                    
                    
         8'h51:begin
					Mod<=8'h52;
					word_pos1<=(var_1+byte_position_reduced)%8;
					word_pos2<=(var_3+byte_position_reduced)%8;                 
					end
                     
         8'h52:begin
				Mod<=8'h53;
				/*XOR OF 128 BIT*/																	
				A1<=Data_64_2_Chunk;  
				B1<=Lut_Out_Shift[135:0];
				select_line<=3'b111;                       
        end
    /*update in memory the modified chunk*/                  
         8'h53:begin          
				Mod<=8'h54; 
				b_w_C<=1'h1;
				b_data_in_C<=var_C_left;
				b_w_D<=1'h1;
				b_data_in_D<=var_D_left;
				end

         8'h54:begin
				Mod<=8'h55;
				b_w_D<=1'h0;
				b_adbus_D<=start_addr;
				D_byte_Pos<=3'h4;                         
				end
            
         8'h55:begin
             Mod<=8'h56;
				end
            
       8'h56:begin
                Mod<=8'h57;
                b_w_D<=1'h1;        
                b_data_in_D<=256'h00;    //change
            //    Data_256<=b_data_out_D;                        
      end
    
       8'h57:begin
             Mod<=8'h58;
             b_w_D<=1'h0;        
             A_Red_Poly1<=Data_byte_D;    
             if(word_pos1==3'h3 ) begin
					b_adbus_D<= addr_affected_D_1-1'h1;
					addr_affected_D_1<=addr_affected_D_1-1'h1;
					end
             else begin
					b_adbus_D<= addr_affected_D_1;
					end
             b_adbus_C<= addr_affected_C_1;
             byte_pos_Reduction<=word_pos1%8;                                                                   
          end
            
        8'h58:begin
				Mod<=8'h59;
				end 
        
        8'h59:begin
                  Mod<=8'h5a;
                  A1<=Data_64_2_Chunk;           
                 B1<=Lut_Out_Shift[271:136];
                  select_line<=3'b111;                                                               
            end
                 /*updating Memory Polynomial*/      
         8'h5a:begin
                Mod<=8'h5b;
                b_w_C<=1'h1;
                b_data_in_C<=var_C_left;
                b_w_D<=1'h1;
                b_data_in_D<=var_D_left;                                            
         end
   /*Reducing second byte of reduction Polynomial*/
        8'h5b:begin
               Mod<=8'h5c;        
               b_w_C<=1'h0;
               b_w_D<=1'h0;                  
            
                 if(word_pos2==3'h3) begin
                            b_adbus_D<= addr_affected_D_2-1'h1;
                            addr_affected_D_2<=addr_affected_D_2-1'h1;
                            end
                else begin
                        b_adbus_D<= addr_affected_D_2;
                        end
                b_adbus_C<= addr_affected_C_2;
                byte_pos_Reduction<=word_pos2%8;          
                byte_position_reduced<=byte_position_reduced+1'h1;                                    
                end
                    
         8'h5c:begin
              Mod<=8'h5d;
              word_pos1<=(var_1+byte_position_reduced)%8;
              word_pos2<=(var_3+byte_position_reduced)%8;             
        end
                     
         8'h5d:begin
                  Mod<=8'h5e;
                /*XOR OF 128 BIT*/                                                                        
                A1<=Data_64_2_Chunk;  
                B1<=Lut_Out_Shift[135:0];
                select_line<=3'b111;                       
        end
    //update in memory the modified chunk                 
         8'h5e:begin
                Mod<=8'h8f;                         
                b_w_C<=1'h1;
                b_data_in_C<=var_C_left;
                b_w_D<=1'h1;
                b_data_in_D<=var_D_left;
					 check<=1'h1;         
            end						
				
///////////////////////////////////////Last byte reduction///////////////////////////////////////////////////////////////

            8'h8f:begin                     /*Reducing Frst Chunk*/
                b_w_C<=1'h0;
                b_w_D<=1'h0;
					 C_byte_Pos<=1;
                if(!word_pos1[2] && check)
                       addr_affected_D_1<=addr_affected_D_1-1'h1;
                if(!word_pos2[2] && check)
                      addr_affected_D_2<=addr_affected_D_2-1'h1;
							 
                b_adbus_C<=C_start_addr;	
                if(check_last_byte[1] ||check_last_byte[0])begin         /////check 64 byte to be reduced
						  
						  //alignment_pos<=check_last_byte;
						  check_last_byte<=check_last_byte-1'h1;
						  Mod<=8'h90;
						  end
				    else 
					     Mod<=8'hab;         //Move to shiftcase                							  
                end               
                
            8'h90:begin
                Mod<=8'h91;        
              if((word_pos1==3'h7)) begin
                     b_adbus_C<= addr_affected_C_1-1'h1;
                     addr_affected_C_1<=addr_affected_C_1-1'h1;
							end
              else begin
                    b_adbus_C<= addr_affected_C_1;
							end
              b_adbus_D<= addr_affected_D_1;
              byte_pos_Reduction<=word_pos1%8; 
                                                          
            end                    
                 
       8'h91:begin        
              Mod<=8'h92;
              b_w_C<=1'h0;
              A_Red_Poly1<=Data_byte_C;
              i<=i+1'h1;                      //variable for reducing last byte to zero that has been reduced              
        end
                                                   
        8'h92:begin
                 Mod<=8'h94;
                 A1<=Data_64_2_Chunk;           
                 B1<=Lut_Out_Shift[271:136];
                 select_line<=3'b111;                                                               
            end
                      
         8'h94:begin
                 Mod<=8'h95;
                 b_w_C<=1'h1;
                 b_data_in_C<=var_C_left;
                 b_w_D<=1'h1;
                 b_data_in_D<=var_D_left;
                                            
         end
   //*Reducing second byte of reduction Polynomial/
        8'h95:begin
            Mod<=8'h96;         
                b_w_C<=1'h0;
                b_w_D<=1'h0; 
                                                
				  if(word_pos2==3'h7) begin
							 b_adbus_C<= addr_affected_C_2-1'h1;
							 addr_affected_C_2<=addr_affected_C_2-1'h1;
								  end
				  else begin
							 b_adbus_C<= addr_affected_C_2;
							 end
				  b_adbus_D<= addr_affected_D_2;
				  byte_pos_Reduction<=word_pos2%8;			  
				  byte_position_reduced<=byte_position_reduced+1'h1;
				  end
                    
         8'h96:begin
              Mod<=8'h97;
              word_pos1<=(var_1+byte_position_reduced)%8;
              word_pos2<=(var_3+byte_position_reduced)%8;
                end
                     
				8'h97:begin
                Mod<=8'h98;                                                             
                A1<=Data_64_2_Chunk;  
                B1<=Lut_Out_Shift[135:0];
                select_line<=3'b111;                              
        end
         
    //*update in memory the modified chunk/                  
				8'h98:begin          
                  Mod<=8'h99;                  
                  b_w_C<=1'h1;
                  b_data_in_C<=var_C_left;
                  b_w_D<=1'h1;
                  b_data_in_D<=var_D_left;                 
            end
          /////Second chunk reduction//////
            8'h99:begin                         /*Reducing Second Chunk*/
                b_w_C<=1'h0;
                b_w_D<=1'h0;
					 b_adbus_C<=C_start_addr;
                 if(check_last_byte[1] ||check_last_byte[0]) begin   //check byte need to be reduced or not
					     C_byte_Pos<=C_byte_Pos+1'h1;
                    Mod<=8'h9a;
                    check_last_byte<=check_last_byte-1'h1;  
                 end
					  else begin
					    Mod<=8'hab;
					  end
            end
            
            8'h9a:begin
                Mod<=8'h9b;                    
                if(word_pos1==3'h7) begin
                        b_adbus_C<= addr_affected_C_1-1'h1;
                        addr_affected_C_1<=addr_affected_C_1-1'h1;
                    end
                else begin
                        b_adbus_C<= addr_affected_C_1;
                end
                b_adbus_D<= addr_affected_D_1;
                byte_pos_Reduction<=word_pos1%8; 
            end
    
            8'h9b:begin
                Mod<=8'h9c;
                b_w_C<=1'h0;        
                A_Red_Poly1<=Data_byte_C; 
                i<=i+1'h1;				 
              end
        
				8'h9c:begin
                  Mod<=8'h9d;
                  A1<=Data_64_2_Chunk;           
                 B1<=Lut_Out_Shift[271:136];
                  select_line<=3'b111;                                                               
            end
                 //*updating Memory Polynomial      
				8'h9d:begin
                  Mod<=8'h9e;
                  b_w_C<=1'h1;
                  b_data_in_C<=var_C_left;
                  b_w_D<=1'h1;
                  b_data_in_D<=var_D_left;                                           
         end
   //*Reducing second byte of reduction Polynomial
        8'h9e:begin
                Mod<=8'h9f;        
                b_w_C<=1'h0;
                b_w_D<=1'h0;                  

                if(word_pos2==3'h7) begin
                 b_adbus_C<= addr_affected_C_2-1'h1;
                 addr_affected_C_2<=addr_affected_C_2-1'h1;
                    end
                else begin
                    b_adbus_C<= addr_affected_C_2;
                    end
                b_adbus_D<= addr_affected_D_2;
                byte_pos_Reduction<=word_pos2%8;
               
                byte_position_reduced<=byte_position_reduced+1'h1;                                    
                end
                    
                    
         8'h9f:begin
              Mod<=8'ha0;
              word_pos1<=(var_1+byte_position_reduced)%8;
              word_pos2<=(var_3+byte_position_reduced)%8;             
          end
                     
				8'ha0:begin
                 Mod<=8'ha1;
               //*XOR OF 128 BIT/                                                                        
                 A1<=Data_64_2_Chunk;  
                 B1<=Lut_Out_Shift[135:0];
                 select_line<=3'b111;                       
        end
         
    //*update in memory the modified chunk/                  
				8'ha1:begin          
                Mod<=8'ha2;
                b_w_C<=1'h1;
                b_data_in_C<=var_C_left;
                b_w_D<=1'h1;
                b_data_in_D<=var_D_left;
            end
                                           
    //////////////third byte reduction///////////////////////////////
         8'ha2:begin                   //Reducing thd Chunk
					b_w_C<=1'h0;
					b_w_D<=1'h0;
					b_adbus_C<=C_start_addr;
					if(check_last_byte[1] ||check_last_byte[0]) begin
					   C_byte_Pos<=C_byte_Pos+1'h1;
						Mod<=8'ha3;
						check_last_byte<=check_last_byte-1'h1;  
						end
					else begin
							Mod<=8'hab;
							end                               
             end
            
             8'ha3:begin
                 Mod<=8'ha4;
                 if(word_pos1==3'h7) begin                                
                        b_adbus_C<= addr_affected_C_1-1'h1;
                        addr_affected_C_1<=addr_affected_C_1-1'h1;
                        end
                 else begin
                         b_adbus_C<= addr_affected_C_1;
                        end
                 b_adbus_D<= addr_affected_D_1;
                 byte_pos_Reduction<=word_pos1%8;
                 end
               
				8'ha4:begin
						Mod<=8'ha5;
						b_w_C<=1'h0;        
						A_Red_Poly1<=Data_byte_C;     //third chunk to be reduced
						i<=i+1'h1;
						//*Accessing respective byte /                                                                                
						end
                    
				8'ha5:begin
                  Mod<=8'ha6;
                  A1<=Data_64_2_Chunk;           
                  B1<=Lut_Out_Shift[271:136];
                  select_line<=3'b111;                                                               
            end
                 //*updating Memory Polynomial      
					8'ha6:begin
                    Mod<=8'ha7;
                    b_w_C<=1'h1;
                    b_data_in_C<=var_C_left;
                    b_w_D<=1'h1;
                    b_data_in_D<=var_D_left;
                                            
         end
   //*Reducing second byte of reduction Polynomial/
				8'ha7:begin
               Mod<=8'ha8;        
               b_w_C<=1'h0;
               b_w_D<=1'h0;                  
            
               if(word_pos2==3'h7) begin
                             b_adbus_C<= addr_affected_C_2-1'h1;
                             addr_affected_C_2<=addr_affected_C_2-1'h1;
                             end
                else begin
                            b_adbus_C<= addr_affected_C_2;
                            end
                b_adbus_D<= addr_affected_D_2;
                byte_pos_Reduction<=word_pos2%8;      
                byte_position_reduced<=byte_position_reduced+1'h1;                                    
                end                    
                    
			8'ha8:begin
				Mod<=8'ha9;
				word_pos1<=(var_1+byte_position_reduced)%8;
				word_pos2<=(var_3+byte_position_reduced)%8;
				end
                     
				8'ha9:begin
                Mod<=8'haa;
                //*XOR OF 128 BIT
                                                                    
                A1<=Data_64_2_Chunk;  
                B1<=Lut_Out_Shift[135:0];
                select_line<=3'b111;                       
			end
    //*update in memory the modified chunk/                  
				8'haa:begin          
                Mod<=8'hab;
              
                b_w_C<=1'h1;
                b_data_in_C<=var_C_left;
                b_w_D<=1'h1;
                b_data_in_D<=var_D_left;
            end
////////////////shift last 64 chunk reduction////////////////
				8'hab:begin
                Mod<=8'hac;
                b_w_C<=1'h0;
                b_w_D<=1'h0;
                b_adbus_C<=C_start_addr;
                C_byte_Pos<=C_byte_Pos+1'h1;		 //access shift chunk of byte			 
                    end
            
             8'hac:begin
                 Mod<=8'had;
                 end
					 
			    8'had:begin                   //shift data that need to be reduced
						Mod<=8'hae;
						select_line<=3'b100;
						A_Mask<=Data_byte_C;
						last_64_chunk<=Data_byte_C;
						last_chunk<=Data_byte_C;               //SToRING LAST CHUNK THAT NEED TO BE REDUCEED
						B_Mask_Pos<=8'h40-(position_shift)%7'h40;
						
					   if(word_pos1==3'h7) begin
									b_adbus_C<= addr_affected_C_1-1'h1;
									addr_affected_C_1<=addr_affected_C_1-1'h1;
									end
					   else begin
									b_adbus_C<= addr_affected_C_1;
									end
					   b_adbus_D<= addr_affected_D_1;
					   byte_pos_Reduction<=word_pos1%8; 
					   end					
    
       8'hae:begin
				Mod<=8'haf;
				b_w_C<=1'h0;
				A_Red_Poly1<=Out_Mask;				 
				A1<=Out_Mask;
				B1<=last_64_chunk;
				select_line<=3'b111;				 
				last_byte<=D_Out1[63:0];                         //last byte that is reduced                                                            
				end		
     
        8'haf:begin
                 Mod<=8'hb1;
					  last_64_chunk<=D_Out1[63:0];
                 A1<=Data_64_2_Chunk;           
                 B1<=Lut_Out_Shift[271:136];
                 select_line<=3'b111;                                                               
                 end
                 //*updating Memory Polynomial/      
         8'hb1:begin
						Mod<=8'hb2;
						b_w_C<=1'h1;
						b_data_in_C<=var_C_left;
						b_w_D<=1'h1;
						b_data_in_D<=var_D_left;
         // byte_position_reduced<=byte_position_reduced+1'h1;                                 
                  end
                               
   //*Reducing second byte of reduction Polynomial/
        8'hb2:begin
               Mod<=8'hb3;        
               b_w_C<=1'h0;
               b_w_D<=1'h0;                  
            
               if(word_pos2==3'h7) begin
                         b_adbus_C<= addr_affected_C_2-1'h1;
                         addr_affected_C_2<=addr_affected_C_2-1'h1;
                         end
                else begin
                        b_adbus_C<= addr_affected_C_2;
                        end
                               
                b_adbus_D<= addr_affected_D_2;                    
                byte_pos_Reduction<=word_pos2%8;
                byte_position_reduced<=byte_position_reduced+1'h1;                                                                     
                end
                    
                    
         8'hb3:begin
              Mod<=8'hb4;                          
        end
                 
        8'hb4:begin
                 Mod<=8'hb6;
                 A1<=Data_64_2_Chunk;           
                 B1<=Lut_Out_Shift[135:0];
                 select_line<=3'b111;                                                               
            end					  
        
    //*update in memory the modified chunk                 
         8'hb6:begin           
                Mod<=8'hb7;                             
                b_w_C<=1'h1;
                b_data_in_C<=var_C_left;
                b_w_D<=1'h1;
                b_data_in_D<=var_D_left;
            end
				
				
		   8'hb7:begin
			     Mod<=8'hb8;
				  b_w_C<=1'h0;
				  b_w_D<=1'h0;

				  b_adbus_C<=C_start_addr;
            end
				
			8'hb8:begin
			    Mod<=8'hb9;
				 
				 end
				 
				 
				 
		    8'hb9:begin
			     Mod<=8'hba;
				  interupt<=1'h1;
				  //cmd_red<=1'h0;
	          b_w_C<=1'h1;
				  if(i==2'h0)
						b_data_in_C<={last_64_chunk,b_data_out_C[191:0]};
				  else if(i==2'h1)
						b_data_in_C<={64'h0,last_64_chunk,b_data_out_C[127:0]};
				  else if(i==2'h2)
						b_data_in_C<={128'h0,last_64_chunk,b_data_out_C[63:0]};
				  else
						b_data_in_C<={192'h0,last_64_chunk};
				  end 
    

         8'hba:begin
			     Mod<=8'hbb;
				  interupt<=1'h0;
				  b_w_C<=1'h0;
			     cmd_red<=1'h0;
			      end


	 
               
   /////////           /////////////////////////////////last byte  dor D port reduction///////////////////////////////////////////////////////////////

          8'hc6:begin
                 b_w_C<=1'h0;
                 b_w_D<=1'h0;
                   D_byte_Pos<=1;                  
                 if(word_pos1[2])
                     addr_affected_C_1<=addr_affected_C_1-1'h1;
                 if(word_pos2[2])
                     addr_affected_C_2<=addr_affected_C_2-1'h1;                         
                  b_adbus_D<=D_start_addr;	
                if(check_last_byte[1]|| check_last_byte[0])begin
						 
						  //alignment_pos<=check_last_byte;
						  check_last_byte<=check_last_byte-1'h1;
						  Mod<=8'hc7;
						  end
				    else 
					     Mod<=8'hf1;         //Move to shiftcase                    
             end  
				 
            8'hc7:begin
					  Mod<=8'hc8; 
					  if((word_pos1==3'h3)) begin
						 b_adbus_D<= addr_affected_D_1-1'h1;
						 addr_affected_D_1<=addr_affected_D_1-1'h1;
						 end
						 else begin
							 b_adbus_D<= addr_affected_D_1;
						 end
					  b_adbus_C<= addr_affected_C_1;
					  byte_pos_Reduction<=word_pos1%8;									
				     end                                 

       8'hc8:begin
              // Data_256<=b_data_out_D;   
              Mod<=8'hc9;
              b_w_D<=1'h0;
              A_Red_Poly1<=Data_byte_D;
				  i<=i+1'h1;
            //*Acessing 64 chunk to be affected/                                                     
              end
                   
                    //*Xor respective byte with Lut/            
        8'hc9:begin
                  Mod<=8'hca;
                  A1<=Data_64_2_Chunk;           
                 B1<=Lut_Out_Shift[271:136];
                  select_line<=3'b111;                                                               
                  end
                 //*updating Memory Polynomial      
         8'hca:begin
                  Mod<=8'hcb;
                  b_w_C<=1'h1;
                  b_data_in_C<=var_C_left;
                  b_w_D<=1'h1;
                  b_data_in_D<=var_D_left;                                           
                 end
   //*Reducing second byte of reduction Polynomial
        8'hcb:begin 
                Mod<=8'hcc;
                b_w_C<=1'h0;
                b_w_D<=1'h0;                  

                if((word_pos2==3'h3)) begin
                    b_adbus_D<= addr_affected_D_2-1'h1;
                    addr_affected_D_2<=addr_affected_D_2-1'h1;
                    end
                else begin
                    b_adbus_D<= addr_affected_D_2;
                    end
                b_adbus_C<= addr_affected_C_2;
                byte_pos_Reduction<=word_pos2%8;
   
                byte_position_reduced<=byte_position_reduced+1'h1;                            
               end
                    
         8'hcc:begin
              Mod<=8'hcd;
              word_pos1<=(var_1+byte_position_reduced)%8;
              word_pos2<=(var_3+byte_position_reduced)%8;
              end
                     
         8'hcd:begin
                Mod<=8'hce;                                                                              
                A1<=Data_64_2_Chunk;  
                B1<=Lut_Out_Shift[135:0];
                select_line<=3'b111;                            
                end
    //*update in memory the modified chunk                  
            8'hce:begin          
                  Mod<=8'hcf;                                    
                  b_w_C<=1'h1;
                  b_data_in_C<=var_C_left;
                  b_w_D<=1'h1;
                  b_data_in_D<=var_D_left;
						D_byte_Pos<=D_byte_Pos+1'h1;    //increase it by 1 when whole 64 byte is reduced                   
                 end
          
         8'hcf:begin
                  b_w_D<=1'h0;
                  b_w_C<=1'h0;
                  b_adbus_D<=D_start_addr;
                 if(check_last_byte[1] ||check_last_byte[0]) begin		     
                    Mod<=8'hd0;
                    check_last_byte<=check_last_byte-1'h1;  
                 end
					  else begin
					    Mod<=8'hf1;
					  end                   
           end
        
         8'hd0:begin
             Mod<=8'hd1;
             if(word_pos1==3'h3) begin
							b_adbus_D<= addr_affected_D_1-1'h1;
							addr_affected_D_1<=addr_affected_D_1-1'h1;
							end
             else begin
							b_adbus_D<= addr_affected_D_1;
							end
             b_adbus_C<= addr_affected_C_1;
             byte_pos_Reduction<=word_pos1%8;  
             end
            
    
       8'hd1:begin
                Mod<=8'hd2;
                b_w_C<=1'h0;                      
                A_Red_Poly1<=Data_byte_D;    
                i<=i+1'h1;					 
                end
            
        
        8'hd2:begin
                 Mod<=8'hd3;
                 A1<=Data_64_2_Chunk;           
                 B1<=Lut_Out_Shift[271:136];
                 select_line<=3'b111;                                                               
                 end
                 //*updating Memory Polynomial/      
         8'hd3:begin
                 Mod<=8'hd4;
                 b_w_C<=1'h1;
                 b_data_in_C<=var_C_left;
                 b_w_D<=1'h1;
                 b_data_in_D<=var_D_left;                                          
                 end
   //*Reducing second byte of reduction Polynomial/
        8'hd4:begin
                Mod<=8'hd5;        
                b_w_C<=1'h0;
                b_w_D<=1'h0;                  

                if(word_pos2==3'h3) begin
                     b_adbus_D<= addr_affected_D_2-1'h1;
                     addr_affected_D_2<=addr_affected_D_2-1'h1;
                     end
                else begin
                    b_adbus_D<= addr_affected_D_2;
                    end
                b_adbus_C<= addr_affected_C_2;
                byte_pos_Reduction<=word_pos2%8;
         
                byte_position_reduced<=byte_position_reduced+1'h1;                                    
                end
                    
                    
         8'hd5:begin
              Mod<=8'hd6;
              word_pos1<=(var_1+byte_position_reduced)%8;
              word_pos2<=(var_3+byte_position_reduced)%8;               
              end
                     
         8'hd6:begin
                 Mod<=8'hd7;
         //*XOR OF 128 BIT/
                A1<=Data_64_2_Chunk;  
                B1<=Lut_Out_Shift[135:0];
                select_line<=3'b111;                       
               end
    //*update in memory the modified chunk/                  
         8'hd7:begin          
                Mod<=8'hd8;             
                b_w_C<=1'h1;
                b_data_in_C<=var_C_left;
                b_w_D<=1'h1;
                b_data_in_D<=var_D_left;
					 D_byte_Pos<=D_byte_Pos+1'h1;
                end
    //*SECOND Byte reduction
         8'hd8:begin                     
					b_w_D<=1'h0;
					b_w_C<=1'h0;
					b_adbus_D<=D_start_addr;
					
					if(check_last_byte[0]) begin					   
						Mod<=8'hd9;
						check_last_byte<=check_last_byte-1'h1;  
						end
					else begin
							Mod<=8'hf1;
							end                       
             end
            
             8'hd9:begin
                Mod<=8'hda;
					 if(word_pos1==3'h3) begin                                
						b_adbus_D<= addr_affected_D_1-1'h1;
						addr_affected_D_1<=addr_affected_D_1-1'h1;
						end
                else begin
						b_adbus_D<= addr_affected_D_1;
					  end
                b_adbus_C<= addr_affected_C_1;
                byte_pos_Reduction<=word_pos1%8; 
                end
              
       8'hda:begin
                Mod<=8'hdb;    
                b_w_D<=1'h0;        
                A_Red_Poly1<=Data_byte_D;     //third chunk to be reduced 
                i<=i+1'h1;					 
                end
                    
        8'hdb:begin
                 Mod<=8'hdc;
                 A1<=Data_64_2_Chunk;           
                 B1<=Lut_Out_Shift[271:136];
                 select_line<=3'b111;                                                               
                 end
                 //*updating Memory Polynomial     
         8'hdc:begin
                 Mod<=8'hdd;
                 b_w_C<=1'h1;
                 b_data_in_C<=var_C_left;
                 b_w_D<=1'h1;
                 b_data_in_D<=var_D_left;                                            
                 end
   //*Reducing second byte of reduction Polynomial
        8'hdd:begin
               Mod<=8'hde;        
               b_w_C<=1'h0;
               b_w_D<=1'h0;                  
            
               if(word_pos2==3'h3) begin
							b_adbus_D<= addr_affected_D_2-1'h1;
							addr_affected_D_2<=addr_affected_D_2-1'h1;
							end
                else begin
                        b_adbus_D<= addr_affected_D_2;
                        end
                b_adbus_C<= addr_affected_C_2;
                byte_pos_Reduction<=word_pos2%8;       
                byte_position_reduced<=byte_position_reduced+1'h1;                                    
                end
                    
                    
         8'hde:begin
              Mod<=8'hdf;
              word_pos1<=(var_1+byte_position_reduced)%8;
              word_pos2<=(var_3+byte_position_reduced)%8;                
              end
                     
         8'hdf:begin
                   Mod<=8'hf0;
                   //*XOR OF 128 BIT                                                           
                A1<=Data_64_2_Chunk;  
                B1<=Lut_Out_Shift[135:0];
                select_line<=3'b111;                       
        end
    //*update in memory the modified chunk*                 
         8'hf0:begin          
				  Mod<=8'hf1; 
				  b_w_C<=1'h1;
				  b_data_in_C<=var_C_left;
				  b_w_D<=1'h1;
				  b_data_in_D<=var_D_left;
				  D_byte_Pos<=D_byte_Pos+1'h1;
              end

         8'hf1:begin
				  Mod<=8'hf2;
				  b_w_D<=1'h0;
				  b_w_C<=1'h0;
				  b_adbus_D<=D_start_addr;             				  
             end
            
         8'hf2:begin
             Mod<=8'hf3;
         end
 		 
			 8'hf3:begin                   //shift data that need to be reduced
				Mod<=8'hf4;
				//select_line<=3'b100;
				A_Mask<=Data_byte_D;
				last_64_chunk<=Data_byte_D;
				last_chunk<=Data_byte_D;               //SToRING LAST CHUNK THAT NEED TO BE REDUCEED
				B_Mask_Pos<=8'h40-(position_shift)%8'h40;
				
			 if(word_pos1==3'h3) begin
							b_adbus_D<= addr_affected_D_1-1'h1;
							addr_affected_D_1<=addr_affected_D_1-1'h1;
							end
			 else begin
							b_adbus_D<= addr_affected_D_1;
							end
			 b_adbus_C<= addr_affected_C_1;
			 byte_pos_Reduction<=word_pos1%8; 
				end						
 
    
       8'hf4:begin
				Mod<=8'hf5;
				b_w_D<=1'h0;        
				A_Red_Poly1<=Out_Mask;    //change
				A1<=Out_Mask;
				B1<=last_64_chunk;
				select_line<=3'b111;

				last_byte<=D_Out1[63:0];                                                                 
				end				  
     
        8'hf5:begin
                 Mod<=8'hf7;
                 A1<=Data_64_2_Chunk;           
                 B1<=Lut_Out_Shift[271:136];
					  last_64_chunk<=D_Out1[63:0];
                 select_line<=3'b111;                                                               
                end      
      
                 //*updating Memory Polynomial      
         8'hf7:begin
                 Mod<=8'hf8;
                 b_w_C<=1'h1;
                 b_data_in_C<=var_C_left;
                 b_w_D<=1'h1;
                 b_data_in_D<=var_D_left;                                            
         end
   //*Reducing second byte of reduction Polynomial
        8'hf8:begin
               Mod<=8'hf9;        
               b_w_C<=1'h0;
               b_w_D<=1'h0;                  
            
               if(word_pos2==3'h3) begin
                            b_adbus_D<= addr_affected_D_2-1'h1;
                            addr_affected_D_2<=addr_affected_D_2-1'h1;
                            end
               else begin
                        b_adbus_D<= addr_affected_D_2;
                        end
                b_adbus_C<= addr_affected_C_2;
                byte_pos_Reduction<=word_pos2%4'h8;          
                byte_position_reduced<=byte_position_reduced+1'h1;                                    
                end
                                        
         8'hf9:begin
				Mod<=8'hfa;
				word_pos1<=(var_1+byte_position_reduced)%4'h8;
				word_pos2<=(var_3+byte_position_reduced)%4'h8;            
				end
                     
         8'hfa:begin
                Mod<=8'hfb;
                //*XOR OF 128 BIT                                                                        
                A1<=Data_64_2_Chunk;  
                B1<=Lut_Out_Shift[135:0];
                select_line<=3'b111;                       
        end
    //*update in memory the modified chunk                
         8'hfb:begin
                Mod<=8'hfc;                          
                b_w_C<=1'h1;
                b_data_in_C<=var_C_left;
                b_w_D<=1'h1;
                b_data_in_D<=var_D_left;
            end  	

          8'hfc:begin
			     Mod<=8'hfd;
				  b_w_C<=1'h0;
				   b_w_D<=1'h0;
				  b_adbus_D<=D_start_addr;
              end
				
			8'hfd:begin
			    Mod<=8'hc0;
				
				 end
		    8'hc0:begin
			     Mod<=8'hc1;
				   interupt<=1'h1;
				   b_w_D<=1'h1;
				  if(i==3'h0)
				  b_data_in_D<={last_64_chunk,b_data_out_D[191:0]};
				  else if(i==2'h1)
				  b_data_in_D<={64'h0,last_64_chunk,b_data_out_D[127:0]};
				  else if(i==2'h2)
				  b_data_in_D<={128'h0,last_64_chunk,b_data_out_D[63:0]};
				  else
				  b_data_in_D<={192'h0,last_64_chunk};
				  end
           8'hc1:begin
			     Mod<=8'hc2;
				  
				  b_w_D<=1'h0;
				  interupt<=1'h0;
			     cmd_red<=1'h0;
			      end
           				  
			endcase
         end    //always block
     endmodule
      
