`timescale 1ns / 1ps

//===================================================================
// File Name	:  sync_fifo_wrapper.v
// Project Name	:  sync_fifo_wrapper 
// Create Date	:  2020/05/05
// Author		:  shaomignhe
// Description	:  sync_fifo_wrapper
//===================================================================

`include "/nfs54/project/spiderman/wangwei5/workspace/rsa/code_base16_0805/rtl/parameter.v"

module sync_fifo_wrapper(
    input                  clk,
    input                  rstn,
   
    input     [1:0]        mode,
    input     [31:0]       mont_in,
    input                  mm_out_wr_en,
    input                  mm_M_wr_en,
    
    input                  done,
    input                  rd_fifo_en,
      
    input     [31:0]       N1_in,
    input     [31:0]       R2_in,
    
    input     [2:0]        state,
    input     [2:0]        next_state,

    input                  R2_en_wr,   
    
    input                  rd_en_0,
    input                  rd_en_1,
    input                  rd_en_2,
    input                  rd_en_3,
    input                  rd_en_4,
    input                  rd_en_5,
    input                  rd_en_6,
    
    output     [31:0]      dout_SS0,   
    output     [31:0]      dout_SS1, 
    output     [31:0]      dout_SS2,
    output     [31:0]      dout_CS,
    output     [31:0]      dout_N1, 
    output     [31:0]      dout_CS_PR,
    output     [31:0]      dout_SS_PR,
    
    output                 OUT_full_SS0,
    output                 OUT_full_SS1,
    output                 OUT_full_SS2,
    output                 OUT_full_CS, 
    output                 OUT_full_N1, 
    output                 OUT_full_CS_PR,
    output                 OUT_full_SS_PR,
    
    output                 OUT_empty_SS0,
    output                 OUT_empty_SS1,
    output                 OUT_empty_SS2,
    output                 OUT_empty_CS, 
    output                 OUT_empty_N1, 
    output                 OUT_empty_CS_PR,
    output                 OUT_empty_SS_PR
);
     wire                 wr_en_SS0_1;
     wire                 wr_en_SS2;
     wire                 wr_en_CS;
     wire                 wr_en_N1;
     wire                 wr_en_CS_PR;
     wire                 wr_en_SS_PR;
     
     //wire                 full_0,full_1,full_2,full_3,full_4,full_5,full_6;
     wire                 empty_0,empty_1,empty_2,empty_3,empty_4,empty_5,empty_6;
     
     wire        [31:0]   din_SS0,din_SS1,din_SS2,din_CS,din_N1,din_CS_PR,din_SS_PR;
     wire        [31:0]   dout_0,dout_1,dout_2,dout_3,dout_4,dout_5,dout_6;
     wire                 rd_en_CS;
          
     reg                  full_SS0, full_SS1,full_SS2, full_CS, full_N1,full_CS_PR,full_SS_PR;
     reg                  R2_en_dly;
 
     reg                  reg_empty_0,reg_empty_1,reg_empty_2,reg_empty_3,reg_empty_4,reg_empty_5,reg_empty_6;
     
     ///////////////////////////////////////////////////
     //read ctl
     assign  din_SS0   =  (next_state == `ENTER2 | next_state == `SS_MM) ?  mont_in:  0 ;
     assign  din_SS1   =  (next_state == `ENTER2 | next_state == `SS_MM) ?  mont_in:  0 ;
     assign  din_SS2   =  (next_state == `ENTER1)?  R2_in: ( (next_state == `ENTER2 | next_state == `SS_MM) ?  mont_in:  0 );
     assign  din_CS    =  (next_state == `ENTER1 | next_state == `CS_MM | next_state == `EXIT) ?  mont_in:  0;
     assign  din_N1    =  (next_state == `ENTER1 | next_state == `ENTER2 | next_state == `SS_MM | next_state == `CS_MM | next_state == `CS_PR| next_state == `EXIT) ?  N1_in: 0 ;
     
     assign  din_CS_PR =  (next_state == `ENTER2 | next_state == `CS_PR ) ?  mont_in:  0;
     assign  din_SS_PR =  (next_state == `ENTER2 | next_state == `SS_MM)  ?  mont_in:  0 ;
 
     always @(posedge clk or negedge rstn) begin
          if (! rstn) 
              R2_en_dly  <= 0;
          else 
              R2_en_dly  <= R2_en_wr;
     end
     
     //fifo wr_en_2  ctl sinal
     assign   wr_en_SS0_1 = ((next_state == `ENTER2 & state == `ENTER2)  | (next_state == `SS_MM & state == `SS_MM) ) ? (mm_out_wr_en & ~full_SS0): 0;
     assign   wr_en_SS2   =  (next_state == `ENTER1)? (R2_en_dly & ~full_SS2) : (wr_en_SS0_1) ;
     assign   wr_en_CS    =  (next_state == `ENTER1 & state == `ENTER1   | (next_state == `CS_MM  & state == `CS_MM) | (next_state == `EXIT  & state == `EXIT )) ? (mm_out_wr_en & ~full_CS) : 0;    
     assign   wr_en_N1    =  (next_state == `ENTER1 | next_state == `ENTER2 | next_state == `SS_MM | next_state == `CS_MM | next_state == `CS_PR  | next_state == `EXIT) ? (mm_M_wr_en & ~full_N1) : 0;    
     assign   wr_en_CS_PR =  (next_state == `ENTER2 & state == `ENTER2| next_state == `CS_PR & state == `CS_PR ) ?  (mm_out_wr_en & ~full_CS_PR): 0;
     assign   wr_en_SS_PR = wr_en_SS0_1;

     //fifo SSO
     sync_fifo # (.FIFO_WIDTH (32),.FIFO_DEPTH(128) ) U_sync_fifo_SS0 (
         .clk        (clk           ),
         .rst_n      (rstn          ),
         .buf_in     (din_SS0       ),
         .buf_out    (dout_0        ),
         .wr_en      (wr_en_SS0_1   ),
         .rd_en      (rd_en_0       ),
         .buf_empty  (empty_0       ),
         .buf_full   (              ),
         .fifo_cnt   (              )
       );  
       
       //fifo SS1
       sync_fifo # (.FIFO_WIDTH (32),.FIFO_DEPTH(128) ) U_sync_fifo_SS1  (
          .clk       (clk           ),       
          .rst_n     (rstn          ),      
          .buf_in    (din_SS1       ),   
          .buf_out   (dout_1        ),    
          .wr_en     (wr_en_SS0_1   ),   
          .rd_en     (rd_en_1       ),   
          .buf_empty (empty_1       ),          
          .buf_full  (              ),    
          .fifo_cnt  (              )           
        
       );  
       
       //fifo SS2
       sync_fifo # (.FIFO_WIDTH (32),.FIFO_DEPTH(128) ) U_sync_fifo_SS2  (
          .clk       (clk           ),       
          .rst_n     (rstn          ),      
          .buf_in    (din_SS2       ),   
          .buf_out   (dout_2        ),    
          .wr_en     (wr_en_SS2     ),   
          .rd_en     (rd_en_2       ),   
          .buf_empty (empty_2       ),          
          .buf_full  (              ),    
          .fifo_cnt  (              )     
       );  
       
       assign  rd_en_CS =  (done == 1'b0) ? rd_en_3 : rd_fifo_en;
       //fifo CS
       sync_fifo # (.FIFO_WIDTH (32),.FIFO_DEPTH(128) ) U_sync_fifo_CS  (
          .clk       (clk           ),       
          .rst_n     (rstn          ),      
          .buf_in    (din_CS        ),   
          .buf_out   (dout_3        ),    
          .wr_en     (wr_en_CS      ),   
          .rd_en     (rd_en_CS      ),   
          .buf_empty (empty_3       ),          
          .buf_full  (              ),    
          .fifo_cnt  (              )     
       );  
       
       //fifo N1
       sync_fifo # (.FIFO_WIDTH (32),.FIFO_DEPTH(128) ) U_sync_fifo_N1  (
          .clk       (clk           ),       
          .rst_n     (rstn          ),      
          .buf_in    (din_N1        ),   
          .buf_out   (dout_4        ),    
          .wr_en     (wr_en_N1      ),   
          .rd_en     (rd_en_4       ),   
          .buf_empty (empty_4       ),          
          .buf_full  (              ),    
          .fifo_cnt  (              )     
       );  
      
      //fifo CS_PR
      sync_fifo # (.FIFO_WIDTH (32),.FIFO_DEPTH(128) ) U_sync_fifo_CS_PR  (
          .clk       (clk           ),       
          .rst_n     (rstn          ),      
          .buf_in    (din_CS_PR     ),   
          .buf_out   (dout_5        ),    
          .wr_en     (wr_en_CS_PR   ),   
          .rd_en     (rd_en_5       ),   
          .buf_empty (empty_5       ),          
          .buf_full  (              ),    
          .fifo_cnt  (              )     
       ); 
       
       //fifo SS_PR
       sync_fifo # (.FIFO_WIDTH (32),.FIFO_DEPTH(128) ) U_sync_fifo_SS_PR  (
          .clk       (clk           ),       
          .rst_n     (rstn          ),      
          .buf_in    (din_SS_PR     ),   
          .buf_out   (dout_6        ),    
          .wr_en     (wr_en_SS_PR   ),   
          .rd_en     (rd_en_6       ),   
          .buf_empty (empty_6       ),          
          .buf_full  (              ),    
          .fifo_cnt  (              )     
       ); 
    
     reg   [6:0]    cnt_SS0,cnt_SS1,cnt_SS2,cnt_CS,cnt_N1,cnt_CS_PR,cnt_SS_PR;
     
     always @(posedge clk or negedge rstn) begin            //fifo cnt ctl for full flag 
          if (! rstn) begin
                cnt_SS0   <= 0;
                cnt_SS1   <= 0;
                cnt_SS2   <= 0;
                cnt_CS    <= 0;
                cnt_N1    <= 0;
                cnt_CS_PR <= 0;
                cnt_SS_PR <= 0;
          end      
          else begin  
                if (full_SS0 == 1'b1)
                    cnt_SS0 <= 0;
                else if (wr_en_SS0_1 == 1'b1)
                    cnt_SS0 <= cnt_SS0 + 1'b1;
                
                if (full_SS1 == 1'b1)           
                    cnt_SS1 <= 0;               
                else if (wr_en_SS0_1 == 1'b1)   
                    cnt_SS1 <= cnt_SS1 + 1'b1;  
                
                if (full_SS2 == 1'b1)           
                    cnt_SS2 <= 0;               
                else if (wr_en_SS2 == 1'b1)   
                    cnt_SS2 <= cnt_SS2 + 1'b1;  
                
                if (full_CS == 1'b1)           
                    cnt_CS  <= 0;               
                else if (wr_en_CS == 1'b1)   
                    cnt_CS  <= cnt_CS + 1'b1;  
                
                if (full_N1 == 1'b1)           
                    cnt_N1  <= 0;               
                else if (wr_en_N1 == 1'b1)   
                    cnt_N1  <= cnt_N1 + 1'b1;  
                
                if (full_CS_PR == 1'b1)           
                    cnt_CS_PR <= 0;               
                else if (wr_en_CS_PR == 1'b1)   
                    cnt_CS_PR <= cnt_CS_PR + 1'b1;  
                
                if (full_SS_PR == 1'b1)           
                    cnt_SS_PR <= 0;               
                else if (wr_en_SS_PR == 1'b1)   
                    cnt_SS_PR <= cnt_SS_PR + 1'b1;  
            end
     end
                
                
      always @(posedge clk or negedge rstn) begin       //full flag ctl 
            if (! rstn) begin
                     full_SS0   <= 0;
                     full_SS1   <= 0;
                     full_SS2   <= 0;
                     full_CS    <= 0;
                     full_N1    <= 0;
                     full_CS_PR <= 0;
                     full_SS_PR <= 0;
            end         
            else begin
                case(mode)
               2'b00: begin                //mode = 00, 4096
                    if (rd_en_0 == 1'b1)
                        full_SS0   <= 1'b0;
                    else if (cnt_SS0 == 7'd127)     //128 * 32
                        full_SS0   <= 1'b1;
                        
                    if (rd_en_1 == 1'b1)
                        full_SS1   <= 1'b0;                        
                    else if (cnt_SS1 == 7'd127)  
                        full_SS1   <= 1'b1;
                        
                    if (rd_en_2 == 1'b1)  
                        full_SS2   <= 1'b0;
                    else if (cnt_SS2 == 7'd127)    
                        full_SS2   <= 1'b1;
                        
                    if (rd_en_3 == 1'b1)  
                        full_CS   <= 1'b0;
                    else if (cnt_CS == 7'd127)
                        full_CS   <= 1'b1;
                        
                    if (rd_en_4 == 1'b1)  
                        full_N1   <= 1'b0;
                    else if (cnt_N1 == 7'd127)
                        full_N1    <= 1'b1;
                        
                    if (rd_en_5 == 1'b1)   
                        full_CS_PR <= 1'b0;
                    else if (cnt_CS_PR == 7'd127)
                        full_CS_PR <= 1'b1;
                        
                    if (rd_en_6 == 1'b1)   
                        full_SS_PR <= 1'b0; 
                    else if (cnt_SS_PR == 7'd127)
                        full_SS_PR <= 1'b1;             
                end   

            2'b01: begin                //mode = 00, 2048
                    if (rd_en_0 == 1'b1)
                        full_SS0   <= 1'b0;
                    else if (cnt_SS0 == 7'd63)     //64
                        full_SS0   <= 1'b1;
                        
                    if (rd_en_1 == 1'b1)
                        full_SS1   <= 1'b0;                        
                    else if (cnt_SS1 == 7'd63)  
                        full_SS1   <= 1'b1;
                        
                    if (rd_en_2 == 1'b1)  
                        full_SS2   <= 1'b0;
                    else if (cnt_SS2 == 7'd63)    
                        full_SS2   <= 1'b1;
                        
                    if (rd_en_3 == 1'b1)  
                        full_CS   <= 1'b0;
                    else if (cnt_CS == 7'd63)
                        full_CS   <= 1'b1;
                        
                    if (rd_en_4 == 1'b1)  
                        full_N1   <= 1'b0;
                    else if (cnt_N1 == 7'd63)
                        full_N1    <= 1'b1;
                        
                    if (rd_en_5 == 1'b1)   
                        full_CS_PR <= 1'b0;
                    else if (cnt_CS_PR == 7'd63)
                        full_CS_PR <= 1'b1;
                        
                    if (rd_en_6 == 1'b1)   
                        full_SS_PR <= 1'b0; 
                    else if (cnt_SS_PR == 7'd63)
                        full_SS_PR <= 1'b1;             
                end   
               
            2'b10: begin            //mode = 01, 1024
                    if (rd_en_0 == 1'b1)
                        full_SS0   <= 1'b0;
                    else if (cnt_SS0 == 7'd31)        //31
                        full_SS0   <= 1'b1;
                        
                    if (rd_en_1 == 1'b1)
                        full_SS1   <= 1'b0;                        
                    else if (cnt_SS1 == 7'd31)  
                        full_SS1   <= 1'b1;
                        
                    if (rd_en_2 == 1'b1)  
                        full_SS2   <= 1'b0;
                    else if (cnt_SS2 == 7'd31)    
                        full_SS2   <= 1'b1;
                        
                    if (rd_en_3 == 1'b1)  
                        full_CS    <= 1'b0;
                    else if (cnt_CS == 7'd31)
                        full_CS    <= 1'b1;
                        
                    if (rd_en_4 == 1'b1)  
                        full_N1    <= 1'b0;
                    else if (cnt_N1 == 7'd31)
                        full_N1    <= 1'b1;
                        
                    if (rd_en_5 == 1'b1)   
                        full_CS_PR   <= 1'b0;
                    else if (cnt_CS_PR == 7'd31)
                        full_CS_PR   <= 1'b1;
                        
                    if (rd_en_6 == 1'b1)   
                        full_SS_PR   <= 1'b0; 
                    else if (cnt_SS_PR == 7'd31)
                        full_SS_PR <= 1'b1;             
                end    
                
              2'b11: begin        //mode = 10, 512
                    if (rd_en_0 == 1'b1)
                        full_SS0   <= 1'b0;
                    else if (cnt_SS0 == 7'd15)     //64
                        full_SS0   <= 1'b1;
                        
                    if (rd_en_1 == 1'b1)
                        full_SS1   <= 1'b0;                        
                    else if (cnt_SS1 == 7'd15)  
                        full_SS1   <= 1'b1;
                        
                    if (rd_en_2 == 1'b1)  
                        full_SS2   <= 1'b0;
                    else if (cnt_SS2 == 7'd15)    
                        full_SS2   <= 1'b1;
                        
                    if (rd_en_3 == 1'b1)  
                        full_CS    <= 1'b0;
                    else if (cnt_CS == 7'd15 )
                        full_CS    <= 1'b1;
                        
                    if (rd_en_4 == 1'b1)  
                        full_N1    <= 1'b0;
                    else if (cnt_N1 == 7'd15)
                        full_N1    <= 1'b1;
                        
                    if (rd_en_5 == 1'b1)   
                        full_CS_PR   <= 1'b0;
                    else if (cnt_CS_PR == 7'd15)
                        full_CS_PR   <= 1'b1;
                        
                    if (rd_en_6 == 1'b1)   
                        full_SS_PR   <= 1'b0; 
                    else if (cnt_SS_PR == 7'd15)
                        full_SS_PR   <= 1'b1;             
                end
                default : begin
                     full_SS0   <= 0;
                     full_SS1   <= 0;
                     full_SS2   <= 0;
                     full_CS    <= 0;
                     full_N1    <= 0;
                     full_CS_PR <= 0;
                     full_SS_PR <= 0;
                end
              endcase
          end
      end

       //***********************full signal pull up
       always @(posedge clk or negedge rstn) begin
          if (! rstn) begin
               reg_empty_0  <=  0;
               reg_empty_1  <=  0;
               reg_empty_2  <=  0;
               reg_empty_3  <=  0;
               reg_empty_4  <=  0; 
               reg_empty_5  <=  0;
               reg_empty_6  <=  0;  
          end                 
          else begin
               reg_empty_0  <=  empty_0;
               reg_empty_1  <=  empty_1;
               reg_empty_2  <=  empty_2;
               reg_empty_3  <=  empty_3;
               reg_empty_4  <=  empty_4; 
               reg_empty_5  <=  empty_5; 
               reg_empty_6  <=  empty_6; 
          end      
       end
       
       //output full flag 
       assign  OUT_full_SS0     =  full_SS0   ;
       assign  OUT_full_SS1     =  full_SS1   ;
       assign  OUT_full_SS2     =  full_SS2   ;
       assign  OUT_full_CS      =  full_CS    ;
       assign  OUT_full_N1      =  full_N1    ;
       assign  OUT_full_CS_PR   =  full_CS_PR ;
       assign  OUT_full_SS_PR   =  full_SS_PR ;
       
       //output [31:0] read fifo data 
       assign  dout_SS0         =  dout_0;
       assign  dout_SS1         =  dout_1;
       assign  dout_SS2         =  dout_2;
       assign  dout_CS          =  dout_3;
       assign  dout_N1          =  dout_4;
       assign  dout_CS_PR       =  dout_5;
       assign  dout_SS_PR       =  dout_6;
       
       //output empty flag
       assign  OUT_empty_SS0    =  reg_empty_0;
       assign  OUT_empty_SS1    =  reg_empty_1;
       assign  OUT_empty_SS2    =  reg_empty_2;
       assign  OUT_empty_CS     =  reg_empty_3;
       assign  OUT_empty_N1     =  reg_empty_4;
       assign  OUT_empty_CS_PR  =  reg_empty_5;
       assign  OUT_empty_SS_PR  =  reg_empty_6;
       
endmodule
