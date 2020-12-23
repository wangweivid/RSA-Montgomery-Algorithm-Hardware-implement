`timescale 1ns / 1ps

//===================================================================
// File Name	:  compressor6_2_top.v
// Project Name	:  16x16 bit Booth Recoded Multiplier 
// Create Date	:  2020/05/05
// Author		:  wangwei
// Description	:  Implement Partial Product  module
//===================================================================


module compressor6_2_top #(parameter DATA_WIDTH = 32)(
    clk,
    rstn,
    flag_low,
    a,
    b,
    c,
    d,
    e,
    f,
    sum_result,
    cout_result
);
    
    input                               clk,rstn;
    input       [DATA_WIDTH-1:0]        a, b, c, d, e, f;
    input                               flag_low;
    
    output      [DATA_WIDTH-1:0]        sum_result;
    output      [DATA_WIDTH-1:0]        cout_result;
    
    wire                                C1,C2,C3; 
    
    wire       [DATA_WIDTH-1:0]         sum;
    wire       [DATA_WIDTH-1:0]         cout;
    
    reg                                 reg_C1 = 0;
    reg                                 reg_C2 = 0;
    reg                                 reg_C3 = 0; 
    
    reg        [DATA_WIDTH-1:0]         reg_sum;
    reg        [DATA_WIDTH-1:0]         reg_cout;
    
   compressor6_2_wrapper #(.DATA_WIDTH (32)) u_compressor6_2_wrapper // 
    (
        .a      (a      ),
        .b      (b      ),
        .c      (c      ),
        .d      (d      ),
        .e      (e      ),
        .f      (f      ),
        .cin1   (reg_C1 ),
        .cin2   (reg_C2 ),
        .cin3   (reg_C3 ),
        .sum    (sum    ),
        .cout   (cout   ),
        .C1     (C1     ),
        .C2     (C2     ),
        .C3     (C3     )
    );
    
    //wire        [31:0]       sum_wire;
    wire                     flag_one;
    reg                      cout_high;
    
    reg    [31:0]  cout_r1;
    reg    [31:0]  sum_r1;
    
    always @(posedge clk or negedge rstn) begin
          if(! rstn)begin
                   reg_C1   <= 0 ;
                   reg_C2   <= 0 ;
                   reg_C3   <= 0 ;
                   reg_sum  <= 0 ; 
                   sum_r1   <= 0;
                   reg_cout <= 0 ;
                   cout_high<= 0 ;  
          end
          else begin
                   reg_C1   <= C1 ;
                   reg_C2   <= C2 ;
                   reg_C3   <= C3 ;
                   reg_sum  <= sum; 
                   sum_r1   <= reg_sum;
                   reg_cout <= cout ;
                   cout_high<= cout_r1[DATA_WIDTH-1];
          end
    end
   
     assign   flag_one = (flag_low == 1'b1) ? (reg_cout[14:0] != 0 | reg_sum[15:0] != 0) : 0 ;

     //cout + 1'b1
     always @(posedge clk or negedge rstn) begin
          if(!rstn) 
                   cout_r1       <= 0;  
          else if (flag_one == 1'b1)
                   cout_r1       <= {{reg_cout[31:15] + 1'b1},reg_cout[14:0]};
          else
                   cout_r1       <= reg_cout[DATA_WIDTH-1:0]; 
     end
    
     
     //Data alignment         
     assign    sum_result  = sum_r1;
     assign    cout_result = {cout_r1[DATA_WIDTH-2:0],cout_high};  
     

             
endmodule
