`timescale 1ns / 1ps

//===================================================================
// File Name	:  lsfr_random_gen.v
// Project Name	:  lsfr_random_gen
// Create Date	:  2020/05/05
// Author		:  wangwei
// Description	:  lsfr_random_gen_16      lsfr_random_gen_11
// A LFSR or Linear Feedback Shift Register is a quick and easy way to generate
// pseudo-random data inside of an FPGA.  The LFSR can be used for things like
// counters, test patterns, scrambling of data, and others.  This module
// creates an LFSR whose width gets set by a parameter.  The o_LFSR_Done will
// pulse once all combinations of the LFSR are complete.  The number of clock
// cycles that it takes o_LFSR_Done to pulse is equal to 2^g_Num_Bits-1.  For
// example setting g_Num_Bits to 5 means that o_LFSR_Done will pulse every
// 2^5-1 = 31 clock cycles.  o_LFSR_Data will change on each clock cycle that
// the module is enabled, which can be used if desired.
//===================================================================

module lsfr_random_gen_16 (
        input           Clk,
        input           Reset,
        input           Start,    
        input           Enable,
        input  [15:0]   Seed,
        
        output [15:0]   LFSR_o
 ); 
    
        reg    [15:0]   LFSR;
        wire            Feedback;
        
        assign Feedback = LFSR[0] ^ (~(| LFSR[15:1]));
        
        //TAPs = 16'b10000000_00010110;
        always@(posedge Clk) begin
            if( ! Reset) 
                LFSR <= Seed;
            else if (Start == 1'b1)
                LFSR <= {Feedback,LFSR[15:5],LFSR[4]^Feedback, LFSR[3],LFSR[2]^Feedback,LFSR[1]^Feedback};
        end
         
        reg     [15:0]          Random_A_reg;
        
        wire                     enable_edge;
        reg                      enable_dly;
        
        
        always  @(posedge Clk or negedge Reset) begin  //edge  
           if(! Reset)
                enable_dly <= 0;
           else
                enable_dly <= Enable;
        end
        
        assign  enable_edge = ~enable_dly & Enable;
        
        always  @(posedge Clk or negedge Reset) begin
           if(! Reset)
                Random_A_reg <= 0;
           else if ( enable_edge == 1'b1)
                Random_A_reg <= LFSR;  
        end 
        
        assign  LFSR_o = Random_A_reg;
        
endmodule
    
 
///////////////////////////////////////////////////// 
//random 0-2047
module lsfr_random_gen_11(
        input           Clk,
        input           Reset,
        input           Start,    
        input           Enable,
        input  [10:0]   Seed,
        
        output [10:0]   LFSR_o
    
 ); 
    
        reg    [10:0]   LFSR;
        wire            Feedback;
        
        assign Feedback = LFSR[0] ^ (~(| LFSR[10:1]));

        //TAPs = 11'b10000000_010;
        always@(posedge Clk) begin
            if(! Reset) 
                LFSR <= Seed;
            else if (Start == 1'b1)
                LFSR <= {Feedback,LFSR[10:2],LFSR[1]^Feedback};
        end
         
        reg     [10:0]           Random_A_reg;        
        wire                     enable_edge;
        reg                      enable_dly;
        
        
        always  @(posedge Clk or negedge Reset) begin  //edge  
           if(! Reset)
                enable_dly <= 0;
           else
                enable_dly <= Enable;
        end
        
        assign  enable_edge = ~enable_dly & Enable;
        
        always  @(posedge Clk or negedge Reset) begin
           if(! Reset)
                Random_A_reg <= 0;
           else if ( enable_edge == 1'b1)
                Random_A_reg <= LFSR;  
        end 
        
        assign  LFSR_o = (Random_A_reg < 5'b11111) ? (Random_A_reg + 5'b11111) : (Random_A_reg); 
          
    endmodule
 
////            TapsArray [2]   =  2'b11;
////            TapsArray [3]   =  3'b101;
////            TapsArray [4]   =  4'b1001;
////            TapsArray [5]   =  5'b10010;
////            TapsArray [6]   =  6'b100001;
////            TapsArray [7]   =  7'b1000001;
////            TapsArray [8]   =  8'b10001110;
////            TapsArray [9]   =  9'b10000100_0;
////            TapsArray[10]   = 10'b10000001_00;
////            TapsArray[11]   = 11'b10000000_010;
////            TapsArray[12]   = 12'b10000010_1001;
////            TapsArray[13]   = 13'b10000000_01101;
////            TapsArray[14]   = 14'b10000000_010101;
////            TapsArray[15]   = 15'b10000000_0000001;
////            TapsArray[16]   = 16'b10000000_00010110;
////            TapsArray[17]   = 17'b10000000_00000010_0;
////            TapsArray[18]   = 18'b10000000_00010000_00;
////            TapsArray[19]   = 19'b10000000_00000010_011;
////            TapsArray[20]   = 20'b10000000_00000000_0100;
////            TapsArray[21]   = 21'b10000000_00000000_00010;
////            TapsArray[22]   = 22'b10000000_00000000_000001;
////            TapsArray[23]   = 23'b10000000_00000000_0010000;
////            TapsArray[24]   = 24'b10000000_00000000_00001101;
////            TapsArray[25]   = 25'b10000000_00000000_00000010_0;
////            TapsArray[26]   = 26'b10000000_00000000_00001000_11;
////            TapsArray[27]   = 27'b10000000_00000000_00000010_011;
////            TapsArray[28]   = 28'b10000000_00000000_00000000_0100;
////            TapsArray[29]   = 29'b10000000_00000000_00000000_00010;
////            TapsArray[30]   = 30'b10000000_00000000_00000000_101001;
////            TapsArray[31]   = 31'b10000000_00000000_00000000_0000100;
////            TapsArray[32]   = 32'b10000000_00000000_00000000_01100010;
