`timescale 1ns / 1ps

//===================================================================
// File Name	:  qm_gen.v
// Project Name	:  16x16 bit Booth Recoded Multiplier 
// Create Date	:  2020/05/05
// Author		:  wangwei
// Description	:  QM_module  generate Q' to adjust S £¬avoiding  low S[15:0] value discard
// Formular     :  QM = (S_last + Xi *Y ) *M'
//===================================================================


module qm_gen(
    clk,
    rstn,
    X_Y,      //X[j]
    S,        //input [15:0] S0
    M_1,      //input [15:0] M' from AXI
    Q_m       //output [15:0] adjustment factor Qm
);
    
    input                            clk;
    input                            rstn;
    input       [15:0]               X_Y;
    input       [15:0]               S;  
    input       [15:0]               M_1;
    
    output      [15:0]               Q_m;
 
    wire        [15:0]              X_Y;
    wire        [15:0]              result;

    wire        [15:0]              S2; 
    reg         [15:0]              reg_S2; 
    reg         [15:0]              reg_result;  
    
     assign S2 = S + X_Y;

     //module 16 * 16 bits multiplier 
      multi16_16  u_multi16_16(
        .clk            (clk    ),
        .rstn           (rstn   ),
        .multiplier     (reg_S2 ),                      //input [15:0]  reg_S2
        .multiplicand   (M_1    ),                      //input [15:0]  M'
        .S              (result )                       //output [15:0] S
      );
    
     //pipeline
     always@(posedge clk or negedge rstn) begin         
          if (!rstn) begin   
             reg_S2     <= 0;                          
             reg_result <= 0;                          
          end
          else  begin  
             reg_S2 <= S2;                              //pipeline0
             reg_result <= result;                      //pipiline1
          end    
     end
     
    assign  Q_m = reg_result;                           //output [15:0] Qm for Qm * Mi input
                   
endmodule
