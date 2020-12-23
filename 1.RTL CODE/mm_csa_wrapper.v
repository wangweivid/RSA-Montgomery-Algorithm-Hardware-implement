`timescale 1ns / 1ps

//===================================================================
// File Name	:  csa_wrapper.v
// Project Name	:  16x16 bit Booth Recoded Multiplier 
// Create Date	:  2020/05/05
// Author		:  wangwei
// Description	:  Implement Partial Product  module
//===================================================================
`include "/nfs54/project/spiderman/wangwei5/workspace/rsa/code_base16_0805/rtl/parameter.v"


module mm_csa_wrapper(
    clk,
    rstn,
    start,
    mode,
    X_j,
    Y_i,
    X_Y,
    M_i,
    S_last,
    C_last,
    M_q,
    s0_last_qm,
    Carry_o,
    Sum_o,
    Co_o,
    So_o,
    s0,
    Y_o,
    M_o
    );
        
    input                           clk;
    input                           rstn;
    input                           start;
    input       [1:0]               mode;
    
    input       [15:0]              X_j;
    input       [31:0]              Y_i;
    input       [15:0]              X_Y;
    input       [31:0]              M_i;
    input       [31:0]              S_last;
    input       [31:0]              C_last;
    
    input       [15:0]              M_q;
    input       [15:0]              s0_last_qm;
    
    output      [31:0]              Carry_o,Sum_o;
    output      [15:0]              s0;
    output      [31:0]              Y_o;
    output      [31:0]              M_o;
    output      [31:0]              Co_o;
    output      [31:0]              So_o;
    
    wire        [31:0]              Sum1,Carry1;
    wire        [31:0]              Sum2,Carry2;
        
    reg                             start_dly;
    wire                            start_edge;
    wire        [15:0]              QM;

    reg         [15:0]              reg_X;
    wire        [31:0]              sum,cout;
    
    reg         [3:0]               cnt_s;
    reg                             start_flag;
    reg                             flag_low;
    
    always @(posedge clk or negedge rstn) begin             //reg_X ctl for cnt_s == 3 
        if(!rstn)
            reg_X <= 0;
        else if  (cnt_s == `NUM_MULTI_QM - 2)
            reg_X <= X_j;
        else
            reg_X <= reg_X;    
    end

    always @(posedge clk or negedge rstn) begin
      if(!rstn)
          start_dly <= 1'b0;
      else 
          start_dly <= start;
    end
   
    assign start_edge = start & (! start_dly);              //start edge detect
   
    always @(posedge clk or negedge rstn) begin             //start flag for cnt_s count
      if(!rstn)
          start_flag <= 1'b0;
      else  if (start_edge == 1'b1)
          start_flag <= 1'b1;
      else
          start_flag <= start_flag;
    end

    always @(posedge clk or negedge rstn) begin             //count for regX
        if(!rstn)
            cnt_s <= 0;
        else if (start_flag == 1'b1 | start == 1'b1) begin
            if (start_edge == 1'b1)
                cnt_s <= 0;
            else  if (cnt_s != `NUM_PIPELINE - 1'b1)
                cnt_s <= cnt_s + 1'b1;
            else 
                cnt_s <= cnt_s;
        end
    end
               
    //QM_module  generate Q' to adjust S £¬avoiding  low S[15:0] value discard
    qm_gen u_qm_gen(
        .clk            (clk        ),
        .rstn           (rstn       ),
        .X_Y            (X_Y        ),              //X[j]
        .S              (s0_last_qm ),              //S[0]
        .M_1            (M_q        ),
        .Q_m            (QM         )
    );
    
   //X[j]*Y  32*16 bits Multiplier
    booth_multi_top  u_booth_multi_top_1(
        .clk             (clk       ),
        .rstn            (rstn      ),
        .multiplier      (reg_X     ),                              //input [15:0]  regX
        .multiplicand    (Y_i       ),                              //input [31:0]  Y_i
        .Sum_result      (Sum1      ),                              //output [31:0] CSA sum1
        .Carry_result    (Carry1    )                               //output [31:0] CSA carry1
    );
    
    
    //Q[j]*M  32*16 bits Multiplie
    booth_multi_top  u_booth_multi_top_2(
        .clk             (clk       ),
        .rstn            (rstn      ),
        .multiplier      (QM        ),                              //input [15:0]  Qm       
        .multiplicand    (M_i       ),                              //input [31:0]  M_i         
        .Sum_result      (Sum2      ),                              //output [31:0] CSA sum2     
        .Carry_result    (Carry2    )                               //output [31:0] CSA carry2   
    );
    
    
    always @(posedge clk or negedge rstn) begin                     //compressor 6:2 start flag 
              if(!rstn) 
                   flag_low          <= 0;
              else if (cnt_s == `NUM_PIPELINE - 4)
                   flag_low          <= 1'b1;
              else 
                   flag_low          <= 0;
    end   
     
    wire       [15:0]      s_add;    
    
    //compressor6_2 -2clk
    compressor6_2_top #(.DATA_WIDTH (32)) u_com6_2_top  ( 
            .clk            (clk    ),
            .rstn           (rstn   ),
            .flag_low       (flag_low),
            .a              (Sum1   ),
            .b              (Carry1 ),
            .c              (Sum2   ),
            .d              (Carry2 ),
            .e              (S_last ),
            .f              (C_last ),
            .sum_result     (sum    ),
            .cout_result    (cout   )
      );
 
       reg        [15:0]      cout_dly;
       reg        [15:0]      sum_dly;
       reg                    data_flag;
       wire       [31:0]      carry_0,sum_0;
       
       reg        [15:0]      reg_s;
       reg        [7:0]       cnt_result; 
       
      always @(posedge clk or negedge rstn) begin                                       //ouput [31:0] pipeline 
          if(!rstn) begin
               sum_dly          <= 0;
               cout_dly         <= 0;
          end
          else begin
               sum_dly          <= sum[31:16];
               cout_dly         <= cout[31:16];
          end        
       end     
        
        
       assign   carry_0  = (data_flag == 1'b1) ? ({cout[15:0],cout_dly})  : 0;          //output [31:0] for Compressor 6:2 
       assign   sum_0    = (data_flag == 1'b1) ? ({sum[15:0],sum_dly})    : 0;          //output [31:0] for Compressor 6:2     
    
       wire  [32:0] test3;
       assign test3 = carry_0 + sum_0; 
       
       always @(posedge clk or negedge rstn) begin                                      //cnt for data flag out 
          if (! rstn) 
             cnt_result <= 0;
          else if (start_edge == 1'b1)
             cnt_result <= 0;
          else if (data_flag == 1'b1) begin
                if  (cnt_result == 8'd128)
                    cnt_result <=  0;
                else
                    cnt_result <=  cnt_result + 1'b1 ;
           end
           else 
                cnt_result <= 0;
       end             
       
       always @(posedge clk or negedge rstn) begin                          //data flag out for Carry and Sum
           if (! rstn) 
              data_flag <= 0;
           else begin
                case (mode )
                2'b00: begin                //4096 bit
                             if (cnt_s == 9 )           // 1 space  129 -128
                                  data_flag <= 1'b0;    //mode = 00 
                             else if (cnt_s == `NUM_PIPELINE - 2'b10 | cnt_result == 8'd127)
                                  data_flag <= ~data_flag;
                       end
                2'b01: begin                //2048 bit   
                            if (cnt_s == 3 )            // 8 space   72 - 64
                                data_flag <= 1'b0;      //mode = 01  
                            else if (cnt_s == `NUM_PIPELINE - 2'b10 | cnt_result == 8'd127)
                                data_flag <= ~data_flag;
                       end
                2'b10: begin                //1024 bit      
                            if (cnt_s == 6 )            //
                                data_flag <= 1'b0;      //mode = 10 
                            else if (cnt_s == `NUM_PIPELINE - 2'b10 | cnt_result == 8'd127)
                                data_flag <= ~data_flag;
                       end       
                2'b11: begin                //512 bit 
                            if (cnt_s == 6 )            //
                                data_flag <= 1'b0;      //mode = 11
                            else if (cnt_s == `NUM_PIPELINE - 2'b10 | cnt_result == 8'd127)
                                data_flag <= ~data_flag;
                       end
                default:   data_flag <= 1'b0;
                       
                endcase
           end                
       end
                     
       always @(posedge clk or negedge rstn) begin                          //output delay  for S to next  M.M cell
              if (! rstn) 
                 reg_s <= 0;
              else if (cnt_s == `NUM_PIPELINE - 2'b10)
                 reg_s <= s_add;
       end  
                 

      assign  s_add = sum[31:16] + cout[31:16];
      assign  s0    = reg_s;  
       
      //***************************************************
      //shift reg 
       //shift for Y/M   
       shift_reg_12    u_shift_reg_12_Y (
            .clk         (clk),   
            .rstn        (rstn), 
            .shift_i     (Y_i),
            .shift_o     (Y_o)
       );
   
       shift_reg_12    u_shift_reg_12_M (
            .clk         (clk),   
            .rstn        (rstn), 
            .shift_i     (M_i),
            .shift_o     (M_o)
       );     
               
       //shift for Y/M            
       shift_reg_9    u_shift_reg_9_sum (
            .clk         (clk),   
            .rstn        (rstn), 
            .shift_i     (sum_0),
            .shift_o     (Sum_o)
       );     
      
      shift_reg_9    u_shift_reg_9_carry (
            .clk         (clk),   
            .rstn        (rstn), 
            .shift_i     (carry_0),
            .shift_o     (Carry_o)
       );     
             
       assign Co_o =  carry_0;              //output [31:0] Carry for Co
       assign So_o =  sum_0;                //output [31:0] Carry for So       
                            
endmodule
