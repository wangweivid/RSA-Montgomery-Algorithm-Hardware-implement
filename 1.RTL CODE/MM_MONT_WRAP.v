//===================================================================
// File Name	:  MM_MONT_WRAP.v
// Project Name	:  MM_MONT_WRAP 
// Create Date	:  2020/05/05
// Author		:  wangwei
// Description	:  MM_MONT_WRAP
//===================================================================

`include "/nfs54/project/spiderman/wangwei5/workspace/rsa/code_base16_0805/rtl/parameter.v"
`timescale 1ns / 1ps


module MM_MONT_WRAP(
    clk,
    rstn,

    pre_slast_ctl,
    pre_carry_sum_ctl,
    
    cnt_X_pull_up,
    Y_M_2_start,
    flag_to_mm,
    
    mult_Xi_Y0,
    multi_Xi_Y0_encode,
    
    X_j,
    Y_i,
    M_i,
    M_q,
    mode,
    
    S_result_o,
    mm_out_wr_en,
    M_o,
    mm_M_wr_en
);
     
    input                           clk;
    input                           rstn;

    input       [1:0]               mode;
    
    
    input                           pre_slast_ctl;
    input                           pre_carry_sum_ctl;
    
    input                           cnt_X_pull_up;
    input                           Y_M_2_start;
    input                           flag_to_mm;
    
    input       [15:0]              mult_Xi_Y0;
    
    input       [3:0]               multi_Xi_Y0_encode;
    
    input       [15:0]              X_j;
    input       [31:0]              Y_i;
    
    input       [31:0]              M_i;
    input       [15:0]              M_q;

    output      [31:0]              M_o;
    input                           mm_M_wr_en;
    
    output      [31:0]              S_result_o;
    input                           mm_out_wr_en;

    
    //1 latency
    //reg         [15:0]              reg_X;

    //reg         [31:0]              reg_Y;
    //reg         [31:0]              reg_M;
      
    //reg         [15:0]              reg_s0_last_qm;
    //reg                             empty_flag;
    //wire        [15:0]              multi_Xi;
        
    wire        [15:0]              s0;
    wire        [15:0]              s1;
    wire        [15:0]              s2;
    wire        [15:0]              s3;
    wire        [15:0]              s4;
    wire        [15:0]              s5;
    wire        [15:0]              s6;
    wire        [15:0]              s7;
    wire        [15:0]              s8;
    wire        [15:0]              s9;
    
    wire        [31:0]              Y_0, M_0;
    wire        [31:0]              Y_1, M_1;
    wire        [31:0]              Y_2, M_2;
    wire        [31:0]              Y_3, M_3;
    wire        [31:0]              Y_4, M_4;
    wire        [31:0]              Y_5, M_5;
    wire        [31:0]              Y_6, M_6;
    wire        [31:0]              Y_7, M_7;
    wire        [31:0]              Y_8, M_8;
    wire        [31:0]              Y_9, M_9;

    wire        [31:0]              Carry_0, Sum_0;
    wire        [31:0]              Carry_1, Sum_1;
    wire        [31:0]              Carry_2, Sum_2;
    wire        [31:0]              Carry_3, Sum_3;
    wire        [31:0]              Carry_4, Sum_4;
    wire        [31:0]              Carry_5, Sum_5;
    wire        [31:0]              Carry_6, Sum_6;
    wire        [31:0]              Carry_7, Sum_7;
    wire        [31:0]              Carry_8, Sum_8;
    wire        [31:0]              Carry_9, Sum_9;
    
    //reg         [7:0]               cnt_rd_X;
    //reg                             flag_out;
    //reg                             flag_out_dly;
        
//    always @(posedge clk or negedge rstn) begin             //latency 1 clk for enter data Yi/Mi 
//        if(!rstn) begin
//             reg_Y      <= 0;
//             reg_M      <= 0;
//        end
//        else if (empty_Y_M )begin
//             reg_Y      <= Y_i;
//             reg_M      <= M_i;
//        end
//        else begin
//             reg_Y      <= 0;
//             reg_M      <= 0;      
//        end        
//    end
    
    reg         [31:0]        reg_Y_in,reg_M_in;
    reg         [31:0]        Carry_pre,Sum_pre;
    reg         [15:0]        S_last_pre;
        
    wire        [31:0]        CARRY_4096,SUM_4096;              //result for muplitiy 
    wire        [31:0]        CARRY_2048,SUM_2048;  
    wire        [31:0]        CARRY_1024,SUM_1024;
    
    wire        [31:0]        Carry_9_shift,Sum_9_shift,M_9_shift,Y_9_shift;
    wire        [15:0]        s9_shift;
    
    //reg         [31:0]        Carry_reg,Sum_reg;
    reg         [31:0]        Carry,Sum;
    reg         [31:0]        M;
    
    always @(*) begin
        case (mode)
            2'b00:  begin       // 4096 bit
                        //data in select for pipiline 
                        reg_Y_in     =   (Y_M_2_start == 1'b0      ) ?  Y_i           : Y_9_shift;          
                        reg_M_in     =   (Y_M_2_start == 1'b0      ) ?  M_i           : M_9_shift;                                                                              
                        Carry_pre    =   (pre_carry_sum_ctl == 1'b1) ?  Carry_9_shift : 0 ;         
                        Sum_pre      =   (pre_carry_sum_ctl == 1'b1) ?  Sum_9_shift   : 0 ;         
                        S_last_pre   =   (pre_slast_ctl == 1'b1    ) ?  s9_shift      : 0 ;   
                        
                        //data out select for pipeline
                        Carry        =   (mm_out_wr_en == 1'b1     ) ?  CARRY_4096    : 0;
                        Sum          =   (mm_out_wr_en == 1'b1     ) ?  SUM_4096      : 0;
                        M            =   (mm_M_wr_en == 1'b1       ) ?  M_6           : 0;                                                                              
                    end
                    
            2'b01:  begin       // 2048 bit
                        reg_Y_in     =   (Y_M_2_start == 1'b0      ) ?  Y_i           : Y_5; 
                        reg_M_in     =   (Y_M_2_start == 1'b0      ) ?  M_i           : M_5;                                                                               
                        Carry_pre    =   (pre_carry_sum_ctl == 1'b1) ?  Carry_5       : 0;         
                        Sum_pre      =   (pre_carry_sum_ctl == 1'b1) ?  Sum_5         : 0;         
                        S_last_pre   =   (pre_slast_ctl == 1'b1    ) ?  s5            : 0; 
                
                        //data out select for pipeline
                        Carry        =   (mm_out_wr_en == 1'b1     ) ?  CARRY_2048    : 0;
                        Sum          =   (mm_out_wr_en == 1'b1     ) ?  SUM_2048      : 0;
                        M            =   (mm_M_wr_en == 1'b1       ) ?  M_2           : 0;   
                    end     
                     
            2'b10:  begin       // 1024 bit
                        reg_Y_in     =   (Y_M_2_start == 1'b0      ) ?  Y_i           : Y_3; 
                        reg_M_in     =   (Y_M_2_start == 1'b0      ) ?  M_i           : M_3;                                                                              
                        Carry_pre    =   (pre_carry_sum_ctl == 1'b1) ?  Carry_3       : 0;         
                        Sum_pre      =   (pre_carry_sum_ctl == 1'b1) ?  Sum_3         : 0;         
                        S_last_pre   =   (pre_slast_ctl == 1'b1    ) ?  s3            : 0; 
                
                        //data out select for pipeline
                        Carry        =   (mm_out_wr_en == 1'b1     ) ?  CARRY_1024    : 0;
                        Sum          =   (mm_out_wr_en == 1'b1     ) ?  SUM_1024      : 0;
                        M            =   (mm_M_wr_en == 1'b1       ) ?  M_0           : 0;              
                    end   
                
            2'b11:  begin       // 512 bit
                        reg_Y_in     =   (Y_M_2_start == 1'b0      ) ?  Y_i           : Y_1; 
                        reg_M_in     =   (Y_M_2_start == 1'b0      ) ?  M_i           : M_1; 
                                                                                                    
                        Carry_pre    =   (pre_carry_sum_ctl == 1'b1) ?  Carry_1       : 0;         
                        Sum_pre      =   (pre_carry_sum_ctl == 1'b1) ?  Sum_1         : 0;         
                        S_last_pre   =   (pre_slast_ctl == 1'b1    ) ?  s1            : 0; 
                
                        //data out select for pipeline
                        Carry        =   (mm_out_wr_en == 1'b1     ) ?  CARRY_1024    : 0;
                        Sum          =   (mm_out_wr_en == 1'b1     ) ?  SUM_1024      : 0;
                        M            =   (mm_M_wr_en == 1'b1       ) ?  M_0           : 0;   
            
                    end  
                    
            default :  ;         
        endcase
    
    end
    
    
    
//    assign   reg_Y_in     =   (Y_M_2_start == 1'b0)       ?  Y_i           :  Y_9_shift;   //Y data selsect for 2nd cycle and 1st
//    assign   reg_M_in     =   (Y_M_2_start == 1'b0)       ?  M_i           :  M_9_shift;   //M data selsect for 2nd cycle and 1st

//    assign   Carry_pre    =   (pre_carry_sum_ctl == 1'b1) ?  Carry_9_shift : 0 ;                        //Carry data selsect for 2nd cycle and 1st
//    assign   Sum_pre      =   (pre_carry_sum_ctl == 1'b1) ?  Sum_9_shift   : 0 ;                        //Sum data dselsect for 2nd cycle and 1st
//    assign   S_last_pre   =   (pre_slast_ctl == 1'b1          ) ?  s9_shift      : 0 ;                        //S_last data selsect for 2nd cycle and 1st
                       
    wire        [15:0]      multi_X_Y_0;                                                        //decode Xi*Y0 for 6 M.M cell
    wire        [15:0]      multi_X_Y_1;
    wire        [15:0]      multi_X_Y_2;
    wire        [15:0]      multi_X_Y_3;
    wire        [15:0]      multi_X_Y_4;
    wire        [15:0]      multi_X_Y_5;
    wire        [15:0]      multi_X_Y_6;
    wire        [15:0]      multi_X_Y_7;
    wire        [15:0]      multi_X_Y_8;
    wire        [15:0]      multi_X_Y_9;
    
    wire        [15:0]      Xi_0,Xi_1,Xi_2,Xi_3,Xi_4,Xi_5,Xi_6,Xi_7,Xi_8,Xi_9;                                       //decode Xi*Y0 for 6 M.M cell
    
    wire                    csa_flag_0,csa_flag_1,csa_flag_2,csa_flag_3,csa_flag_4,csa_flag_5,csa_flag_6,csa_flag_7,csa_flag_8,csa_flag_9;    //decode start Xi enter flag for each 6 M.M cell
             
    ///////////////////////////// Xi DECODE CTL FOR EACH 10 M.M ////////////////////////////////////////
    //input for X0*Y0
    multi_Xi_Y0_decoder U_multi_Xi_Y0_decoder(
        
        .clk                    (clk),               
        .rstn                   (rstn),              
                     
        .start                  (cnt_X_pull_up),             
        .valid                  (flag_to_mm),             
        .multi_Xi_Y0_encode     (multi_Xi_Y0_encode),
                      
        .mult_Xi_Y0             (mult_Xi_Y0),        
        .X_j                    (X_j),               
                    
        .Xi_0                   (Xi_0   ),              
        .Xi_1                   (Xi_1   ),              
        .Xi_2                   (Xi_2   ),              
        .Xi_3                   (Xi_3   ),              
        .Xi_4                   (Xi_4   ),              
        .Xi_5                   (Xi_5   ),              
        .Xi_6                   (Xi_6   ),              
        .Xi_7                   (Xi_7   ),              
        .Xi_8                   (Xi_8   ),              
        .Xi_9                   (Xi_9   ),              
                         
        .multi_X_Y_0            (multi_X_Y_0),       
        .multi_X_Y_1            (multi_X_Y_1),       
        .multi_X_Y_2            (multi_X_Y_2),       
        .multi_X_Y_3            (multi_X_Y_3),       
        .multi_X_Y_4            (multi_X_Y_4),       
        .multi_X_Y_5            (multi_X_Y_5),       
        .multi_X_Y_6            (multi_X_Y_6),       
        .multi_X_Y_7            (multi_X_Y_7),       
        .multi_X_Y_8            (multi_X_Y_8),       
        .multi_X_Y_9            (multi_X_Y_9),       
                                
        .csa_flag_0             (csa_flag_0  ),        
        .csa_flag_1             (csa_flag_1  ),        
        .csa_flag_2             (csa_flag_2  ),        
        .csa_flag_3             (csa_flag_3  ),        
        .csa_flag_4             (csa_flag_4  ),        
        .csa_flag_5             (csa_flag_5  ),        
        .csa_flag_6             (csa_flag_6  ),        
        .csa_flag_7             (csa_flag_7  ),        
        .csa_flag_8             (csa_flag_8  ),        
        .csa_flag_9             (csa_flag_9  )         
   );                    
 
    //M.M. pipeline cell 0     
    mm_csa_wrapper u_mm_csa_wrapper0(
         .clk           (clk        ),
         .rstn          (rstn       ),
         .mode          (mode       ),
         .start         (csa_flag_0 ),          //input  start_flag for M.M
         .X_j           (Xi_0       ),          //input  [15:0] Xi_0
         .Y_i           (reg_Y_in   ),          //input  [31:0] Yi_0
         .X_Y           (multi_X_Y_0),          //input  [15:0] Xi_0 * Y0
         .M_i           (reg_M_in   ),          //input  [31:0] Mi_0
         .S_last        (Sum_pre    ),          //input  [31:0] Sum    2nd cycle 
         .C_last        (Carry_pre  ),          //input  [31:0] Carry  2nd cycle 
         .M_q           (M_q        ),          //input  [15:0] M'
         .s0_last_qm    (S_last_pre ),          //input  [15:0] S_last 2nd cycle
         .Carry_o       (Carry_0    ),          //output  [31:0] Carry for next M.M cell
         .Sum_o         (Sum_0      ),          //output  [31:0] Sum   for next M.M cell
         .Co_o          (CARRY_1024 ),          //output  [31:0] Carry for calcu done data path    
         .So_o          (SUM_1024   ),          //output  [31:0] Sum for calcu done data path  
         .s0            (s0         ),          //output  [15:0] S_low for next M.M cell
         .Y_o           (Y_0        ),          //output  [31:0] Y Shift data flow
         .M_o           (M_0        )           //output  [31:0] M Shift data flow
     );
    
     //M.M. pipeline cell 1   
     mm_csa_wrapper u_mm_csa_wrapper1(
         .clk           (clk        ),
         .rstn          (rstn       ),
         .mode          (mode       ),
         .start         (csa_flag_1 ),
         .X_j           (Xi_1       ),
         .Y_i           (Y_0        ),
         .X_Y           (multi_X_Y_1),
         .M_i           (M_0        ),
         .S_last        (Sum_0      ),
         .C_last        (Carry_0    ),      //shift
         .M_q           (M_q        ),
         .s0_last_qm    (s0         ),
         .Carry_o       (Carry_1    ),
         .Sum_o         (Sum_1      ),
         .Co_o          (           ),
         .So_o          (           ),         
         .s0            (s1         ),
         .Y_o           (Y_1        ),
         .M_o           (M_1        )
      );
    
     //M.M. pipeline cell 2   
     mm_csa_wrapper u_mm_csa_wrapper2(
         .clk           (clk        ),
         .rstn          (rstn       ),
         .mode          (mode       ),
         .start         (csa_flag_2 ),
         .X_j           (Xi_2       ),
         .Y_i           (Y_1        ),
         .X_Y           (multi_X_Y_2),
         .M_i           (M_1        ),
         .S_last        (Sum_1      ),
         .C_last        (Carry_1    ),
         .M_q           (M_q        ),
         .s0_last_qm    (s1         ),
         .Carry_o       (Carry_2    ),       
         .Sum_o         (Sum_2      ),
         .Co_o          (CARRY_2048 ),
         .So_o          (SUM_2048   ), 
         .s0            (s2         ),
         .Y_o           (Y_2        ),
         .M_o           (M_2        )
      );
     
     //M.M. pipeline cell 3   
     mm_csa_wrapper u_mm_csa_wrapper3(
          .clk          (clk        ),
          .rstn         (rstn       ),
          .mode         (mode       ),
          .start        (csa_flag_3 ),
          .X_j          (Xi_3       ),
          .Y_i          (Y_2        ),
          .X_Y          (multi_X_Y_3),
          .M_i          (M_2        ),
          .S_last       (Sum_2      ),
          .C_last       (Carry_2    ),
          .M_q          (M_q        ),
          .s0_last_qm   (s2         ),
          .Carry_o      (Carry_3    ),
          .Sum_o        (Sum_3      ),
          .Co_o         (           ),
          .So_o         (           ),
          .s0           (s3         ),
          .Y_o          (Y_3        ),
          .M_o          (M_3        )
       );
       
     //M.M. pipeline cell 4    
     mm_csa_wrapper u_mm_csa_wrapper4(
           .clk         (clk        ),
           .rstn        (rstn       ),
           .mode        (mode       ),
           .start       (csa_flag_4 ),
           .X_j         (Xi_4       ),
           .Y_i         (Y_3        ),
           .X_Y         (multi_X_Y_4),
           .M_i         (M_3        ),
           .S_last      (Sum_3      ),
           .C_last      (Carry_3    ),
           .M_q         (M_q        ),
           .s0_last_qm  (s3         ),
           .Carry_o     (Carry_4    ),
           .Sum_o       (Sum_4      ),
           .Co_o        (           ),
           .So_o        (           ),           
           .s0          (s4         ),
           .Y_o         (Y_4        ),
           .M_o         (M_4        )
        );
        
       //M.M. pipeline cell 5   
       mm_csa_wrapper u_mm_csa_wrapper5(
          .clk          (clk        ),
          .rstn         (rstn       ),
          .mode         (mode       ),
          .start        (csa_flag_5 ),
          .X_j          (Xi_5       ),
          .Y_i          (Y_4        ),
          .X_Y          (multi_X_Y_5),
          .M_i          (M_4        ),
          .S_last       (Sum_4      ),
          .C_last       (Carry_4    ),
          .M_q          (M_q        ),
          .s0_last_qm   (s4         ),
          .Carry_o      (Carry_5    ),
          .Co_o         (           ),
          .So_o         (           ),
          .Sum_o        (Sum_5      ),
          .s0           (s5         ),
          .Y_o          (Y_5        ),
          .M_o          (M_5        )
       );
      
       //M.M. pipeline cell 6   
       mm_csa_wrapper u_mm_csa_wrapper6(
          .clk          (clk        ),
          .rstn         (rstn       ),
          .mode         (mode       ),
          .start        (csa_flag_6 ),
          .X_j          (Xi_6       ),
          .Y_i          (Y_5        ),
          .X_Y          (multi_X_Y_6),
          .M_i          (M_5        ),
          .S_last       (Sum_5      ),
          .C_last       (Carry_5    ),
          .M_q          (M_q        ),
          .s0_last_qm   (s5         ),
          .Carry_o      (Carry_6    ),
          .Co_o         (CARRY_4096 ),          //result for 4096 : 256 + 1 mm cell£¨expand 16 bit£© 257/7 ...7
          .So_o         (SUM_4096   ),
          .Sum_o        (Sum_6      ),
          .s0           (s6         ),
          .Y_o          (Y_6        ),
          .M_o          (M_6        )
       );
            
        //M.M. pipeline cell 7   
      mm_csa_wrapper u_mm_csa_wrapper7(
           .clk          (clk        ),
           .rstn         (rstn       ),
           .mode         (mode       ),
           .start        (csa_flag_7 ),
           .X_j          (Xi_7       ),
           .Y_i          (Y_6        ),
           .X_Y          (multi_X_Y_7),
           .M_i          (M_6        ),
           .S_last       (Sum_6      ),
           .C_last       (Carry_6    ),
           .M_q          (M_q        ),
           .s0_last_qm   (s6         ),
           .Carry_o      (Carry_7    ),
           .Co_o         (           ),
           .So_o         (           ),
           .Sum_o        (Sum_7      ),
           .s0           (s7         ),
           .Y_o          (Y_7        ),
           .M_o          (M_7        )
        );
              
         //M.M. pipeline cell 8   
       mm_csa_wrapper u_mm_csa_wrapper8(
            .clk          (clk        ),
            .rstn         (rstn       ),
            .mode         (mode       ),
            .start        (csa_flag_8 ),
            .X_j          (Xi_8       ),
            .Y_i          (Y_7        ),
            .X_Y          (multi_X_Y_8),
            .M_i          (M_7        ),
            .S_last       (Sum_7      ),
            .C_last       (Carry_7    ),
            .M_q          (M_q        ),
            .s0_last_qm   (s7         ),
            .Carry_o      (Carry_8    ),
            .Co_o         (           ),
            .So_o         (           ),
            .Sum_o        (Sum_8      ),
            .s0           (s8         ),
            .Y_o          (Y_8        ),
            .M_o          (M_8        )
         );
            
        //M.M. pipeline cell 9   
       mm_csa_wrapper u_mm_csa_wrapper9(
             .clk          (clk        ),
             .rstn         (rstn       ),
             .mode         (mode       ),
             .start        (csa_flag_9 ),
             .X_j          (Xi_9       ),
             .Y_i          (Y_8        ),
             .X_Y          (multi_X_Y_9),
             .M_i          (M_8        ),
             .S_last       (Sum_8      ),
             .C_last       (Carry_8    ),
             .M_q          (M_q        ),
             .s0_last_qm   (s8         ),
             .Carry_o      (Carry_9    ),
             .Co_o         (           ),
             .So_o         (           ),
             .Sum_o        (Sum_9      ),
             .s0           (s9         ),
             .Y_o          (Y_9        ),
             .M_o          (M_9        )
       ); 
       

       
       shift_reg_9    u_shift_reg_9_carry (
             .clk         (clk),   
             .rstn        (rstn), 
             .shift_i     (Carry_9),
             .shift_o     (Carry_9_shift)
        );       
       
       shift_reg_9    u_shift_reg_9_sum (
              .clk         (clk),   
              .rstn        (rstn), 
              .shift_i     (Sum_9),
              .shift_o     (Sum_9_shift)
        );  
        
       shift_reg_9    u_shift_reg_9_Y (
                .clk         (clk),   
                .rstn        (rstn), 
                .shift_i     (Y_9),
                .shift_o     (Y_9_shift)
        );        
      
      shift_reg_9    u_shift_reg_9_M(
                 .clk         (clk),   
                 .rstn        (rstn), 
                 .shift_i     (M_9),
                 .shift_o     (M_9_shift)
      );   
      
      shift_reg_9_16bit    u_shift_reg_9_S(
                 .clk         (clk),   
                 .rstn        (rstn), 
                 .shift_i     (s9),
                 .shift_o     (s9_shift)
      );           
                

      
      //////////////////out flag wr signal decode
      ////////////////////////////////////////////
      
      reg                   cin_high;
      wire      [32:0]      S_result;
      
      always @(posedge clk or negedge rstn) begin
        if (! rstn) 
             cin_high  <= 0;
        else 
             cin_high   <=  S_result[32];
      end
      
      
      assign  S_result   =   Carry + Sum + cin_high;
 
      assign  S_result_o =   S_result[31:0];                  //output [31:0]  S_result for M.M modular
      assign  M_o        =   M;                             //output [31:0] M for each Modular
      
endmodule
