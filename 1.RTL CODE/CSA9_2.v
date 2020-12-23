`timescale 1ns / 1ps

//===================================================================
// File Name	:  CSA9_2.v
// Project Name	:  CSA9_2 
// Create Date	:  2020/05/05
// Author		:  wangwei
// Description	:  CSA9_2 carry save adder compressor 9:2
//===================================================================

module CSA9_2 #( parameter DATA_WIDTH = 16 ) (
    clk,
    rstn,
    data_0,
    data_1,
    data_2,
    data_3,
    data_4,
    data_5,
    data_6,
    data_7,
    data_8,
    flag_zero,
    shift_direct,
    Carry,
    Sum
    );
    
    localparam      NUMBER_REAL_BIT  =  DATA_WIDTH + 2;          //2bits 2'b00
    
    input                                                     clk;  
    input                                                     rstn;
    input                                                     flag_zero;
    input   [(NUMBER_REAL_BIT/2-3):0]                         shift_direct;    
    output  [2*DATA_WIDTH-1:0]                                Carry;
    output  [2*DATA_WIDTH-1:0]                                Sum;

    input   [NUMBER_REAL_BIT-1:0]                             data_0; 
    input   [NUMBER_REAL_BIT-1:0]                             data_1;
    input   [NUMBER_REAL_BIT-1:0]                             data_2;
    input   [NUMBER_REAL_BIT-1:0]                             data_3; 
    input   [NUMBER_REAL_BIT-1:0]                             data_4; 
    input   [NUMBER_REAL_BIT-1:0]                             data_5; 
    input   [NUMBER_REAL_BIT-1:0]                             data_6; 
    input   [NUMBER_REAL_BIT-1:0]                             data_7;
    input   [NUMBER_REAL_BIT-1:0]                             data_8;
    
    wire    [2*DATA_WIDTH-1:0]                                ext_add_0;
    wire    [2*DATA_WIDTH-1:0]                                ext_add_1;
    wire    [2*DATA_WIDTH-1:0]                                ext_add_2;
    wire    [2*DATA_WIDTH-1:0]                                ext_add_3;
    wire    [2*DATA_WIDTH-1:0]                                ext_add_4;
    wire    [2*DATA_WIDTH-1:0]                                ext_add_5;
    wire    [2*DATA_WIDTH-1:0]                                ext_add_6;
    wire    [2*DATA_WIDTH-1:0]                                ext_add_7;
    wire    [2*DATA_WIDTH-1:0]                                ext_add_8;
    
    wire    [NUMBER_REAL_BIT-1:0]                             add_0,  add_1,  add_2,  add_3,  add_4,  add_5,  add_6,  add_7,  add_8;
    
    wire    [31:0]                                            C11,C12,C13;
    wire    [31:0]                                            S11,S12,S13;
    wire    [31:0]                                            S31,S32;
    wire    [31:0]                                            C31,C32;
    wire    [31:0]                                            S21,S22;
    wire    [31:0]                                            C21,C22;

    //MUX for data0~9 when valid
    assign  add_0        =  flag_zero == 1'b1 ? data_0 : 0;    //[17:0];
    assign  add_1        =  flag_zero == 1'b1 ? data_1 : 0;    //[35:18];
    assign  add_2        =  flag_zero == 1'b1 ? data_2 : 0;    //[53:36];
    assign  add_3        =  flag_zero == 1'b1 ? data_3 : 0;    //[71:54];
    assign  add_4        =  flag_zero == 1'b1 ? data_4 : 0;    //[89:72];
    assign  add_5        =  flag_zero == 1'b1 ? data_5 : 0;    //[107:90];
    assign  add_6        =  flag_zero == 1'b1 ? data_6 : 0;    //[125:108];
    assign  add_7        =  flag_zero == 1'b1 ? data_7 : 0;    //[143:126];
    assign  add_8        =  flag_zero == 1'b1 ? data_8 : 0;    //[161:144];
    
    //decoder-booth algorithm  
    assign  ext_add_0    =  (shift_direct[0]) ? { {14{1'b1}},add_0      }:{14'b0,add_0      };           //32bits         
    assign  ext_add_1    =  (shift_direct[1]) ? { {12{1'b1}},add_1,2'b0 }:{12'b0,add_1, 2'b0};    
    assign  ext_add_2    =  (shift_direct[2]) ? { {10{1'b1}},add_2,4'b0 }:{10'b0,add_2, 4'b0};   
    assign  ext_add_3    =  (shift_direct[3]) ? { { 8{1'b1}},add_3,6'b0 }:{ 8'b0,add_3, 6'b0};     
    assign  ext_add_4    =  (shift_direct[4]) ? { {6{1'b1}}, add_4,8'b0 }:{ 6'b0,add_4, 8'b0};     
    assign  ext_add_5    =  (shift_direct[5]) ? { {4{1'b1}}, add_5,10'b0}:{ 4'b0,add_5,10'b0};    
    assign  ext_add_6    =  (shift_direct[6]) ? { {2{1'b1}}, add_6,12'b0}:{ 2'b0,add_6,12'b0};     
    assign  ext_add_7    =                      {      add_7,14'b0};     
    assign  ext_add_8    =                      {add_8[15:0],16'b0};        

    //pipeline stage 1
    CSA3_2 #(.DATA_WIDTH (32)) u_compressor_10 (                //carry save adder compressor 3:2
         .a     (ext_add_0  ),
         .b     (ext_add_1  ),
         .c     (ext_add_2  ),
         .sum   (S11        ),
         .cout  (C11        )
    );    
    
    CSA3_2 #(.DATA_WIDTH (32)) u_compressor_11 (                //carry save adder compressor 3:2
         .a     (ext_add_3  ),
         .b     (ext_add_4  ),
         .c     (ext_add_5  ),
         .sum   (S12        ),
         .cout  (C12        )
    );    
        
     CSA3_2 #(.DATA_WIDTH (32)) u_compressor_12 (               //carry save adder compressor 3:2
         .a     (ext_add_6  ),
         .b     (ext_add_7  ),
         .c     (ext_add_8  ),
         .sum   (S13        ),
         .cout  (C13        )
    );
     
     //pipeline stage 2
     CSA3_2 #(.DATA_WIDTH (32)) u_compressor_21 (                //carry save adder compressor 3:2
         .a     ({C11[30:0],1'b0}  ),
         .b     ({C12[30:0],1'b0}  ),
         .c     ({C13[30:0],1'b0}  ),
         .sum   (S22               ),
         .cout  (C22               )
     );
     
     CSA3_2 #(.DATA_WIDTH (32)) u_compressor_22 (                 //carry save adder compressor 3:2
         .a     (S11                ),
         .b     (S12                ),
         .c     (S13                ),
         .sum   (S21                ),
         .cout  (C21                )
);  
       
     //pipeline stage 3  
     CSA3_2 #(.DATA_WIDTH (32)) u_compressor_31 (                 //carry save adder compressor 3:2
         .a     ( S22               ),
         .b     ({C22[30:0],1'b0}   ),
         .c     ({C21[30:0],1'b0}   ),
         .sum   (S31                ),
         .cout  (C31                )
     );
            
     CSA3_2 #(.DATA_WIDTH (32)) u_compressor_32 (                 //carry save adder compressor 3:2
         .a     (S21                 ),
         .b     (S31                 ),
         .c     ({C31[30:0],1'b0}    ),
         .sum   (S32                 ),
         .cout  (C32                 )
     );       
              
     assign     Carry   = C32[31:0];                            //output [31:0] Carry CAS 9:2
     assign     Sum     = S32[31:0];                            //output [31:0] Sum CAS 9:2
  
endmodule
