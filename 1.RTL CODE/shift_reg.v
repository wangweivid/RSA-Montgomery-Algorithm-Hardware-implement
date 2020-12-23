`timescale 1ns / 1ps

//===================================================================
// File Name	:  CSA9_2.v
// Project Name	:  CSA9_2 
// Create Date	:  2020/05/05
// Author		:  wangwei
// Description	:  CSA9_2 carry save adder compressor 9:2
//===================================================================


module shift_reg_9(
    input               clk,
    input               rstn,
    input   [31:0]      shift_i,
    output  [31:0]      shift_o
    );
    
    reg     [31:0]     S1,S2,S3,S4,S5,S6,S7,S8,S9;
    
    always @(posedge clk or  negedge rstn) begin
        if ( ! rstn) begin
            S1  <= 0;
            S2  <= 0;
            S3  <= 0;
            S4  <= 0;
            S5  <= 0;
            S6  <= 0;
            S7  <= 0;
            S8  <= 0;
            S9  <= 0;
        end
        else begin
            S1  <= shift_i;
            S2  <= S1 ;
            S3  <= S2 ;
            S4  <= S3 ;
            S5  <= S4 ;
            S6  <= S5 ;
            S7  <= S6 ;
            S8  <= S7 ;
            S9  <= S8 ;
        end        
    end
    
    assign shift_o = S9;
 
endmodule

module shift_reg_12(
    input               clk,
    input               rstn,
    input   [31:0]      shift_i,
    output  [31:0]      shift_o
    );
    
    reg     [31:0]     S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12;
    
    always @(posedge clk or  negedge rstn) begin
        if ( ! rstn) begin
            S1  <= 0;
            S2  <= 0;
            S3  <= 0;
            S4  <= 0;
            S5  <= 0;
            S6  <= 0;
            S7  <= 0;
            S8  <= 0;
            S9  <= 0;
            S10 <= 0;
            S11 <= 0;
            S12 <= 0;
        end
        else begin
            S1  <= shift_i;
            S2  <= S1 ;
            S3  <= S2 ;
            S4  <= S3 ;
            S5  <= S4 ;
            S6  <= S5 ;
            S7  <= S6 ;
            S8  <= S7 ;
            S9  <= S8 ;
            S10 <= S9 ;
            S11 <= S10;
            S12 <= S11;
        end          
    end
    
    assign shift_o = S12;
endmodule

//module shift_reg_8_32bit(
//    input               clk,
//    input               rstn,
//    input   [31:0]      shift_i,
//    output  [31:0]      shift_o
//    );
    
//    reg     [31:0]     S1,S2,S3,S4,S5,S6,S7,S8;
    
//    always @(posedge clk or  negedge rstn) begin
//        if ( ! rstn) begin
//            S1  <= 0;
//            S2  <= 0;
//            S3  <= 0;
//            S4  <= 0;
//            S5  <= 0;
//            S6  <= 0;
//            S7  <= 0;
//            S8  <= 0;
//        end
//        else begin
//            S1  <= shift_i;
//            S2  <= S1 ;
//            S3  <= S2 ;
//            S4  <= S3 ;
//            S5  <= S4 ;
//            S6  <= S5 ;
//            S7  <= S6 ;
//            S8  <= S7 ;
//        end        
//    end
    
//    assign shift_o = S8;
 
//endmodule

module shift_reg_9_16bit(
    input               clk,
    input               rstn,
    input   [15:0]      shift_i,
    output  [15:0]      shift_o
    );
    
    reg     [15:0]     S1,S2,S3,S4,S5,S6,S7,S8,S9;
    
    always @(posedge clk or  negedge rstn) begin
        if ( ! rstn) begin
            S1  <= 0;
            S2  <= 0;
            S3  <= 0;
            S4  <= 0;
            S5  <= 0;
            S6  <= 0;
            S7  <= 0;
            S8  <= 0;
            S9  <= 0;
        end
        else begin
            S1  <= shift_i;
            S2  <= S1 ;
            S3  <= S2 ;
            S4  <= S3 ;
            S5  <= S4 ;
            S6  <= S5 ;
            S7  <= S6 ;
            S8  <= S7 ;
            S9  <= S8;
        end        
    end
    
    assign shift_o = S9;
 
endmodule
