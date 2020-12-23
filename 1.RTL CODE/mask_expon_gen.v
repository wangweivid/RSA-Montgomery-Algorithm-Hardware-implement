`timescale 1ns / 1ps

//===================================================================
// File Name	:  mask_expon_gen.v
// Project Name	:  mask_expon_gen
// Create Date	:  2020/05/05
// Author		:  wangwei
// Description	:  mask_expon_gen   E' = E + random * Euler
// 
//===================================================================


module mask_expon_gen(
        Clk,
        Rstn,
        Enable,
        Phi_N,
        Ei,                 //
        Random_A,           //radndom  A
        E_o,                //generate Exponent output [31:0]
        Rd_en_phi,
        Rd_en_Ei,
        Wr_en_data,
        Phi_empty,
        Ei_empty,
        full_expo     
    );
        
        input                   Clk;
        input                   Rstn;
        input                   Enable;
        
        input    [31:0]         Phi_N;
        input    [31:0]         Ei;
        input    [15:0]         Random_A;
        
        output   [31:0]         E_o;
        output                  Rd_en_phi;
        output                  Rd_en_Ei;
        output                  Wr_en_data;
        
        input                   Phi_empty;
        input                   Ei_empty;
        input                   full_expo;
         
        wire    [31:0]          Sum1,Sum2;
        
        reg     [31:0]          Sum1_dly;
        reg     [31:0]          Sum2_dly;  
        reg     [15:0]          sum2_next;
        
        reg     [15:0]          sum2_delay2; 
        reg                     carry_high;    
        wire    [31:0]          sum_2,carry_2;   
               
        //instance   32*16 bits multiplier 
        booth_32_16_wrapper #(.WIDTH (32) ) u_booth_32_16_wrapper (
            .clk                    (Clk          ),
            .rstn                   (Rstn         ),
            .multiplier             (Random_A     ),           //16bits
            .multiplicand           (Phi_N        ),           //32bits
            .Sum_1                  (Sum1         ),
            .Sum_2                  (Sum2         )
        );
              
        always  @(posedge Clk or negedge Rstn) begin          //pipeline
            if(!Rstn)begin
                 Sum1_dly        <= 0;
                 Sum2_dly        <= 0;
                 sum2_delay2     <= 0;
            end
            else  begin
                 Sum1_dly        <= Sum1;    
                 Sum2_dly        <= Sum2; 
                 sum2_delay2     <= Sum2_dly[31:16];                  
            end
        end
         
        //carry save adder 3:2
        CSA3_2 #(.DATA_WIDTH (32)) u_CSA3_2 (
          .a     (Ei                        ),
          .b     (Sum1_dly                  ),
          .c     ({Sum2_dly[15:0],sum2_delay2}  ),
          .sum   (sum_2                     ),
          .cout  (carry_2                   )
         ); 
 
        reg     [31:0]          sum_2_dly,carry_2_dly;
        reg                     carry_2_high;
                 
        wire    [32:0]          S_result;
        reg     [31:0]          S_result_dly;       
        reg                     carry_3_high;
        
        always  @(posedge Clk or negedge Rstn) begin        //pipeline
            if (!Rstn) begin
                 sum_2_dly          <= 0;
                 carry_2_dly        <= 0;
                 carry_2_high       <= 0;
            end
            else  begin
                 sum_2_dly          <= sum_2;    
                 carry_2_dly        <= carry_2[31:0]; 
                 carry_2_high       <= carry_2_dly[31] ;            
            end
        end  

        
        assign  S_result  = sum_2_dly + {carry_2_dly[30:0],carry_2_high} + carry_3_high;

        always  @(posedge Clk or negedge Rstn) begin        //pipeline
            if (!Rstn) begin
                carry_3_high <= 0;
                S_result_dly <= 0;
            end
            else begin
                carry_3_high <= S_result[32];
                S_result_dly <= S_result[31:0];           
            end
        end
          
        ////////////////////////////////////////////////
        //read data from FIFO
        reg         rd_en_phi,rd_en_ei;      
        wire        RD_PHI_EN,RD_EI_EN;
        
        //read enable for Ei 
        always  @(posedge Clk or negedge Rstn) begin
            if (!Rstn) begin
               rd_en_phi  <= 0;
            end
            else if (Enable == 1'b1) begin
               rd_en_phi  <= 1'b1;
            end     
        end
    
        //cnt for pipeline
        reg     [3:0]       cnt_Ei_reg;
        wire    [3:0]       cnt_Ei;
        reg                 full_expo_pull_up;
        wire                wr_data_en;
        //wire                WR_Eo;
        
        always  @(posedge Clk or negedge Rstn) begin        //expo full flag
            if (!Rstn) 
                full_expo_pull_up <= 0;
            else if (full_expo == 1'b1)
                full_expo_pull_up <= 1'b1;
        end
        
        always  @(posedge Clk or negedge Rstn) begin        //cnt_reg for Ei
            if (!Rstn) 
               cnt_Ei_reg    <= 0;
            else if (Enable == 1'b1  ) begin
               if (cnt_Ei_reg != 4'd8) 
                    cnt_Ei_reg   <= cnt_Ei_reg + 1'b1;
               else 
                    cnt_Ei_reg   <= cnt_Ei_reg;
            end
            else  
                cnt_Ei_reg   <= 0;   
        end
        
        assign cnt_Ei = (Enable == 1'b1 & ~full_expo_pull_up) ? cnt_Ei_reg : 0;
     
        always  @(posedge Clk or negedge Rstn) begin                    //read enable ctl for Ei
             if (!Rstn) 
                rd_en_ei <= 0;
             else if (cnt_Ei == 4'd4)
                rd_en_ei <= 1'b1;
             else 
                rd_en_ei <= rd_en_ei;
        end
               
        assign     RD_EI_EN   = ~Ei_empty & rd_en_ei;                   //output for rd_phi
        assign     wr_data_en =  (cnt_Ei == 4'd8) ? 1'b1 : 1'b0;           //write data enable signal
      
        //assign     WR_Eo      = ~full_expo_pull_up &  wr_data_en;       //output for wr_Eo
        
        assign     RD_PHI_EN  = ~Phi_empty & rd_en_phi;                 //output for rd_phi           
        assign     Rd_en_phi  = RD_PHI_EN;                              //output fifo phi read en
        assign     Rd_en_Ei   = RD_EI_EN;                               //output fifo ei  read en
        assign     Wr_en_data = wr_data_en;                             //output fifo write data en
        assign     E_o        = S_result_dly;                           //output  Eo
        
    endmodule
