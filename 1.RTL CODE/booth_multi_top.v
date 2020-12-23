`timescale 1ns / 1ps

//===================================================================
// File Name	:  booth_multi_top.v
// Project Name	:  16x16 bit Booth Recoded Multiplier 
// Create Date	:  2020/05/05
// Author		:  wangwei
// Description	:  Implement Partial Product  module
//===================================================================


module booth_multi_top (
    clk,
    rstn,
    multiplier,               //16bits                                               
    multiplicand,             //32bits                          
    Sum_result,               //output [31:0] low  [15:0] * [15:0] bits 
    Carry_result              //output [31:0] high [15:0] * [31:16] bits 
    );

    input                           clk;
    input                           rstn;
    input           [15:0]          multiplier;
    input           [31:0]          multiplicand;

    output          [31:0]          Sum_result, Carry_result;

     //cnt_booth_multi delay
    wire            [31:0]          Sum1,Sum2;
    reg             [31:0]          sum1_delay,sum2_delay;   
    reg             [15:0]          sum2_delay2;                
     
    //instance   
    booth_32_16_wrapper #(.WIDTH (32) ) u_booth_32_16_wrapper (
      .clk                    (clk          ),
      .rstn                   (rstn         ),
      .multiplier             (multiplier   ),         //16bits
      .multiplicand           (multiplicand ),         //32bits
      .Sum_1                  (Sum1         ),         //output [31:0] low  16 * 16 bits
      .Sum_2                  (Sum2         )          //output [31:0] high 16 * 16 bits
    );
  
    //CSA_result      
   always  @(posedge clk or negedge rstn) begin
       if(!rstn)begin
            sum1_delay        <= 0;
            sum2_delay        <= 0;
            sum2_delay2       <= 0;
       end
       else  begin
            sum1_delay        <= Sum1;
            sum2_delay        <= Sum2; 
            sum2_delay2       <= sum2_delay[31:16];   
       end
   end
   
   //data aligment                                       
   assign Sum_result          = sum1_delay;       
   assign Carry_result        = {sum2_delay[15:0],sum2_delay2};      
                  
endmodule
