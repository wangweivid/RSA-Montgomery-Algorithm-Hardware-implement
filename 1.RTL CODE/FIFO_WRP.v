`timescale 1ns / 1ps

//===================================================================
// File Name	:  fifo_wrapper.v
// Project Name	:  fifo_wrapper 
// Create Date	:  2020/05/05
// Author		:  shaomignhe
// Description	:  fifo_wrapper
//===================================================================


module FIFO_WRP(
    input                  clka,
//    clkb,
    input                  rstn,
    
    input     [31:0]       din_0,
    input     [31:0]       din_1,
    input     [31:0]       din_2,
    input     [31:0]       din_3,
    input     [31:0]       din_4,
    
    input                  wr_en_0,
    input                  wr_en_1,
    input                  wr_en_2,
    input                  wr_en_3,
    input                  wr_en_4,
    
    input                  rd_en_0,
    input                  rd_en_1,
    input                  rd_en_2,
    input                  rd_en_3,
    input                  rd_en_4,
    
    output     [31:0]      dout_R2,   
    output     [31:0]      dout_N, 
    output     [31:0]      dout_M,
    output     [31:0]      dout_phi_N,
    output     [31:0]      dout_Ei, 
    
    output                 OUT_empty_0, 
    output                 OUT_empty_1,
    output                 OUT_empty_2,
    output                 OUT_empty_3,
    output                 OUT_empty_4
    
);
    
     //wire                 full_1,full_2,full_3,full_4,full_0;
     wire                 empty_0,empty_1,empty_2,empty_3,empty_4;
     reg                  reg_empty_0,reg_empty_1,reg_empty_2,reg_empty_3,reg_empty_4;

//     fifo_generator_0   u_fifo_R2 (
//         .clk                  (clka    ),                      // input wire clk
//         .srst                 (~rstn   ),                      // input wire srst
//         .din                  (din_0   ),                      // input wire [31 : 0] din
//         .wr_en                (wr_en_0 ),                      // input wire wr_en
//         .rd_en                (rd_en_0 ),                      // input wire rd_en
//         .dout                 (dout_R2 ),                      // output wire [31 : 0] dout
//         .full                 (        ),                      // output wire full
//         .almost_full          (        ),                      // output wire almost_full
//         .empty                (empty_0 ),                      // output wire empty
//         .almost_empty         (        )                       // output wire almost_empty
//       );  
       
     sync_fifo # (.FIFO_WIDTH (32),.FIFO_DEPTH(128) ) u_fifo_R2 (
         .clk        (clka          ),
         .rst_n      (rstn          ),
         .buf_in     (din_0       ),
         .buf_out    (dout_R2        ),
         .wr_en      (wr_en_0   ),
         .rd_en      (rd_en_0       ),
         .buf_empty  (empty_0       ),
         .buf_full   (              ),
         .fifo_cnt   (              )
     );    
       
       
//       fifo_generator_0     u_fifo_N (
//         .clk                  (clka    ),                      // input wire clk
//         .srst                 (~rstn   ),                      // input wire srst
//         .din                  (din_1   ),                      // input wire [31 : 0] din
//         .wr_en                (wr_en_1 ),                      // input wire wr_en
//         .rd_en                (rd_en_1 ),                      // input wire rd_en
//         .dout                 (dout_N  ),                      // output wire [31 : 0] dout
//         .full                 (        ),                      // output wire full
//         .almost_full          (  ),                      // output wire almost_full
//         .empty                (empty_1 ),                      // output wire empty
//         .almost_empty         (        )                       // output wire almost_empty

//       );  
       
       sync_fifo # (.FIFO_WIDTH (32),.FIFO_DEPTH(128) ) u_fifo_N (
           .clk        (clka          ),
           .rst_n      (rstn          ),
           .buf_in     (din_1       ),
           .buf_out    (dout_N        ),
           .wr_en      (wr_en_1   ),
           .rd_en      (rd_en_1       ),
           .buf_empty  (empty_1       ),
           .buf_full   (              ),
           .fifo_cnt   (              )
       ); 
         
//       fifo_generator_0     u_fifo_M (
//         .clk                  (clka    ),                      // input wire clk
//         .srst                 (~rstn   ),                      // input wire srst
//         .din                  (din_2   ),                      // input wire [31 : 0] din
//         .wr_en                (wr_en_2 ),                      // input wire wr_en
//         .rd_en                (rd_en_2 ),                      // input wire rd_en
//         .dout                 (dout_M  ),                      // output wire [31 : 0] dout
//         .full                 (        ),                      // output wire full
//         .almost_full          (  ),                      // output wire almost_full
//         .empty                (empty_2 ),                      // output wire empty
//         .almost_empty         (        )                       // output wire almost_empty
//       );  
       
       sync_fifo # (.FIFO_WIDTH (32),.FIFO_DEPTH(128) ) u_fifo_M (
           .clk        (clka          ),
           .rst_n      (rstn          ),
           .buf_in     (din_2       ),
           .buf_out    (dout_M        ),
           .wr_en      (wr_en_2   ),
           .rd_en      (rd_en_2       ),
           .buf_empty  (empty_2       ),
           .buf_full   (              ),
           .fifo_cnt   (              )
       ); 
       
//       fifo_generator_0     u_fifo_phi_N (
//         .clk                  (clka    ),                      // input wire clk
//         .srst                 (~rstn   ),                      // input wire srst
//         .din                  (din_3   ),                      // input wire [31 : 0] din
//         .wr_en                (wr_en_3 ),                      // input wire wr_en
//         .rd_en                (rd_en_3 ),                      // input wire rd_en
//         .dout                 (dout_phi_N),                    // output wire [31 : 0] dout
//         .full                 (        ),                      // output wire full
//         .almost_full          (  ),                      // output wire almost_full
//         .empty                (empty_3 ),                      // output wire empty
//         .almost_empty         (        )                       // output wire almost_empty

//       );  
       
       sync_fifo # (.FIFO_WIDTH (32),.FIFO_DEPTH(128) ) u_fifo_phi_N (
           .clk        (clka          ),
           .rst_n      (rstn          ),
           .buf_in     (din_3       ),
           .buf_out    (dout_phi_N        ),
           .wr_en      (wr_en_3  ),
           .rd_en      (rd_en_3      ),
           .buf_empty  (empty_3      ),
           .buf_full   (              ),
           .fifo_cnt   (              )
       ); 
       
//       fifo_generator_0     u_fifo_Ei (
//         .clk                  (clka    ),                      // input wire clk
//         .srst                 (~rstn   ),                      // input wire srst
//         .din                  (din_4   ),                      // input wire [31 : 0] din
//         .wr_en                (wr_en_4 ),                      // input wire wr_en
//         .rd_en                (rd_en_4 ),                      // input wire rd_en
//         .dout                 (dout_Ei ),                      // output wire [31 : 0] dout
//         .full                 (        ),                      // output wire full
//         .almost_full          (  ),                      // output wire almost_full
//         .empty                (empty_4 ),                      // output wire empty
//         .almost_empty         (        )                       // output wire almost_empty
//       );  
      
      sync_fifo # (.FIFO_WIDTH (32),.FIFO_DEPTH(128) ) u_fifo_Ei (
           .clk        (clka          ),
           .rst_n      (rstn          ),
           .buf_in     (din_4       ),
           .buf_out    (dout_Ei        ),
           .wr_en      (wr_en_4  ),
           .rd_en      (rd_en_4      ),
           .buf_empty  (empty_4      ),
           .buf_full   (              ),
           .fifo_cnt   (              )
       ); 
      
      
       //***********************full signal pull up 
       always @(posedge clka or negedge rstn) begin      
          if (! rstn)                                    
               reg_empty_0  <=  0;                        
          else if (empty_0 == 1'b1)                       
               reg_empty_0  <=  1'b1;
          else if (wr_en_0 == 1'b1)
               reg_empty_0  <=  1'b0;                   
       end                                               
                                                         
       always @(posedge clka or negedge rstn) begin      
          if (! rstn)                                    
               reg_empty_1  <=  0;                        
          else if (empty_1 == 1'b1)                       
               reg_empty_1  <=  1'b1;
          else if (wr_en_1 == 1'b1)     
               reg_empty_1  <=  1'b0;                      
       end                                               
                                                         
       always @(posedge clka or negedge rstn) begin      
          if (! rstn)                                    
               reg_empty_2  <=  0;                        
          else if (empty_2 == 1'b1)                       
               reg_empty_2  <=  1'b1;
          else if (wr_en_2 == 1'b1)        
               reg_empty_2  <=  1'b0;      
                               
       end                                               
                                                         
       always @(posedge clka or negedge rstn) begin      
          if (! rstn)                                    
               reg_empty_3  <=  0;                        
          else if (empty_3 == 1'b1)                       
               reg_empty_3  <=  1'b1; 
          else if (wr_en_3 == 1'b1)        
               reg_empty_3  <=  1'b0;                        
       end                                               
                                                         
       always @(posedge clka or negedge rstn) begin      
          if (! rstn)                                    
               reg_empty_4  <=  0;                        
          else if (empty_4 == 1'b1)                       
               reg_empty_4  <=  1'b1; 
          else if (wr_en_4 == 1'b1)        
               reg_empty_4  <=  1'b0;                                                                                                          
       end                                               
       
       //output empty ctl signal
       assign   OUT_empty_0  =   reg_empty_0;
       assign   OUT_empty_1  =   reg_empty_1;
       assign   OUT_empty_2  =   reg_empty_2;
       assign   OUT_empty_3  =   reg_empty_3;
       assign   OUT_empty_4  =   reg_empty_4;
          
endmodule
