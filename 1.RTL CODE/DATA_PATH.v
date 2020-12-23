`timescale 1ns / 1ps

//===================================================================
// File Name	:  DATA_PATH.v
// Project Name	:  DATA_PATH 
// Create Date	:  2020/05/05
// Author		:  wangwei
// Description	:  DATA_PATH
//===================================================================
`include "/nfs54/project/spiderman/wangwei5/workspace/rsa/code_base16_0805/rtl/parameter.v"

module DATA_PATH(
    input             clk,
    input             rstn,
    
    input   [15:0]    M_q_in,
    input   [15:0]    one_reg,
       
    input   [31:0]    R2_in,
    input   [31:0]    N_in,
    input   [31:0]    M_in,
    input   [31:0]    SS0_in,
    input   [31:0]    SS1_in,
    input   [31:0]    SS2_in,
    input   [31:0]    CS_in,
    input   [31:0]    N_1_in,
    input   [31:0]    CS_PR_in,
    input   [31:0]    SS_PR_in,
    
    input   [2:0]     state,
    input   [2:0]     next_state,
    input             RD_Xi_EN,
    input             RD_Yi_Mi_En,
    input   [4:0]     cnt_data_Xi,
    input   [3:0]     cnt_data_Y_M,
    input             Y_M_pull_up,
    input             X_pull_up , 
    input             Y_M_valid,          
    
    input             R2_empty,          //FIFO empty signal
    input             N_empty,        
    input             M_empty,        
    input             MM_SS0_empty,   
    input             MM_SS1_empty, 
    input             MM_SS2_empty,   
    input             MM_CS_empty,    
    input             MM_N_empty, 
    input             MM_CS_PR_empty,
    input             MM_SS_PR_empty,
    
    output  [15:0]    Xi_o,
    output  [31:0]    Yi_o,
    output  [31:0]    Mi_o,
    output  [15:0]    M_q_o,
    
    output            RD_R2_EN, 
    output            RD_N_EN,  
    output            RD_M_EN,  
    output            RD_SS0_EN,
    output            RD_SS1_EN,
    output            RD_SS2_EN ,                   
    output            RD_CS_EN ,                    
    output            RD_N1_EN,
    output            RD_CS_PR_EN,
    output            RD_SS_PR_EN,
     
    //output            empty_Y_M_o,
    output   [15:0]   mult_Xi_Y0_o,
    input             mm_clear
);
    
    reg     [31:0]           Xi,Yi,Mi;   
    reg                      empty_Y_M;
    
    reg     [15:0]           reg_Y0;
    reg     [15:0]           reg_Xi;
    wire    [15:0]           mult_Xi_Y0;
    
    wire    [15:0]           reg_Xi_valid;
    reg     [15:0]           reg_Xi_2_mm;
    reg                      Y_M_pre_ctl;
    
    
    ////////////////////////////////////////////////////////////////////// 
    //read fifo  signal decode ctl 
    assign    RD_R2_EN    =  ~R2_empty      & ((next_state == `ENTER1) ? RD_Yi_Mi_En : 1'b0);
    assign    RD_N_EN     =  ~N_empty       & ((next_state == `ENTER1) ? RD_Yi_Mi_En : 1'b0);
    assign    RD_M_EN     =  ~M_empty       & ((next_state == `ENTER2) ? RD_Xi_EN    : 1'b0);
    assign    RD_SS0_EN   =  ~MM_SS0_empty  & ((next_state == `SS_MM)  ? RD_Xi_EN    : 1'b0);
    assign    RD_SS1_EN   =  ~MM_SS1_empty  & ((next_state == `SS_MM   | next_state == `CS_MM)   ? RD_Xi_EN    : 1'b0);
    assign    RD_SS2_EN   =  ~MM_SS2_empty  & ((next_state == `SS_MM   | next_state == `ENTER2)  ? RD_Yi_Mi_En : 1'b0);
  
    assign    RD_CS_EN    =  ~MM_CS_empty   & ((next_state == `CS_MM   | next_state == `EXIT)    ? RD_Yi_Mi_En : 1'b0);
                                                              
    assign    RD_CS_PR_EN = ~MM_CS_PR_empty & ((next_state == `CS_PR)  ? RD_Xi_EN : 1'b0 );
    assign    RD_SS_PR_EN = ~MM_SS_PR_empty & ((next_state == `CS_PR   | next_state == `SS_MM )  ? RD_Yi_Mi_En : 1'b0 );
    assign    RD_N1_EN    = ~MM_N_empty     & ((next_state == `ENTER2  | next_state == `SS_MM    | next_state == `CS_MM |next_state == `CS_PR| next_state == `EXIT) ? RD_Yi_Mi_En    : 1'b0); 
    /////////////////////////////////////////////////////////////////////
    
    always @(*) begin            //data path MUX select for Xi,Yi,Mi
        if (! rstn ) begin
            Xi  = 0;
            Yi  = 0;
            Mi  = 0;
            empty_Y_M = 0;
        end
        else begin
               case (next_state)
                    `ENTER1:    begin
                                    Xi  =  {16'b0,one_reg};
                                    Yi  =   R2_in ;
                                    Mi  =   N_in  ;
                                    empty_Y_M = R2_empty & N_empty ;
                               end        
                    `ENTER2:    begin                  
                                    Xi  =  M_in;   
                                    Yi  =  SS2_in;     
                                    Mi  =  N_1_in; 
                                    empty_Y_M =  MM_SS2_empty & MM_N_empty ; 
                               end                    
                    `SS_MM:     begin                
                                    Xi  =  SS0_in; 
                                    Yi  =  SS2_in;  
                                    Mi  =  N_1_in; 
                                    empty_Y_M =  MM_SS2_empty & MM_N_empty  ; 
                               end                  
                    `CS_MM:     begin                
                                    Xi  =  SS1_in; 
                                    Yi  =  CS_in;  
                                    Mi  =  N_1_in;
                                    empty_Y_M =  MM_CS_empty & MM_N_empty  ;  
                               end   
                    `CS_PR:     begin
                                    Xi  =  CS_PR_in; 
                                    Yi  =  SS_PR_in;  
                                    Mi  =  N_1_in;
                                    empty_Y_M =  MM_SS_PR_empty & MM_N_empty  ;             
                               end               
                    `EXIT:     begin                
                                    Xi  =  {16'b0,one_reg}; 
                                    Yi  =  CS_in;  
                                    Mi  =  N_1_in;  
                                    empty_Y_M =  MM_CS_empty & MM_N_empty  ;
                              end                   
                    default:  begin                            
                                    Xi  = 0;
                                    Yi  = 0;
                                    Mi  = 0;
                                    empty_Y_M = 0;
                              end
               endcase
        end    
    end
    
    /////////////////////////////////////////////////////////////
     //multiply for  Xi * Y0             
     multi16_16  u_multi16_16(
           .clk              (clk            ),
           .rstn             (rstn           ),
           .multiplier       (reg_Xi_valid   ),
           .multiplicand     (reg_Y0         ),
           .S                (mult_Xi_Y0     )
     );
     ///////////////////////////////////////////////////////    
    
    //initial for YO*Xi
    always @(posedge clk or negedge rstn) begin   // Y0 
       if (! rstn) 
            reg_Y0  <= 0;
       else if (cnt_data_Y_M == 1) 
            reg_Y0  <= Yi[15:0];
       else 
            reg_Y0  <= reg_Y0;
    end 
    
    always @(posedge clk or negedge rstn) begin    //Xi
            if(!rstn) 
                 reg_Xi      <= 0;
            else if (cnt_data_Xi == 1'b1)
                 reg_Xi      <= Xi[15:0];
            else if (cnt_data_Xi == `NUM_PIPELINE + 1)
                 reg_Xi      <= Xi[31:16];
    end
    
    assign reg_Xi_valid = (X_pull_up== 1'b1)   ?  reg_Xi : 0;       //Xi data valid ctl
    


     always @(posedge clk or negedge rstn) begin                    //Xi data ctl to M.M.
           if (! rstn)   
               reg_Xi_2_mm  <= 0;
           else if (cnt_data_Xi == `NUM_MULTI_QM - 1'b1 | cnt_data_Xi == `NUM_MULTI_QM - 1'b1 + `NUM_PIPELINE) 
               reg_Xi_2_mm  <= reg_Xi_valid;
           else
               reg_Xi_2_mm  <= reg_Xi_2_mm;
     end  
       
     always @(posedge clk or negedge rstn) begin                    ///reg_Y_M_IN ctl  
           if (! rstn)   
               Y_M_pre_ctl  <= 0;    
           else if ( mm_clear == 1'b1) 
               Y_M_pre_ctl  <= 1'b1;
           else if (empty_Y_M == 1'b1)
               Y_M_pre_ctl  <= 1'b0;
     end 

     //assign  empty_Y_M_o  =   Y_M_pre_ctl;                          //output Y/M 1st cycle to M.M.

      
     assign  mult_Xi_Y0_o = mult_Xi_Y0;                             //output  [15:0] Xi*Y0 result to M.M.
     
     reg         [31:0]              reg_Y;
     reg         [31:0]              reg_M;
     
     always @(posedge clk or negedge rstn) begin             //latency 1 clk for enter data Yi/Mi 
         if(!rstn) begin
              reg_Y      <= 0;
              reg_M      <= 0;
         end
         else if ( Y_M_pre_ctl &  Y_M_valid ) begin
              reg_Y      <=    Yi ; 
              reg_M      <=    Mi ;
         end
         else begin
              reg_Y      <= 0;
              reg_M      <= 0;      
         end        
     end
     
          
     assign  Xi_o         =   reg_Xi_2_mm;                          //output [15:0]  Xi to M.M.
     assign  Yi_o         =   Y_M_valid ? reg_Y : 0;           //output [31:0]  Yi to M.M.
     assign  Mi_o         =   Y_M_valid ? reg_M : 0;           //output [31:0]  Mi to M.M.
     assign  M_q_o        =   M_q_in ;                              //output [15:0]  M'to M.M.
     
endmodule
