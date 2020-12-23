`timescale 1ns / 1ps

//===================================================================
// File Name	:  RSA_MODULAR_WRAPPE.v
// Project Name	:  RSA_MODULAR_WRAPPE 
// Create Date	:  2020/05/05
// Author		:  shaomignhe
// Description	:  RSA_MODULAR_WRAPPER
//===================================================================


module RSA_MODULAR_WRP(
    input                                  clk,
    input                                  rstn,
    //EXT FIFO empty ctl signal
    input                                  empty_0,
    input                                  empty_1,
    input                                  empty_2,
    input                                  empty_3,
    input                                  empty_4,
    //EXT FIFO full ctl signal
    input                                  full_0,
    input                                  full_1,
    input                                  full_2,
    input                                  full_3,
    input                                  full_4,
    //EXT data [31:0]
    input           [31:0]                 dout_0,
    input           [31:0]                 dout_1,
    input           [31:0]                 dout_2,
    input           [31:0]                 dout_3,
    input           [31:0]                 dout_4,
    //seed mask or pseudo
    input           [15:0]                 seed_exp_mask,
    input           [10:0]                 seed_pseudo,
    input           [15:0]                 M_q_in,
    //rsa work mode
    input           [1 :0]                 MODE,
    //EXT FIFO read ctl signal
    output                                 RD_R2_EN, 
    output                                 RD_N_EN, 
    output                                 RD_M_EN,
    output                                 RD_Phi_EN, 
    output                                 RD_Ei_EN,
    //rsa done / data_out
    output                                 done,
    output          [31:0]                 data_CS_o,
    //read INT FIFO from CS to RAM though AXI
    input                                  rd_fifo_en
    
);
    
    //wire                                   wr_en_0,wr_en_1,wr_en_2,wr_en_3,wr_en_4;

    //expoen mask 
    wire            [31:0]                 expo_mask;
    wire                                   RD_Xi_EN_o,RD_Yi_Mi_EN_o;
    wire            [2:0]                  state,next_state;
    wire                                   RD_N1_EN, RD_SS0_EN, RD_SS1_EN, RD_SS2_EN, RD_CS_EN, RD_CS_PR_EN, RD_SS_PR_EN;
    wire                                   rd_en_expon;   //read fifo expon
    
    wire            [31:0]                 Yi,Mi;
    wire            [15:0]                 Xi;
    wire            [15:0]                 M_q;
    
    wire                                   pre_ctl,pre_carry_sum_ctl;
    wire            [15:0]                 one_reg;
    
    wire            [4:0]                  cnt_data_Xi;
    wire            [3:0]                  cnt_data_Y_M;
    wire            [15:0]                 mult_Xi_Y0;
    wire            [3:0]                  multi_Xi_Y0_encode;
    
    wire                                   cnt_X_pull_up;
    wire                                   Y_M_2_start; 
    wire                                   flag_to_mm;      //mm output flag
   
    wire            [31:0]                 S_result;        //output mm
    wire            [31:0]                 M_to_N1;         // M for FIFO N1
    
    wire                                   mm_out_wr_en;    //ouput wr fifo enbale
    wire                                   mm_M_wr_en;      //output wr_fifo N1 enable
    
    wire                                   full_SS0,full_SS1,full_SS2,full_CS,full_N1,full_CS_PR;
    wire                                   X_pull_up ,Y_M_pull_up,Y_M_valid;  //output to datapath  
    wire             [31:0]                data_SS0, data_SS1, data_SS2, data_CS, data_N1, data_CS_PR, data_SS_PR;                                       
    
    wire                                   empty_SS1,empty_SS2,empty_CS,empty_N1, MM_CS_PR_empty, MM_SS_PR_empty;
    wire                                   mm_clear;
    
    MM_MONT_WRAP  U_MM_MONT_WRAP(
            .clk                    (clk            ),        
            .rstn                   (rstn           ),       
      
            .pre_slast_ctl          (pre_ctl        ),       //MM cell Y/M 2nd cycle vaild signal
            .pre_carry_sum_ctl      (pre_carry_sum_ctl),     //MM cell carry/sum 2nd cycle vaild signal
            
            .multi_Xi_Y0_encode     (multi_Xi_Y0_encode),    //Xi*Y0 encoder
            .cnt_X_pull_up          (cnt_X_pull_up  ),       //X vaild signal
            .mult_Xi_Y0             (mult_Xi_Y0     ),       //Xi * Y0
            
            .flag_to_mm             (flag_to_mm     ),       //MM cell encoder flag
            .Y_M_2_start            (Y_M_2_start    ) ,      //MM Y/M 2nd vaild 
            .X_j                    (Xi             ),       //input Xi[15£º0]
            .Y_i                    (Yi             ),       //input Yi[15£º0] 
            .M_i                    (Mi             ),       //input Mi[15£º0] 
            .M_q                    (M_q            ),       //software config M'
            .mode                   (MODE           ),       //rsa work mode config
            
            .M_o                    (M_to_N1        ),       //each cycle for M_FIFO
            .mm_M_wr_en             (mm_M_wr_en     ),       //M FIFO write enable
            .S_result_o             (S_result       ),       //output S_result [31:0]
            .mm_out_wr_en           (mm_out_wr_en   )        //S_result write enable 
        );
    
    sync_fifo_wrapper  U_sync_fifo_wrapper( 
        .clk                    (clk            ),            
        .rstn                   (rstn           ),
        
        .done                   (done           ),
        .mode                   (MODE           ),   
        .mont_in                (S_result       ),
        .mm_out_wr_en           (mm_out_wr_en   ),                   //mm out wr to fifo
        .mm_M_wr_en             (mm_M_wr_en     ),
        .N1_in                  (M_to_N1        ),                   //fifo N1
        .R2_in                  (dout_0         ),                    //fifo SS2
          
        .rd_fifo_en             (rd_fifo_en     ),                       
        .state                  (state          ),
        .next_state             (next_state     ),
        .R2_en_wr               (RD_R2_EN       ),
                               
        .rd_en_0                (RD_SS0_EN      ),
        .rd_en_1                (RD_SS1_EN      ),
        .rd_en_2                (RD_SS2_EN      ),
        .rd_en_3                (RD_CS_EN       ),
        .rd_en_4                (RD_N1_EN       ),
        .rd_en_5                (RD_CS_PR_EN    ),
        .rd_en_6                (RD_SS_PR_EN    ),
                              
        .dout_SS0               (data_SS0       ),
        .dout_SS1               (data_SS1       ),
        .dout_SS2               (data_SS2       ),
        .dout_CS                (data_CS        ),
        .dout_N1                (data_N1        ),
        .dout_CS_PR             (data_CS_PR     ),
        .dout_SS_PR             (data_SS_PR     ),
                         
        .OUT_full_SS0           (full_SS0       ),
        .OUT_full_SS1           (full_SS1       ),
        .OUT_full_SS2           (full_SS2       ),
        .OUT_full_CS            (full_CS        ),
        .OUT_full_N1            (full_N1        ),
        .OUT_full_CS_PR         (full_CS_PR     ),
        .OUT_full_SS_PR         (     ),
                         
        .OUT_empty_SS0          (      ),
        .OUT_empty_SS1          (empty_SS1      ),
        .OUT_empty_SS2          (empty_SS2      ),
        .OUT_empty_CS           (empty_CS       ),
        .OUT_empty_N1           (empty_N1       ),
        .OUT_empty_CS_PR        (MM_CS_PR_empty ),
        .OUT_empty_SS_PR        (MM_SS_PR_empty )
    
    );
        //
     mask_exp_ctl U_mask_exp_ctl(
        .clk                    (clk            ),          
        .rstn                   (rstn           ),  
        .mode                   (MODE           ),          //rsa work mode              
        .Seed                   (seed_exp_mask  ),          //AXI reg cinfig
        .Phi_N                  (dout_3         ),          //EXT FIFO datain[31:0] Euler
        .Ei                     (dout_4         ),          //EXT FIFO datain[31:0] Ei      
        .Eepon_o                (expo_mask      ),          //FSM read data for exponent
        .Rd_en_phi              (RD_Phi_EN      ),          //Euler read ctl enable
        .Rd_en_Ei               (RD_Ei_EN       ),          //Ei read ctl enable
        .Rd_en_expon            (rd_en_expon    ),
        .full_phi_N             (full_3         ),
        .full_Ei                (full_4         ),
        .Phi_empty              (empty_3        ),
        .Ei_empty               (empty_4        )  
    );
        
    FSM_MODULAR_CTL  U_FSM_MODULAR_CTL(
        .clk                    (clk            ),      
        .rstn                   (rstn           ),
        
        .Seed                   (seed_pseudo    ),     //seed pseudo random gen
        .mode                   (MODE           ),     //rsa config mode    
                      
        .R2_full                (full_0         ),     //INT FIFO full ctl signal
        .N_full                 (full_1         ),
        .M_full                 (full_2         ),
        .MM_SS0_full            (full_SS0       ),
        .MM_SS1_full            (full_SS1       ),
        .MM_SS2_full            (full_SS2       ),
        .MM_CS_full             (full_CS        ),
        .MM_N_full              (full_N1        ),
        .CS_PR_full             (full_CS_PR     ), 
                               
        .expo_ei                (expo_mask      ),      //mask data input [31:0]
        .rd_expon_en_o          (rd_en_expon    ),      //mask read ctl signal
        
        .state                  (state          ),      //FSM state     
        .next_state             (next_state     ),     
        
        .RD_Xi_EN_o             (RD_Xi_EN_o     ),      //datapath to decode read crl for INT FIFO
        .RD_Yi_Mi_EN_o          (RD_Yi_Mi_EN_o  ),
        
        .one_reg_o              (one_reg        ),      //CTL Valid signal for X/Y/M
        .cnt_data_Xi_o          (cnt_data_Xi    ),
        .cnt_data_Y_M_o         (cnt_data_Y_M   ),             
        .X_pull_up_o            (X_pull_up      ),          
        .Y_M_pull_up_o          (Y_M_pull_up    ),
        .Y_M_valid_o            (Y_M_valid      ),
        .mm_clear_o             (mm_clear       ),
        
        .multi_Xi_Y0_encode_o   (multi_Xi_Y0_encode),  //mm
        .cnt_X_pull_up_o        (cnt_X_pull_up  ),
        .Y_M_2_start_o          (Y_M_2_start    ),
        .flag_to_mm_o           (flag_to_mm     ),
        .mm_M_wr_en_o           (mm_M_wr_en     ),
        .mm_out_wr_en_o         (mm_out_wr_en   ),

        .pre_ctl_o              (pre_ctl        ),
        .pre_carry_sum_ctl_o    (pre_carry_sum_ctl),
        .done_o                 (done           )
    );
       
       
    DATA_PATH  U_DATA_PATH( 
        .clk                    (clk            ),        
        .rstn                   (rstn           ),   
       
        .M_q_in                 (M_q_in         ),       //M'  
        .one_reg                (one_reg        ),       //FSAM     
        .R2_in                  (dout_0         ),       //FIFO
        .N_in                   (dout_1         ),       
        .M_in                   (dout_2         ),  
            
        .SS0_in                 (data_SS0       ),       //datain[31:0] from FIFO
        .SS1_in                 (data_SS1       ),
        .SS2_in                 (data_SS2       ),     
        .CS_in                  (data_CS        ),      
        .N_1_in                 (data_N1        ),     
        .CS_PR_in               (data_CS_PR     ),
        .SS_PR_in               (data_SS_PR     ),
                               
        .state                  (state          ),       //FSM state
        .next_state             (next_state     ), 
        
        .RD_Xi_EN               (RD_Xi_EN_o     ),       //read X/Y/M data ctl
        .RD_Yi_Mi_En            (RD_Yi_Mi_EN_o  ),
        .cnt_data_Xi            (cnt_data_Xi    ),
        .cnt_data_Y_M           (cnt_data_Y_M   ),
        .Y_M_pull_up            (Y_M_pull_up    ),
        .X_pull_up              (X_pull_up      ),
        .Y_M_valid              (Y_M_valid      ),
                    
        .R2_empty               (empty_0        ),       //INT fifo empty signal
        .N_empty                (empty_1        ),     
        .M_empty                (empty_2        ),     
        .MM_SS0_empty           (1'b0           ),
        .MM_SS1_empty           (empty_SS1      ),
        .MM_SS2_empty           (empty_SS2      ),
        .MM_CS_empty            (empty_CS       ), 
        .MM_N_empty             (empty_N1       ),
        .MM_CS_PR_empty         (MM_CS_PR_empty ),
        .MM_SS_PR_empty         (MM_SS_PR_empty ),
                 
        .Xi_o                   (Xi             ),       //output [15:0] Xi for MM cell
        .Yi_o                   (Yi             ),       //output [31:0] Yi for MM cell
        .Mi_o                   (Mi             ),       //output [31:0] Mi for MM cell
        .M_q_o                  (M_q            ),
        
        .RD_R2_EN               (RD_R2_EN       ),       // read enable to INT FIFO
        .RD_N_EN                (RD_N_EN        ),   
        .RD_M_EN                (RD_M_EN        ),   
        .RD_SS0_EN              (RD_SS0_EN      ), 
        .RD_SS1_EN              (RD_SS1_EN      ),       // CS Xi
        .RD_SS2_EN              (RD_SS2_EN      ) ,
        .RD_CS_EN               (RD_CS_EN       ), 
        .RD_N1_EN               (RD_N1_EN       ) ,  
        .RD_CS_PR_EN            (RD_CS_PR_EN    ),
        .RD_SS_PR_EN            (RD_SS_PR_EN    ),
        
        //.empty_Y_M_o            (empty_Y_M      ),       //MM cell Y/M valid ctl
        .mult_Xi_Y0_o           (mult_Xi_Y0     ),       //MM cell Xi * Y0
        .mm_clear               (mm_clear       )        //FSM clear signal
    );     
    
    
    
    assign  data_CS_o = data_CS;          
endmodule
