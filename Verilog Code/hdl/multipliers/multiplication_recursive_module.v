`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  BARC   
// Engineer:Deepak Kapoor(Modified)
//
// Create Date:    18:41:06 08/25/2014
// Design Name:
// Mulule Name:    Mul_576
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
module multiplication_recursive_module(
     input wire          clk,
     input wire [255:0]  b_data_out_A,
     input wire [255:0]  b_data_out_B,
    
     output reg [127:0]  Mul_A,
     output reg [127:0]  Mul_B,
     input wire [127:0]  Mul_out_lsb,
     input wire [127:0]  Mul_out_msb,
 
     input  wire [3:0]   command,
	  output reg          cmd_mul,    //register  to give command to othr modules
     input  wire [2:0]   start_addr,
    
     output reg [2:0]    select_line,
    
     output reg [2:0]    b_adbus_A,
     output reg [2:0]    b_adbus_B,
     output reg [2:0]    b_adbus_C,                          
     output reg [2:0]    b_adbus_D,                           
     
     output reg [255:0]  b_data_in_C,
     output reg [255:0]  b_data_in_D,
    
     output reg         b_w_C,
     output reg         b_w_D,
	  output reg         interupt,
	  input wire [9:0]   Data_len_Polynomial
 
 );
        reg [2:0] write_addr;
        reg [7:0]Mul;
		  reg [2:0] Poly_len,Poly_chunk;
        reg [255:0] x00,x01,x02,x10,x12,x20,x22,D00,D01,D10,D11,D20,D21,A11,Out0;
        reg [255:0] y00,y02;
        reg [255:0] A00,B00;
        reg [255:0]  A20,B20,A21,B21,O21,O20,O23,O24;
         reg [511:0] Out_1,Out_2,Out_3,Out_4;
        reg [255:0] Xor_A1,Xor_B1,A01,B01,A02,B02,D02,B11,D12;
        wire [255:0] Xor_A,Xor_B,Xor_out;
 
    Xor_256 Xor_256 (
        .A(Xor_A),
        .B(Xor_B),
        .Out(Xor_out)
     );
	  
    assign Xor_A = Xor_A1;
    assign Xor_B = Xor_B1;

    initial begin
		  interupt<=1'h0;
		  cmd_mul<=1'h0;
            end
    
    always @(posedge clk)begin
         	  	  
	    if(command==4'h1)begin
		      Mul<= 8'h1; 
           
			  end
			  
	  case(Mul)
	 	 
        8'h1:begin
              Mul<=8'h2;
				  cmd_mul<=1'h1;
              b_adbus_A<=start_addr-((Data_len_Polynomial/9'h100)+1'h1);          
              b_adbus_B<=start_addr-((Data_len_Polynomial/9'h100)+1'h1);
				  
              Poly_chunk<=Data_len_Polynomial/9'h100;    //for addr allocation
              Poly_len<=Data_len_Polynomial/8'h80;		//var to run no of cases 		  
              end 
			 
        8'h2:begin
					Mul<=8'h3;
					write_addr<=start_addr-Poly_chunk-1'h1;
					  end
					  
        8'h3:begin    //a0b0   96 BIT
					 Mul<=8'h4;
                Mul_A<=b_data_out_A[127:0];
                Mul_B<=b_data_out_B[127:0];              //a0b0
               
                A00<=b_data_out_A;
                B00<=b_data_out_B;
           
                select_line<=3'b001;        //select_line for multiplication
                //(a2+a0)   (b2+b0)=a1,b1
                Xor_A1<={b_data_out_A[127:0],b_data_out_B[127:0]};
                Xor_B1<={b_data_out_A[255:128],b_data_out_B[255:128]};                                    
                end 
			
         8'h4:begin    //a1b1
					
					Mul_A<=Xor_out[127:0];
					Mul_B<=Xor_out[255:128];
					x00<={Mul_out_msb[127:0],Mul_out_lsb};

					b_adbus_A<=start_addr-Poly_chunk;          
					b_adbus_B<=start_addr-Poly_chunk;
					
					  


               if(Poly_len	==3'h0)begin
                 b_adbus_C<=write_addr;
					  interupt<=1'h1;
                 b_w_C <=1'h1;
					  b_data_in_C<={Mul_out_msb[127:0],Mul_out_lsb};
					  Mul<=8'h42;
					  end
					  else begin
					   Mul<=8'h5;
						Poly_chunk<=Poly_chunk-1'h1;
						end
                      end
			 
          8'h5:begin  //A2B2      A1B1+A0B0
					Mul<=8'h6;
					Xor_A1<={Mul_out_msb[127:0],Mul_out_lsb};
					Xor_B1<=x00;
					Mul_A<=A00[255:128];
					Mul_B<=B00[255:128];                      
              end
             
         8'h6:begin        // A1B1+A0B0+A2B2
					Mul<=8'h7;
					Xor_A1<={Mul_out_msb[127:0],Mul_out_lsb};
					Xor_B1<=Xor_out;
					x02<={Mul_out_msb[127:0],Mul_out_lsb};   

					A02<=b_data_out_A;
					B02<=b_data_out_B;

					b_adbus_A<=start_addr-Poly_chunk;          
					b_adbus_B<=start_addr-Poly_chunk;
               end
				 
        8'h7:begin
           Mul<=8'h8;              
            Xor_A1<={   x02[127:0],     Xor_out[127:0]};
            Xor_B1<={Xor_out[255:128], x00[255:128] };   ////Xoring for 192*192 Mul
            Mul_A<=A02[127:0];       //A20*B20
            Mul_B<=B02[127:0];                                                
            end
            //A2B2 Multiplication//
				
        8'h8:begin
				if(Poly_len[2]==0 && Poly_len[1]==0&&Poly_len[0]==1)begin
					  Mul<=8'h42;
                 interupt<=1'h1;					  
					  b_adbus_C<=write_addr;
					  b_w_C<=1;
					  b_adbus_D<=write_addr;
					  b_w_D<=1;
					  b_data_in_C<={x02[255:128],Xor_out[255:128]};              //128 bit data
					  b_data_in_D<={Xor_out[127:0],x00[127:0]};   //256 data
						end
				else
					Mul<=8'h9;           
					//Ans D01,D00  192 Bit//////
					D00<={Xor_out[127:0],x00[127:0]};
					D01<={x02[255:128],Xor_out[255:128]};
					/////////////////////////////////////////////////////////////////////       
					Xor_A1<={A02[127:0],B02[127:0]};
					Xor_B1<={A02[255:128],B02[255:128]};          //xor (a2+a0)   (b2+b0)
					x20<={Mul_out_msb[127:0],Mul_out_lsb};
					Mul_A<=A02[255:128];                          //A2_2*B2_2
					Mul_B<=B02[255:128];   
					/////////////////////////////////////////////////////////////////////
					A20<={128'h0,b_data_out_A[127:0]};
					B20<={128'h0,b_data_out_B[127:0]};
					///A20 B20 192 BIT
					end        
         
		8'h9:begin
				Mul<=8'ha;
				x22<={Mul_out_msb[127:0],Mul_out_lsb};
				Mul_A<=Xor_out[127:0];                         //A2_1*B2_1
				Mul_B<=Xor_out[255:128];       
				Xor_A1<=x20;                                //a0b0+a2b2
				Xor_B1<={Mul_out_msb[127:0],Mul_out_lsb};                     
          end
                   
		 8'ha:begin
				Mul<=8'hb;         
				Xor_A1<={Mul_out_msb[127:0],Mul_out_lsb};
				Xor_B1<=Xor_out;                                  //a0b0+a2b2+a1b1
				end   
    
       8'hb:begin
					Mul<=8'hc;
					Xor_A1<=Xor_out;
					Xor_B1<={x22[127:0],x20[255:128]};                      //xoring for final Ans
					end             
                          
          8'hc:begin///A0+A2
					Mul<=8'hd;
					D20<={Xor_out[127:0],x20[127:0]};
					D21<={x22[255:128],Xor_out[255:128]};

					Xor_A1<=A00[255:0];                  //A1=A0+A2    384
					Xor_B1<=A02[255:0];
					end
             
			8'hd:begin
					Mul<=8'he;
					A01<=Xor_out;
					Xor_A1<=B00[255:0];
					Xor_B1<=B02[255:0];                           //B1=B0+B2
					end       
             
			8'he:begin                            
					Mul<=8'hf;
					B01<=Xor_out;
					Mul_A<=A01[127:0];       //a10*b10      a0b0
					Mul_B<=Xor_out[127:0];         

					Xor_A1<={A01[255:128],Xor_out[255:128]};
					Xor_B1<={A01[127:0],Xor_out[127:0]};                    //a10+a12 b10+b12
					end
       8'hf:begin
					Mul<=8'h10;
					x10<={Mul_out_msb[127:0],Mul_out_lsb};
					Mul_A<=A01[255:128];                          //a12*b12   a2*b2
					Mul_B<=B01[255:128];
					A11<=Xor_out;                  //(a0+a1)    (b0+b1)
					end
         
        8'h10:begin
					Mul<=8'h11;
					x12<={Mul_out_msb[127:0],Mul_out_lsb};               //a2*b2
					Mul_A<=A11[127:0];       //A11*B11
					Mul_B<=A11[255:128];
					Xor_A1<=x10;
					Xor_B1<={Mul_out_msb[127:0],Mul_out_lsb};              //A0B0  +A2B2
					end
             
        8'h11:begin
					Mul<=8'h12;
					Xor_A1<=Xor_out;
					Xor_B1<={Mul_out_msb[127:0],Mul_out_lsb};         //a0b0+a1b1+a2+b2
					end            
     8'h12:begin
				Mul<=8'h13;
				Xor_A1<={x12[127:0],x10[255:128]};
				Xor_B1<=Xor_out;                           //xoring for fINAL aNS
				end
          
        8'h13:begin
				Mul<=8'h14;
				Xor_A1<=D21;
				Xor_B1<=D01;
				D10<={Xor_out[127:0],x10[127:0]};             
				D11<= {x12[255:128],Xor_out[255:128]};
				end
       
        8'h14:begin
				Mul<=8'h15;
				Xor_A1<=Xor_out;
				Xor_B1<=D11;
				end
             
        8'h15:begin
				Mul<=8'h16;
				D11<=Xor_out;
				Xor_A1<=D20;
				Xor_B1<=D00;
				end
       
			8'h16:begin
				Mul<=8'h17;
				Xor_A1<=Xor_out;
				Xor_B1<=D10;
				end           
           
     8'h17:begin
				Mul<=8'h18;
				D10<=Xor_out;
				Xor_A1<=D01;
				Xor_B1<=Xor_out;                 //xoring for 384*384 ans
				end
       
     8'h18:begin
			Mul<=8'h19;
			Out0<=Xor_out;
			Xor_A1<=D20;
			Xor_B1<=D11;
			///////////////////////////////////////////////////////     
			Mul_A<=A20[127:0];                                                    //A20*B20
			Mul_B<=B20[127:0];
			//a0b0             
			end             
             
      
         
         8'h19:begin
			  O20<={Mul_out_msb[127:0],Mul_out_lsb}; 
	
			  if(Poly_len[1])	
					Mul<=8'h41;
					else
					Mul<=8'h1e;
			if(Poly_len[0])begin
					
					b_data_in_C<=Out0;
					b_data_in_D<=D00;
					end
			else begin
					
					b_data_in_C<=D00;
					b_data_in_D<=Out0;
					end
/////////////////////// Storing 384*384 Result////////////////////////////////////////
					Out_1<={Out0,D00};
					Out_2<={D21,Xor_out};           

					b_adbus_C<=write_addr;              //write output result
					b_w_C<=1'h1;
					if(Poly_len[0])
					b_adbus_D<=write_addr;              //write output result
					else
					b_adbus_D<=write_addr+1'h1;
					b_w_D<=1'h1;
					write_addr<=write_addr+1'h1;           //increase by 1
															
					Xor_A1<=A00[255:0];                            //(A0+A2)
					Xor_B1<=A20[255:0];
					end                                                                                        
                     
            8'h1e:begin
						Mul<=8'h1f;
						A21<=Xor_out;
						Xor_A1<=B00[255:0];                            //(B0+B2)
						Xor_B1<=B20[255:0];
						end
						//(A02 A21    * B02 B21)    TO BE MULTIPLIED
             8'h1f:begin
						Mul<=8'h20;
						B21<=Xor_out;
						Mul_A<=A21[127:0];                //a0b0
						Mul_B<=Xor_out[127:0];

						Xor_A1<={A21[127:0],Xor_out[127:0]};                       //(a2+a0)      (b2+b0)                           
						Xor_B1<={A21[255:128],Xor_out[255:128]};
						end
                 
            8'h20:begin
						Mul<=8'h21;
						x00<={Mul_out_msb[127:0],Mul_out_lsb};                         //a0*b0   
						Mul_A<=A21[255:128];                //a2b2
						Mul_B<=B21[255:128];
            end

            8'h21:begin
						Mul<=8'h22;
						x02<={Mul_out_msb[127:0],Mul_out_lsb};                             //a2*b2 res                     
						Mul_A<=Xor_out[127:0];                //a1b1
						Mul_B<=Xor_out[255:128];
						Xor_A1<=x00;                                       //a0b0+a2b2                      
						Xor_B1<={Mul_out_msb[127:0],Mul_out_lsb};
						end
                 
            8'h22:begin
                  Mul<=8'h23;
                  Xor_A1<=Xor_out;                                       //a0b0+a2b2+a1b1                      
                  Xor_B1<={Mul_out_msb[127:0],Mul_out_lsb};
    ////////////////////////////////////////////////////////////////////////////////             
                  //A2*B2
                  Mul_A<=A02[127:0];                //a0b0
                  Mul_B<=B02[127:0];
                  end
                 
            8'h23:begin
					Mul<=8'h24;
					Xor_A1<=Xor_out;                                       //xORING TO GET RESULT                     
					Xor_B1<={x02[127:0],x00[255:128]};

	////////////////////////////////////////////////////
					Mul_A<=A02[255:128];                //a2b2
					Mul_B<=B02[255:128];
					x20<={Mul_out_msb[127:0],Mul_out_lsb};          //a0*b0             
                  end
                 
         8'h24:begin
					Mul<=8'h25;
					D02<={x02[255:128],Xor_out[255:128]};
					D00<={Xor_out[127:0],x00[127:0]};
					x22<={Mul_out_msb[127:0],Mul_out_lsb};          //a2*b2
					Xor_A1<={A02[127:0],B02[127:0]};
					Xor_B1<={A02[255:128],B02[255:128]};              //(a2+a0)   (b0+b2)
                  end
       
            8'h25:begin
					Mul<=8'h26;
					Mul_A<=Xor_out[255:128];                      //a1b1
					Mul_B<=Xor_out[127:0];
					Xor_A1<=x22;
					Xor_B1<=x20;                      //a2b2+a0b0                 
					end
               
            8'h26:begin
					Mul<=8'h27;
					Xor_A1<={Mul_out_msb[127:0],Mul_out_lsb};
					Xor_B1<=Xor_out;                         //a2b2+a1b1+a0b0
					end
                      
              8'h27:begin
						Mul<=8'h28;
						Xor_A1<={x22[127:0],x20[255:128]};
						Xor_B1<=Xor_out;
						end
                                     
              8'h28:begin
						Mul<=8'h29;
						D21<={x22[255:128],Xor_out[255:128]};
						D20<={Xor_out[127:0],x20[127:0]};

						Xor_A1<=A02;
						Xor_B1<=A21;
						end
                   
              8'h29:begin
                   Mul<=8'h2a;
                   A11<=Xor_out;
                   Xor_A1<=B02;
                   Xor_B1<=B21;
                end
  
           8'h2a:begin
						Mul<=8'h2b;
						B11<=Xor_out;
						Mul_A<=Xor_out[127:0];             
						Mul_B<=A11[127:0];                   //a0b0         
						end           
           
            8'h2b:begin
                Mul<=8'h2c;
                x10<={Mul_out_msb[127:0],Mul_out_lsb};                      //a0*b0
                Mul_A<=B11[255:128];             
                Mul_B<=A11[255:128];                            //a2b2
                Xor_A1<={B11[127:0],A11[127:0]};
                Xor_B1<={B11[255:128],A11[255:128]};                 //(a0+a2)  (b0+b2)
						end
                                         
            8'h2c:begin
                Mul<=8'h2d;
                x12<={Mul_out_msb[127:0],Mul_out_lsb};                 //a2*b2
                Mul_A<=Xor_out[127:0];                        //a1b1    
                Mul_B<=Xor_out[255:128];                           
                     
                Xor_A1<={Mul_out_msb[127:0],Mul_out_lsb};
                Xor_B1<=x10;                           //a0b0+a2b2
						end                     
                     
            8'h2d:begin
                Mul<=8'h2f;
                Xor_A1<={Mul_out_msb[127:0],Mul_out_lsb};
                Xor_B1<=Xor_out;                                  //a0b0+a1b1+a2b2
						end
                     
            8'h2f:begin
                Mul<=8'h30;
                Xor_A1<={x12[127:0],x10[255:128]};
                Xor_B1<=Xor_out;                                  //Xor of final result
						end

        8'h30:begin
            Mul<=8'h31;
            Xor_A1<={Xor_out[127:0],x10[127:0]};;
            Xor_B1<=D20;
            D12<={x12[255:128],Xor_out[255:128]};
            D10<={Xor_out[127:0],x10[127:0]};
             end
       
        8'h31:begin
            Mul<=8'h32;
            Xor_A1<=Xor_out;
            Xor_B1<=D00;
             end
             
        8'h32:begin
				Mul<=8'h33;
				D10<=Xor_out;
				Xor_A1<=D21;
				Xor_B1<=D02;
				end
       
			8'h33:begin
					Mul<=8'h34;
					Xor_A1<=Xor_out;              //384 Xor A0B0+A1B1+A2B2
					Xor_B1<=D12;
					end   

            8'h34:begin
                 Mul<=8'h35;
                 D12<=Xor_out;           
                 Xor_A1<=D20;
                 Xor_B1<=Xor_out;
						end                            
           
            8'h35:begin
                Mul<=8'h36;
                 Out_4<={D21,Xor_out};
                 Xor_A1<=D02;
                 Xor_B1<=D10;
                 end
                 ////Out_3 Out_4 output for A1B1 384
        8'h36:begin
           Mul<=8'h37;
           Out_3<={Xor_out,D00};
           Xor_A1<=Out_1[255:0];
           Xor_B1<=O20;
          end
    
    
             
      8'h37:begin
			Mul<=8'h39;
			O23<=Xor_out;
			Xor_A1<=Out_3[255:0];
			Xor_B1<=Xor_out;
			end

         
        8'h39:begin
          Mul<=8'h3b;
			 Out_3[255:0]<=Xor_out;
          Xor_A1<=Out_4[255:0];
          Xor_B1<=Out_2[255:0];
         end
    
     8'h3b:begin
				Mul<=8'h3c;
				Out_4[255:0]<=Xor_out;
				Xor_A1<=Out_4[511:256];
				Xor_B1<=Out_2[511:256];
				end
                                          
          8'h3c:begin
					Mul<=8'h3d;
					Out_4[511:256]<=Xor_out;
					Xor_A1<=Out_4[255:0];
					Xor_B1<=O20;
					end
                                                       
               
          8'h3d:begin
					Mul<=8'h3f;
					O20<=Xor_out;
					O21<=Out_4[511:256];
					Xor_A1<=Out_2[255:0];
					Xor_B1<=Out_3[255:0];
					end
         
          8'h3f:begin
				Mul<=8'h40;
				Out_4[255:0]<=Xor_out;
				Xor_A1<=Out_2[511:256];
				Xor_B1<=Out_3[511:256];
				end
               
          8'h40: begin
					Out_4[511:256]<=Xor_out;             	
					Mul<=8'h41;				  
					b_adbus_C<=write_addr;
					b_w_C<=1;
					b_data_in_C<=Out_4[255:0];
					b_adbus_D<=write_addr;
					b_w_D<=1;
					b_data_in_D<={Out_4[511:256]};				 
					end
					  
					  8'h41: begin
								 Mul<=8'h42;
								 interupt<=1'h1;
								
							if(Poly_len[2])begin
					          b_adbus_C<=write_addr+1'h1;
						       b_w_C<=1;
						       b_data_in_C<=O20;
								  b_adbus_D<=write_addr;
								 end
						
								 if(Poly_len[0])begin
								  b_adbus_C<=write_addr;
								  b_w_C<=1;
								  b_data_in_C<=Out_2[511:256];
                           b_adbus_D<=write_addr;
								  b_w_D<=1;
								  b_data_in_D<=Out_2[255:0];
                          end
                      else	 begin
                          b_adbus_C<=write_addr;
								  b_w_C<=1;
								  b_w_D<=0;
								  b_data_in_C<=Out_2[255:0];						 
									end											 
								 end
										
					8'h42:begin
					      Mul<=8'h43; 
					      interupt<=1'h0;
							b_w_C<=1'h0;
							b_w_D<=1'h0;
							end
              8'h43:begin
                   cmd_mul<=1'h0;
               end						 
						              
            endcase
            end
				endmodule
            