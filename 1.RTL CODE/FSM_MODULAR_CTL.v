`timescale 1ns / 1ps

//===================================================================
// File Name	:  FSM_modular_ctl.v
// Project Name	:  FSM_modular_ctl 
// Create Date	:  2020/05/05
// Author		:  wangwei
// Description	:  Implement Partial Product  module
//===================================================================
`include "/nfs54/project/spiderman/wangwei5/workspace/rsa/code_base16_0805/rtl/parameter.v"


//FSM for write and read data flow
module FSM_MODULAR_CTL(
    clk,
    rstn,
   
    Seed,
    mode,
    
    R2_full,            //FIFO full signal
    N_full,
    M_full,
    MM_SS0_full,
    MM_SS1_full,
    MM_SS2_full,
    MM_CS_full,
    MM_N_full,
    CS_PR_full,
    
    expo_ei,            //expon Ei
    state,
    next_state,
    RD_Xi_EN_o,
    RD_Yi_Mi_EN_o,
    
    one_reg_o,
    cnt_data_Xi_o,
    cnt_data_Y_M_o,
    
    multi_Xi_Y0_encode_o,
    cnt_X_pull_up_o,
    Y_M_2_start_o,
    flag_to_mm_o,
    mm_M_wr_en_o,  
    mm_out_wr_en_o,
    X_pull_up_o , 
    Y_M_pull_up_o,
    Y_M_valid_o,
    pre_ctl_o,
    pre_carry_sum_ctl_o,
    mm_clear_o,
    rd_expon_en_o,
    done_o
);
    
    input                   clk;
    input                   rstn;
    input      [10:0]       Seed;
    input      [1:0]        mode;
    
    // FIFO full SIGNAL
    input                   R2_full;
    input                   N_full;
    input                   M_full;   
    input                   MM_SS0_full;
    input                   MM_SS1_full;
    input                   MM_SS2_full;
    
    input                   MM_CS_full;
    input                   MM_N_full;
    input                   CS_PR_full;

    input      [31:0]       expo_ei;
    
    output     [2:0]        state;
    output     [2:0]        next_state; 
    output                  RD_Xi_EN_o;
    output                  RD_Yi_Mi_EN_o;
    
    output     [15:0]       one_reg_o;
    output     [4:0]        cnt_data_Xi_o;
    output     [3:0]        cnt_data_Y_M_o;
    
    output     [3:0]        multi_Xi_Y0_encode_o;
    output                  cnt_X_pull_up_o;
    output                  Y_M_2_start_o;
    output                  flag_to_mm_o;
    
    output                  mm_M_wr_en_o ; 
    output                  mm_out_wr_en_o;
    
    output                  X_pull_up_o;  
    output                  Y_M_pull_up_o;
    output                  Y_M_valid_o;
    output                  pre_ctl_o;
    output                  pre_carry_sum_ctl_o;

    output                  mm_clear_o;
    output                  rd_expon_en_o;
    output                  done_o;
    
    parameter     NUM_PIPELINE       =      12;       //total Y0-->S,C

    
    wire                    multi_start_flag;
    
    reg                     full_enter0_dly,full_enter1_dly, full_enter2_dly, full_CS_dly, full_SS_dly,full_CS_PR_dly;
    wire                    full_enter0, full_enter1, full_enter2, full_CS, full_CS_PR, full_SS;
    wire                    full_enter0_edge, full_enter1_edge, full_enter2_edge, full_CS_edge, full_CS_PR_edge, full_SS_edge;
    
    reg                     edge_cnt,edge_cnt_dly;  
    wire                    edge_pos;
    
    assign   full_enter0    = R2_full     &  N_full;                  
    assign   full_enter1    = MM_CS_full  &  MM_N_full & M_full;      //enter1 done full
    assign   full_enter2    = MM_SS0_full &  MM_SS1_full & MM_SS2_full & MM_N_full; //enter2 done full 
    assign   full_CS        = MM_CS_full  &  MM_N_full; 
    assign   full_CS_PR     = CS_PR_full  &  MM_N_full; 
    assign   full_SS        = MM_SS0_full &  MM_SS1_full & MM_SS2_full & MM_N_full; 
    
    always @(posedge clk or negedge rstn) begin
           if (! rstn)  begin
                full_enter0_dly     <= 0;
                full_enter1_dly     <= 0;
                full_enter2_dly     <= 0;
                full_CS_dly         <= 0;
                full_CS_PR_dly      <= 0;
                full_SS_dly         <= 0;
           end
           else begin
                full_enter0_dly     <= full_enter0 ;           // R2 , N
                full_enter1_dly     <= full_enter1 ;           // R2, M, N
                full_enter2_dly     <= full_enter2;           // SS0,SS1,SS2,N
                full_CS_dly         <= full_CS     ;           // CS, SS1, N
                full_CS_PR_dly      <= full_CS_PR;
                full_SS_dly         <= full_SS     ;           // SS0, SS0, N
           end        
    end
    
    //full edge 
    assign  full_enter0_edge  =  full_enter0  & ~full_enter0_dly;
    assign  full_enter1_edge  =  full_enter1  & ~full_enter1_dly;
    assign  full_enter2_edge  =  full_enter2  & ~full_enter2_dly;
    assign  full_CS_edge      =  full_CS      & ~full_CS_dly;
    assign  full_CS_PR_edge   =  full_CS_PR   & ~full_CS_PR_dly;
    assign  full_SS_edge      =  full_SS      & ~full_SS_dly;
    
    assign  multi_start_flag  =  (full_enter0_edge | full_enter1_edge | full_enter2_edge | full_CS_edge | full_CS_PR_edge | full_SS_edge);  
    assign  mm_clear_o        = multi_start_flag;  //ouput clear 
    
    //cnt 
    reg         [7:0]       cnt_multi;      
    reg                     rd_stop; 
    reg         [4:0]       cnt_data_Xi;
    reg         [3:0]       cnt_data_Y_M;
    wire                    fall_edge;
    reg                     Y_M_pull_up, X_pull_up;
    
    reg         [7:0]       cnt_Y_M_pull_up;
    reg         [8:0]       cnt_rd_X;
         
    wire                    RD_Xi_EN;
    wire                    RD_Yi_Mi_EN;
    reg                     Y_M_valid;
    reg                     datapath_X_ctl;    
    reg                     pre_ctl,pre_carry_sum_ctl;    
    reg         [3:0]       cnt_fall;
 
    reg                     Y_M_2_start;
    reg                     Y_M_2_flag;
    
    reg         [3:0]       cnt_X_pipieline_1;
    
    reg         [3:0]       cnt_X_pipieline_dly;
    reg                     cnt_X_pull_up;
    
    reg                     mm_out_en;
    wire                    mm_M_wr_en;
    reg         [3:0]       cnt_out;
    
    always @(posedge clk or negedge rstn) begin
        if ( ! rstn ) begin
            cnt_multi           <=  0;
            rd_stop             <= 1'b0;
            cnt_Y_M_pull_up     <= 0;
            Y_M_pull_up         <= 1'b0;
            Y_M_valid           <= 1'b0; 
            cnt_rd_X            <= 0; 
            X_pull_up           <= 0;
            datapath_X_ctl      <= 0;
            pre_ctl             <= 1'b0;
            pre_carry_sum_ctl   <= 1'b0;
            Y_M_2_start         <= 1'b0;
            cnt_X_pipieline_1   <= 0;
            mm_out_en           <= 0; 
        end
        else if (multi_start_flag == 1'b1)begin
            cnt_multi           <=  0;
            cnt_Y_M_pull_up     <= 0;
            Y_M_pull_up         <= 1'b1;
            cnt_rd_X            <= 0;
            X_pull_up           <= 1'b1;
            datapath_X_ctl      <= 1'b1; 
            pre_ctl             <= 1'b0;
            pre_carry_sum_ctl   <= 1'b0;
            Y_M_2_start         <= 1'b0;
            cnt_X_pipieline_1   <= 0;
            mm_out_en           <= 0; 
        end
        else begin
            case (mode)
                2'b00:   begin         //4096 BIT 
                            //cnt for each multiply Cycle 128 ---4096 bit 
                            if ( full_enter0  & ~multi_start_flag) begin         
                               if (multi_start_flag == 1'b1 | cnt_multi  == `MODE_4096 - 1'b1 )            // 129 - 1'b1
                                    cnt_multi  <=  0;
                               else 
                                    cnt_multi  <= cnt_multi + 1'b1;
                            end
                            else
                                cnt_multi  <=  0; 
                
                            //ensure rd_stop cover cnt_data_Xi = 20-31, must modify     
                            if (X_pull_up == 1'b1) begin        
                                if (cnt_multi == 0 | cnt_multi == `BYTE_4096 - 1'b1)
                                    rd_stop <= 1'b0;
                                else if (cnt_multi == (`BYTE_4096 - `NUM_PIPELINE - 3) )              
                                    rd_stop <= 1'b1;
                            end
                            else begin 
                                rd_stop     <= 0;
                            end
                            
                            // cnt for Y/M data pull up full_enter1_dly     
                            if (full_enter0_dly == 1'b1) begin
                                 if (cnt_Y_M_pull_up != `BYTE_4096 + `NUM_PIPELINE + 9)             //depth 128
                                       cnt_Y_M_pull_up  <= cnt_Y_M_pull_up + 1'b1; 
                                 
                                 if (cnt_Y_M_pull_up == 9)                                          // cnt for Y/M data pull up  0--64+11-2 pull up
                                       Y_M_valid   <= 1'b1;
                                 else if (cnt_Y_M_pull_up == `BYTE_4096 + 10) begin
                                       Y_M_pull_up <= 1'b0; 
                                       Y_M_valid   <= 1'b0; 
                                 end 
                                 
                                 if (cnt_Y_M_pull_up == `BYTE_4096 + 6)                             //S_last [15:0] Ctl for 2nd cycle
                                      pre_ctl  <= 1'b1;
                                      
                                 if (cnt_Y_M_pull_up == `BYTE_4096 + `NUM_PIPELINE + 3)             //Carry,Sum [31:0] Ctl for 2nd cycle
                                      pre_carry_sum_ctl <= 1'b1;              
                            end   
                            else
                                 cnt_Y_M_pull_up  <=  0;
                                     
                            // cnt for X read number
                            if (cnt_rd_X == `LEN_4096  + 2) begin                                   //256+2
                                 cnt_rd_X   <= 0; 
                                 X_pull_up  <= 0;                                                   // cnt for X data pull up
                            end
                            else if (RD_Xi_EN == 1'b1 | cnt_data_Xi == `NUM_PIPELINE )
                                 cnt_rd_X  <= cnt_rd_X + 1'b1;     
                                 
                            if (cnt_rd_X == `LEN_4096  + 1)
                                 datapath_X_ctl <= 0;
                            
                            //output Y_M_2_start_1
                            if (cnt_fall == (`NUM_PIPELINE - 2))
                                 Y_M_2_start  <= 1'b1;  
                                 
                            if(edge_pos == 1'b1 & cnt_X_pipieline_1 == `NUM_STAGE_4096 - 1'b1) 
                                 cnt_X_pipieline_1  <= 0;
                            else if ( cnt_X_pipieline_1 == `NUM_STAGE_4096 - 1'b1 ) 
                                 cnt_X_pipieline_1  <= cnt_X_pipieline_1;         
                            else if (edge_pos == 1'b1)
                                 cnt_X_pipieline_1  <= cnt_X_pipieline_1 + 1'b1; 
                                 
                            if (cnt_out == 3)
                                 mm_out_en <= 1'b1;     
                                                 
                         end
                         
                2'b01:    begin         //2048 BIT
                            if (X_pull_up == 1'b1) begin                                                                                                                                
                                //cnt for each multiply Cycle 64 ---2048 bit                                                                                                           
                                if ( cnt_multi  == `MODE_2048 - 1'b1 )                      // 12 * 6                                                                                                          
                                    cnt_multi  <=  0;                                                                                                                                   
                                else                                                                                                                                                    
                                    cnt_multi  <= cnt_multi + 1'b1;                                                                                                                     
                                //ensure rd_stop cover cnt_data_Xi = 20-31, must modify                                                                                                 
                                if (cnt_multi == 0 | cnt_multi == `MODE_2048 - 2'b10)       //12 * 6                                                                                                     
                                    rd_stop <= 1'b0;                                                                                                                                    
                                else if (cnt_multi == (`MODE_2048 - 6) )                                                                                                       
                                    rd_stop <= 1'b1;                                                                                                                                    
                            end                                                                                                                                                                                                                                                                                                                                                 
                            else if (mm_out_en == 1'b1)begin
                                rd_stop     <= 0;
                                if (cnt_multi != `BYTE_2048)                                                                                                                                                  
                                    cnt_multi   <=  cnt_multi + 1'b1;                                                                                                                                                                   
                            end 
                            else  begin                                                                                                                                                        
                                rd_stop     <=  0;    
                                cnt_multi   <=  0; 
                            end   
                                                                                                                                                                                       
                            // cnt for Y/M data pull up full_enter1_dly                                                                                                                 
                            if (full_enter0_dly == 1'b1) begin                                                                                                                          
                                 if (cnt_Y_M_pull_up != `BYTE_2048 + `NUM_PIPELINE + 9)             //depth 128                                                                             
                                       cnt_Y_M_pull_up  <= cnt_Y_M_pull_up + 1'b1;                                                                                                      
                                                                                                                                                                                        
                                 if (cnt_Y_M_pull_up == 9)                                          // cnt for Y/M data pull up  0--64+11-2 pull up                                     
                                       Y_M_valid   <= 1'b1;                                                                                                                             
                                 else if (cnt_Y_M_pull_up == `BYTE_2048 + 10) begin                                                                                                     
                                       Y_M_pull_up <= 1'b0;                                                                                                                             
                                       Y_M_valid   <= 1'b0;                                                                                                                             
                                 end                                                                                                                                                    
                                                                                                                                                                                        
                                 if (cnt_Y_M_pull_up == `BYTE_2048 + 6)                             //S_last [15:0] Ctl for 2nd cycle                                                                    
                                      pre_ctl  <= 1'b1;                                                                                                                                 
                                                                                                                                                                                        
                                 if (cnt_Y_M_pull_up == `BYTE_2048 + `NUM_PIPELINE + 3)             //Carry,Sum [31:0] Ctl for 2nd cycle                                                    
                                      pre_carry_sum_ctl <= 1'b1;                                                                                                                        
                            end                                                                                                                                                         
                            else                                                                                                                                                        
                                 cnt_Y_M_pull_up  <=  0;                                                                                                                                
                                                                                                                                                                                        
                            // cnt for X read number                                                                                                                                    
                            if (cnt_rd_X == `LEN_2048  + 2) begin                                   //256+2                                                                                                             
                                 cnt_rd_X   <= 0;                                                                                                                                       
                                 X_pull_up  <= 0;                                                   // cnt for X data pull up                                                                                                   
                            end                                                                                                                                                         
                            else if (RD_Xi_EN == 1'b1 | cnt_data_Xi == `NUM_PIPELINE )                                                                                                  
                                 cnt_rd_X  <= cnt_rd_X + 1'b1;                                                                                                                          
                                                                                                                                                                                        
                            if (cnt_rd_X == `LEN_2048  + 1)                                                                                                                             
                                 datapath_X_ctl <= 0;                                                                                                                                   
                                                                                                                                                                                        
                            //output Y_M_2_start_1                                                                                                                                      
                            if (cnt_fall == (`NUM_PIPELINE - 2))                                                                                                                        
                                 Y_M_2_start  <= 1'b1;   
                                 
                            if(edge_pos == 1'b1 & cnt_X_pipieline_1 == `NUM_STAGE_2048 - 1'b1) 
                                 cnt_X_pipieline_1  <= 0;
                            else if ( cnt_X_pipieline_1 == `NUM_STAGE_2048 - 1'b1 ) 
                                 cnt_X_pipieline_1  <= cnt_X_pipieline_1;         
                            else if (edge_pos == 1'b1)
                                 cnt_X_pipieline_1  <= cnt_X_pipieline_1 + 1'b1;          
                                 
                            if (cnt_out == 3)
                                 mm_out_en <= 1'b1;     
                             else if (cnt_multi == `BYTE_2048 - 1'b1)    
                                 mm_out_en <= 1'b0;                                                                                                                                      
                          end  
                          
                2'b10:    begin             //1024 bit
                             if (X_pull_up == 1'b1) begin                                                                                                                                
                                  //cnt for each multiply Cycle 64 ---2048 bit                                                                                                           
                                  if ( cnt_multi  == `MODE_1024 - 1'b1 )                      // 12 * 6                                                                                                          
                                      cnt_multi  <=  0;                                                                                                                                   
                                  else                                                                                                                                                    
                                      cnt_multi  <= cnt_multi + 1'b1;                                                                                                                     
                                  //ensure rd_stop cover cnt_data_Xi = 20-31, must modify                                                                                                 
                                  if (cnt_multi == 0 | cnt_multi == `MODE_1024 - 2'b10)       //12 * 6                                                                                                     
                                      rd_stop <= 1'b0;                                                                                                                                    
                                  else if (cnt_multi == (`MODE_1024 - 6) )                                                                                                       
                                      rd_stop <= 1'b1;                                                                                                                                    
                              end                                                                                                                                                         
                              else if (mm_out_en == 1'b1)begin
                                  rd_stop     <= 0;
                                  if (cnt_multi != `BYTE_1024)                                                                                                                                                  
                                      cnt_multi   <=  cnt_multi + 1'b1;                                                                                                                                                                   
                              end 
                              else  begin                                                                                                                                                        
                                  rd_stop     <=  0;    
                                  cnt_multi   <=  0; 
                              end                                                                                                                                                     
                              // cnt for Y/M data pull up full_enter1_dly                                                                                                                 
                              if (full_enter0_dly == 1'b1) begin                                                                                                                          
                                   if (cnt_Y_M_pull_up != `BYTE_1024 + `NUM_PIPELINE + 9)             //depth 128                                                                             
                                         cnt_Y_M_pull_up  <= cnt_Y_M_pull_up + 1'b1;                                                                                                      
                                                                                                                                                                                          
                                   if (cnt_Y_M_pull_up == 9)                                          // cnt for Y/M data pull up  0--64+11-2 pull up                                     
                                         Y_M_valid   <= 1'b1;                                                                                                                             
                                   else if (cnt_Y_M_pull_up == `BYTE_1024 + 10) begin                                                                                                     
                                         Y_M_pull_up <= 1'b0;                                                                                                                             
                                         Y_M_valid   <= 1'b0;                                                                                                                             
                                   end                                                                                                                                                    
                                                                                                                                                                                          
                                   if (cnt_Y_M_pull_up == `BYTE_1024 + 9)                             //S_last [15:0] Ctl for 2nd cycle                                                                    
                                        pre_ctl  <= 1'b1;                                                                                                                                 
                                                                                                                                                                                          
                                   if (cnt_Y_M_pull_up == `BYTE_1024 + `NUM_PIPELINE + 3)             //Carry,Sum [31:0] Ctl for 2nd cycle                                                    
                                        pre_carry_sum_ctl <= 1'b1;                                                                                                                        
                              end                                                                                                                                                         
                              else                                                                                                                                                        
                                   cnt_Y_M_pull_up  <=  0;                                                                                                                                
                                                                                                                                                                                          
                              // cnt for X read number                                                                                                                                    
                              if (cnt_rd_X == `LEN_1024  + 2) begin                                   //256+2                                                                                                             
                                   cnt_rd_X   <= 0;                                                                                                                                       
                                   X_pull_up  <= 0;                                                   // cnt for X data pull up                                                                                                   
                              end                                                                                                                                                         
                              else if (RD_Xi_EN == 1'b1 | cnt_data_Xi == `NUM_PIPELINE )                                                                                                  
                                   cnt_rd_X  <= cnt_rd_X + 1'b1;                                                                                                                          
                                                                                                                                                                                          
                              if (cnt_rd_X == `LEN_1024  + 1)                                                                                                                             
                                   datapath_X_ctl <= 0;                                                                                                                                   
                                                                                                                                                                                          
                              //output Y_M_2_start_1                                                                                                                                      
                              if (cnt_fall == (`NUM_PIPELINE - 2))                                                                                                                        
                                   Y_M_2_start  <= 1'b1;   
                                   
                              if(edge_pos == 1'b1 & cnt_X_pipieline_1 == `NUM_STAGE_1024 - 1'b1) 
                                   cnt_X_pipieline_1  <= 0;
                              else if ( cnt_X_pipieline_1 == `NUM_STAGE_1024 - 1'b1 ) 
                                   cnt_X_pipieline_1  <= cnt_X_pipieline_1;         
                              else if (edge_pos == 1'b1)
                                   cnt_X_pipieline_1  <= cnt_X_pipieline_1 + 1'b1;          
                              
                              if (cnt_out == 3)
                                   mm_out_en <= 1'b1;     
                              else if (cnt_multi == `BYTE_1024 - 1'b1)    
                                   mm_out_en <= 1'b0;                                         
                          end
                2'b11:    begin
                             if (X_pull_up == 1'b1) begin                                                                                                                                
                                 //cnt for each multiply Cycle 64 ---2048 bit                                                                                                           
                                 if ( cnt_multi  == `MODE_512 - 1'b1 )                      // 12 * 6                                                                                                          
                                     cnt_multi  <=  0;                                                                                                                                   
                                 else                                                                                                                                                    
                                     cnt_multi  <= cnt_multi + 1'b1;                                                                                                                     
                                 //ensure rd_stop cover cnt_data_Xi = 20-31, must modify                                                                                                 
                                 if (cnt_multi == 0 | cnt_multi == `MODE_512 - 2'b10)       //12 * 6                                                                                                     
                                     rd_stop <= 1'b0;                                                                                                                                    
                                 else if (cnt_multi == (`MODE_512 - 6) )                                                                                                       
                                     rd_stop <= 1'b1;                                                                                                                                    
                             end                                                                                                                                                         
                             else if (mm_out_en == 1'b1)begin
                                 rd_stop     <= 0;
                                 if (cnt_multi != `BYTE_512)                                                                                                                                                  
                                     cnt_multi   <=  cnt_multi + 1'b1;                                                                                                                                                                   
                             end 
                             else  begin                                                                                                                                                        
                                 rd_stop     <=  0;    
                                 cnt_multi   <=  0; 
                             end                                                                                                                                                     
                             // cnt for Y/M data pull up full_enter1_dly                                                                                                                 
                             if (full_enter0_dly == 1'b1) begin                                                                                                                          
                                  if (cnt_Y_M_pull_up != `BYTE_512 + `NUM_PIPELINE + 9)             //depth 128                                                                             
                                        cnt_Y_M_pull_up  <= cnt_Y_M_pull_up + 1'b1;                                                                                                      
                                                                                                                                                                                         
                                  if (cnt_Y_M_pull_up == 9)                                          // cnt for Y/M data pull up  0--64+11-2 pull up                                     
                                        Y_M_valid   <= 1'b1;                                                                                                                             
                                  else if (cnt_Y_M_pull_up == `BYTE_512 + 10) begin                                                                                                     
                                        Y_M_pull_up <= 1'b0;                                                                                                                             
                                        Y_M_valid   <= 1'b0;                                                                                                                             
                                  end                                                                                                                                                    
                                                                                                                                                                                         
                                  if (cnt_Y_M_pull_up == `BYTE_512 + 9)                             //S_last [15:0] Ctl for 2nd cycle                                                                    
                                       pre_ctl  <= 1'b1;                                                                                                                                 
                                                                                                                                                                                         
                                  if (cnt_Y_M_pull_up == `BYTE_512 + `NUM_PIPELINE + 3)             //Carry,Sum [31:0] Ctl for 2nd cycle                                                    
                                       pre_carry_sum_ctl <= 1'b1;                                                                                                                        
                             end                                                                                                                                                         
                             else                                                                                                                                                        
                                  cnt_Y_M_pull_up  <=  0;                                                                                                                                
                                                                                                                                                                                         
                             // cnt for X read number                                                                                                                                    
                             if (cnt_rd_X == `LEN_512  + 2) begin                                   //256+2                                                                                                             
                                  cnt_rd_X   <= 0;                                                                                                                                       
                                  X_pull_up  <= 0;                                                   // cnt for X data pull up                                                                                                   
                             end                                                                                                                                                         
                             else if (RD_Xi_EN == 1'b1 | cnt_data_Xi == `NUM_PIPELINE )                                                                                                  
                                  cnt_rd_X  <= cnt_rd_X + 1'b1;                                                                                                                          
                                                                                                                                                                                         
                             if (cnt_rd_X == `LEN_512  + 1)                                                                                                                             
                                  datapath_X_ctl <= 0;                                                                                                                                   
                                                                                                                                                                                         
                             //output Y_M_2_start_1                                                                                                                                      
                             if (cnt_fall == (`NUM_PIPELINE - 2))                                                                                                                        
                                  Y_M_2_start  <= 1'b1;   
                                  
                             if(edge_pos == 1'b1 & cnt_X_pipieline_1 == `NUM_STAGE_512 - 1'b1) 
                                  cnt_X_pipieline_1  <= 0;
                             else if ( cnt_X_pipieline_1 == `NUM_STAGE_512 - 1'b1 ) 
                                  cnt_X_pipieline_1  <= cnt_X_pipieline_1;         
                             else if (edge_pos == 1'b1)
                                  cnt_X_pipieline_1  <= cnt_X_pipieline_1 + 1'b1;          
                             
                             if (cnt_out == 3)
                                  mm_out_en <= 1'b1;     
                             else if (cnt_multi == `BYTE_512 - 1'b1)    
                                  mm_out_en <= 1'b0;                 
                
                          end          
                                    
                default:  ;
                       
            endcase
        end
    
    end
     
    assign fall_edge = ~rd_stop & (cnt_data_Xi == 5'b11111);
     
     //cnt   for X data stream      2 * 16 clks 
     always @(posedge clk or negedge rstn) begin
        if (! rstn)  
             cnt_data_Xi        <= 0; 
        else if (X_pull_up == 1'b1) begin
             if( multi_start_flag == 1'b1 | cnt_data_Xi == 2*`NUM_PIPELINE - 1'b1 )       //11
                   cnt_data_Xi        <= 0; 
             else if (rd_stop == 1'b1)
                   cnt_data_Xi        <= 5'b11111;
             else
                   cnt_data_Xi        <= cnt_data_Xi + 1'b1;                    
        end
        else 
             cnt_data_Xi          <= 0;   
     end
     
     
     always @(posedge clk or negedge rstn) begin        // cnt for Y/M data flow ctl
            if (! rstn)  
                 cnt_data_Y_M  <=  0;
            else if (full_enter0_dly == 1'b1) begin
                 if (multi_start_flag == 1'b1)
                     cnt_data_Y_M  <=  0;
                 else if (cnt_data_Y_M != `NUM_Y )
                     cnt_data_Y_M  <=  cnt_data_Y_M + 1'b1;
                 else 
                     cnt_data_Y_M  <= cnt_data_Y_M;
            end
            else
                 cnt_data_Y_M  <=  0;
     end
     
     ///////////////////////////////////////////////////////////////////////

     //output for Xi Yi_Mi enable ctl
     assign       RD_Xi_EN       =  (full_enter0_dly == 1'b1 & (X_pull_up & cnt_data_Xi == 0));
     assign       RD_Yi_Mi_EN    =  (cnt_data_Y_M == 0 & full_enter0_dly == 1'b1) | cnt_data_Y_M ==  `NUM_Y ;
     
     //output for read ctl signal
     assign       RD_Xi_EN_o     =  RD_Xi_EN;   //?
     assign       RD_Yi_Mi_EN_o  =  Y_M_pull_up & RD_Yi_Mi_EN;
     assign       X_pull_up_o    =  datapath_X_ctl;
     assign       Y_M_pull_up_o  =  Y_M_pull_up;
     assign       Y_M_valid_o    =  Y_M_valid;
     
     //output for cnt Y/M 
     assign       cnt_data_Y_M_o =  cnt_data_Y_M;
     assign       cnt_data_Xi_o  =  cnt_data_Xi;
     
     //////////////////ENTER1 for X = 1
     reg            one_pull_up;
      
     always @(*) begin       
         if (! rstn)  
            one_pull_up = 0;
         else if (cnt_data_Y_M != 4'd10 & cnt_data_Y_M != 0)
            one_pull_up = 1'b1;
         else 
            one_pull_up = 0;
     end
     
     assign  one_reg_o         =  {15'b0, one_pull_up};
    
    /////////////////////////
    //cnt for pipeline stages

    always @(posedge clk or negedge rstn) begin
       if (! rstn) 
            edge_cnt  <= 0;
       else if (full_enter0_dly == 1'b1) begin
            //if (cnt_data_Xi == 3 | cnt_data_Xi == 9 | cnt_data_Xi == 15 | cnt_data_Xi == 20 | fall_edge)
            if( (cnt_data_Xi ==  `NUM_MULTI_X_Y) |   (cnt_data_Xi ==  `NUM_MULTI_X_Y + `MID_VALUE) | (cnt_data_Xi == `NUM_MULTI_X_Y +  `NUM_PIPELINE) | (cnt_data_Xi ==  `NUM_MULTI_X_Y  + `MID_VALUE +  `NUM_PIPELINE) | fall_edge)                   
                  edge_cnt  <= ~edge_cnt;
            else                 
                  edge_cnt  <= edge_cnt;
       end
       else           
            edge_cnt  <= 0;
    end 
      
    always @(posedge clk or negedge rstn) begin
           if (! rstn) 
                edge_cnt_dly  <= 0;
           else
                edge_cnt_dly  <= edge_cnt;
    end
    
    assign  edge_pos = edge_cnt & ~edge_cnt_dly;
    
    always @(posedge clk or negedge rstn) begin
           if (! rstn) 
                cnt_X_pull_up  <= 0;
           else if (multi_start_flag == 1'b1)
                cnt_X_pull_up  <= 0;
           else if (cnt_data_Xi == `NUM_MULTI_X_Y  + 1'b1)
                cnt_X_pull_up  <= 1'b1;
           else
                cnt_X_pull_up  <= cnt_X_pull_up;
    end
    
    always @(*) begin
        case(mode)
            2'b00:   cnt_X_pipieline_dly = (cnt_X_pull_up == 1'b1 ) ? ((cnt_X_pipieline_1 != 0) ? (cnt_X_pipieline_1 - 1'b1):  `NUM_STAGE_4096 - 1 ): 0; 
            2'b01:   cnt_X_pipieline_dly = (cnt_X_pull_up == 1'b1 & X_pull_up == 1'b1) ? ((cnt_X_pipieline_1 != 0) ? (cnt_X_pipieline_1 - 1'b1):  `NUM_STAGE_2048 - 1 ): 0; 
            2'b10:   cnt_X_pipieline_dly = (cnt_X_pull_up == 1'b1 & X_pull_up == 1'b1) ? ((cnt_X_pipieline_1 != 0) ? (cnt_X_pipieline_1 - 1'b1):  `NUM_STAGE_1024 - 1 ): 0; 
            2'b11:   cnt_X_pipieline_dly = (cnt_X_pull_up == 1'b1 & X_pull_up == 1'b1) ? ((cnt_X_pipieline_1 != 0) ? (cnt_X_pipieline_1 - 1'b1):  `NUM_STAGE_512  - 1 ): 0; 
            default: cnt_X_pipieline_dly = 0;
        endcase
    
    end
               

    assign  cnt_X_pull_up_o     = cnt_X_pull_up;
    assign  multi_Xi_Y0_encode_o  =  cnt_X_pipieline_dly;       ///output for encode multiply for each stage
    
    
    ///////////////////////////////////////////////////////  
    //flag_for 2nd cycly calcul stage

    always @(posedge clk or negedge rstn) begin
          if (! rstn) begin
               Y_M_2_flag  <= 0;
          end 
          else if (multi_start_flag == 1'b1)
               Y_M_2_flag  <= 0;    
          else if (fall_edge == 1'b1)   
               Y_M_2_flag  <= 1'b1;  
    end
                   
    always @(posedge clk or negedge rstn) begin
           if (! rstn) begin
                cnt_fall  <= 0;
           end 
           else if (multi_start_flag == 1'b1)
                cnt_fall  <= 0;    
           else  if (Y_M_2_flag == 1'b1 | fall_edge == 1'b1 ) begin
                if (fall_edge == 1'b1)
                    cnt_fall  <= 0;
                else if (cnt_fall != NUM_PIPELINE)     //cnt to 9 pull up cycle start signal
                    cnt_fall  <= cnt_fall + 1'b1;
                else 
                    cnt_fall  <= cnt_fall;    
           end
           else 
               cnt_fall  <= 0;
    end
    
    //////////////////////////////////////////////////////
    ///Xi numbers for cycles 
    wire            flag_out;
    
    assign  Y_M_2_start_o  =  Y_M_2_start;
    assign  flag_out       =  (full_enter0_dly == 1'b1) ?  !X_pull_up : 0;
    assign  flag_to_mm_o   =  flag_out;             //output to mm 
    
    //////////////////out flag wr signal
    always @(posedge clk or negedge rstn) begin
         if (! rstn) 
             cnt_out <= 0;
         else if (flag_out == 1'b1) begin
              if (cnt_out != 9)
                  cnt_out <= cnt_out + 1'b1;
              else 
                  cnt_out <= cnt_out; 
         end 
         else 
              cnt_out <= 0;
    end  
    
    /*
    always @(posedge clk or negedge rstn) begin
       if (! rstn) 
           mm_out_en <= 0;
       else if (multi_start_flag == 1'b1)
           mm_out_en <= 0; 
       else if (cnt_out == 3)
           mm_out_en <= 1'b1;         //
    end
    */
    assign   mm_M_wr_en          = (cnt_out == 9) ? 1'b1: 0;
       
    assign   mm_M_wr_en_o        = mm_M_wr_en & flag_out;
    assign   mm_out_wr_en_o      = mm_out_en & flag_out; //& ~multi_start_flag;        //ouput
   
    assign   pre_carry_sum_ctl_o = pre_carry_sum_ctl;
    assign   pre_ctl_o           = pre_ctl;
    
 ///////////////////////////////////////////////////////////////////////////////
 //************************FSM  
        parameter    IDLE     = 3'b000;
        parameter    ENTER1   = 3'b001;
        parameter    ENTER2   = 3'b010;
        parameter    SS_MM    = 3'b011;
        parameter    CS_MM    = 3'b100;
        parameter    CS_PR    = 3'b101;
        parameter    EXIT     = 3'b110;
        parameter    DONE     = 3'b111;
        
    /////////////////////////////////////////////
    /////expon mask CTL
    reg         [12:0]   cnt_modular;
    wire                 ei;                 //expo_ei

    reg                  mm_out_en_dly;
    wire                 mm_out_en_edge;
    wire                 SS_cnt_ctl;
    reg         [4:0]    cnt_SS;
    reg                  shift;
    
    always @(posedge clk or negedge rstn) begin        
         if (! rstn) 
            cnt_modular <= 0; 
         else if (state == ENTER2 )
            cnt_modular <= 0;
         else if (next_state == SS_MM & mm_out_en_edge == 1'b1)
            cnt_modular <= cnt_modular + 1'b1;
    end
    
    always @(posedge clk or negedge rstn) begin        
        if (! rstn) 
           mm_out_en_dly <= 0; 
        else 
           mm_out_en_dly <= mm_out_en;
    end
    
    assign  mm_out_en_edge = mm_out_en & ~mm_out_en_dly;
    assign  SS_cnt_ctl     = mm_out_en_edge & (state == SS_MM );
   
    always @(posedge clk or negedge rstn) begin        
        if (! rstn) 
           cnt_SS <= 0; 
        else if (state == ENTER2 & mm_out_en_edge)
           cnt_SS <= 0;
        else if (SS_cnt_ctl == 1'b1)
           cnt_SS <= cnt_SS + 1'b1;
    end
    ////////////////fifo read ctl
    reg  rd_expon_en;
    
    always @(posedge clk or negedge rstn) begin        
         if (! rstn) 
            rd_expon_en <= 0; 
         else if  (state == ENTER2 & mm_out_en_edge | cnt_SS == 5'b00000 & shift == 1'b1)
            rd_expon_en <= 1'b1;
         else 
            rd_expon_en <= 1'b0;
    end   
    
    assign rd_expon_en_o = rd_expon_en;
    ///////
  
    always @(posedge clk or negedge rstn) begin        
         if (! rstn) 
            shift <= 0; 
         else if  (next_state == SS_MM &  mm_out_en_edge == 1'b1 )
            shift <= 1'b1;
         else 
            shift <= 1'b0;
    end   
    
    reg   [31:0]        expo_ei_reg ;
    always @(posedge clk or negedge rstn) begin        
         if (! rstn) 
            expo_ei_reg <= 0; 
         else if (state == ENTER2 & mm_out_en == 1'b1 | cnt_SS == 5'b00000 & mm_out_en == 1'b1)
            expo_ei_reg <= expo_ei;
         else if (shift == 1'b1)
            expo_ei_reg <= expo_ei_reg >> 1;
    end 
    
    assign  ei = expo_ei_reg[0];
       
    ////////////////////////////////////////////////////////
    wire       [10:0]       Random_B;

    reg                     pseudo_flag; 
    wire                    enable;
    
    assign  enable = (cnt_modular == 1);
    
    //module for random  Pseudo-operation
    lsfr_random_gen_11  U_lsfr_random_gen_11(
        .Clk        (clk        ),  
        .Reset      (rstn       ),
        .Start      (1'b1       ),
        .Enable     (enable     ),
        .Seed       (Seed       ),       
        .LFSR_o     (Random_B   )
    );
    
    reg       cnt_modular_flag ;
    
    always @(*) begin
            case (mode)
            2'b00:  begin
                        pseudo_flag      = (cnt_modular > Random_B[10:0] & cnt_modular < Random_B[10:0] + 1024 ) ? 1'b1 : 1'b0;   //Random_B
                        cnt_modular_flag = (cnt_modular == `FLAG_4096 + 16) ? 1'b1 :0;
                    end
            2'b01:  begin
                        pseudo_flag      = (cnt_modular > Random_B[9:0] & cnt_modular < Random_B[9:0] + 512 ) ? 1'b1 : 1'b0;   //Random_B[9:0]
                        cnt_modular_flag = (cnt_modular == `FLAG_2048 + 16) ? 1'b1 :0;
                    end
            2'b10:  begin   
                        pseudo_flag      = (cnt_modular > Random_B[8:0] & cnt_modular < Random_B[8:0] + 256 ) ? 1'b1 : 1'b0;  
                        cnt_modular_flag = (cnt_modular == `FLAG_1024 + 16) ? 1'b1 :0;
                    end
            2'b11:  begin   
                        pseudo_flag      = (cnt_modular > Random_B[7:0] & cnt_modular < Random_B[7:0] + 128 ) ? 1'b1 : 1'b0;  
                        cnt_modular_flag = (cnt_modular == `FLAG_512 + 16) ? 1'b1 :0;
                    end        
                    
            default: begin
                        pseudo_flag      = 0;
                        cnt_modular_flag = 0;
                     end 
            endcase         
    end
    
    //////////////FSM CTL
    //////////////////////////////////////////

    reg       [2:0]     state,next_state;
    
    ////////////////////////////ctl FSM
    always @(posedge clk or negedge rstn) begin
        if (! rstn )
            state <= 0;
        else 
            state <= next_state;
    end
    
    always @(*) begin
            case(state)
                IDLE:       begin
                                if (full_enter0 & ~full_enter0_dly )
                                    next_state = ENTER1;
                                else
                                    next_state = IDLE;
                            end
                            
                ENTER1:     begin
                                if (full_enter1 == 1'b1)
                                    next_state = ENTER2;
                                else
                                    next_state = ENTER1;
                            end
                            
                ENTER2:       begin
                                if (full_enter2 == 1'b1) begin
                                    if (ei == 1'b0)
                                        next_state = SS_MM;
                                    else 
                                        next_state = CS_MM;
                                end
                                else
                                    next_state = ENTER2;
                            end
                            
                SS_MM:      begin
                                if  (full_SS  & ~full_SS_dly) 
                                    if (cnt_modular_flag == 1'b1)
                                        next_state = EXIT;
                                    else if (ei == 1'b1 )//| pseudo_flag == 1'b1 ) 
                                        next_state = CS_MM;
                                    else if (pseudo_flag == 1'b1)
                                        next_state = CS_PR;
                                    else
                                        next_state = SS_MM;
                                else 
                                    next_state = SS_MM;
                            end
                            
                CS_MM:      begin                                 
                               if ((full_CS & ~full_CS_dly) == 1'b1)
                                    next_state = SS_MM;
                               else
                                    next_state = CS_MM;
                            end        
                      
                CS_PR:      begin
                                if ((full_CS_PR & ~full_CS_PR_dly) == 1'b1)
                                     next_state = SS_MM;
                                else
                                     next_state = CS_PR;
                            end
                            
                EXIT:       begin
                                if ((full_CS & ~full_CS_dly) == 1'b1)
                                    next_state = DONE;
                                else
                                    next_state = EXIT;
                            end
                            
                DONE:       begin
                                    next_state = IDLE;
                            end
                default:    next_state = IDLE;            
            endcase    
          end
//////////////////////////////////////////////////////
        
        reg         done;
        
        always @(posedge clk or negedge rstn) begin
            if (! rstn )
                done <= 0;
            else if (state == IDLE & next_state == ENTER1)
                done <= 0;
            else if (state == DONE)
                done <= 1'b1;
        end        
        
        assign  done_o = done;
    
endmodule
