`timescale 1ns / 1ps

//===================================================================
// File Name	:  RSA_TOP.v
// Project Name	:  RSA_TOP 
// Create Date	:  2020/05/05
// Author		:  shaomignhe
// Description	:  RSA_TOP
//===================================================================

module RSA_TOP   #(parameter 
                                 ADDR_WIDTH         =   32,
                                 DATA_WIDTH         =   32,
                                 S_AXI_DATA_WIDTH   =   32, 
                                 S_AXI_ADDR_WIDTH   =   12  ) (
    input                                           clk,
    input                                           rstn,
    output          [3:0]                           M_AXI_AWID,
    output          [ADDR_WIDTH-1:0]                M_AXI_AWADDR,
    output          [7:0]                           M_AXI_AWLEN,  //burst length 0-255
    output          [2:0]                           M_AXI_AWSIZE,
    output          [1:0]                           M_AXI_AWBURST,
    output          [1:0]                           M_AXI_AWLOCK,
    output          [3:0]                           M_AXI_AWCACHE,
    output          [2:0]                           M_AXI_AWPROT,
    output          [3:0]                           M_AXI_AWQOS,
    output          [0:0]                           M_AXI_AWUSER,
    output                                          M_AXI_AWVALID,
    input                                           M_AXI_AWREADY,
    // master write data 
    output          [DATA_WIDTH-1:0]                M_AXI_WDATA,
    output          [3:0]                           M_AXI_WSTRB,
    output                                          M_AXI_WLAST,
    output          [0:0]                           M_AXI_WUSER,
    output                                          M_AXI_WVALID,
    input                                           M_AXI_WREADY,
    //master write response 
    input           [3:0]                           M_AXI_BID,
    input           [1:0]                           M_AXI_BRESP,
    input           [0:0]                           M_AXI_BUSER,
    input                                           M_AXI_BVALID,
    output                                          M_AXI_BREADY,
    //master read address 
    output          [3:0]                           M_AXI_ARID,
    output          [ADDR_WIDTH-1:0]                M_AXI_ARADDR,
    output          [7:0]                           M_AXI_ARLEN,
    output          [2:0]                           M_AXI_ARSIZE,
    output          [1:0]                           M_AXI_ARBUSRT,
    output          [1:0]                           M_AXI_ARLOCK,
    output          [3:0]                           M_AXI_ARCACHE,
    output          [2:0]                           M_AXI_ARPROT,
    output          [3:0]                           M_AXI_ARQOS,
    output          [0:0]                           M_AXI_ARUSER,
    output                                          M_AXI_ARVALID,
    input                                           M_AXI_ARREADY,
     // Master Read Data 
    input           [3:0]                           M_AXI_RID,
    input           [DATA_WIDTH-1:0]                M_AXI_RDATA,
    input           [1:0]                           M_AXI_RRESP,
    input                                           M_AXI_RLAST,
    input           [0:0]                           M_AXI_RUSER,
    input                                           M_AXI_RVALID,
    output                                          M_AXI_RREADY,   
    //AXI Lite
    // Global Clock Signal
    input           [S_AXI_ADDR_WIDTH-1 : 0]        S_AXI_AWADDR,
    input           [2 : 0]                         S_AXI_AWPROT,
    input                                           S_AXI_AWVALID,
    output                                          S_AXI_AWREADY,
    input           [S_AXI_DATA_WIDTH-1 : 0]        S_AXI_WDATA,
    input           [(S_AXI_DATA_WIDTH/8)-1 : 0]    S_AXI_WSTRB,
    input                                           S_AXI_WVALID,
    output                                          S_AXI_WREADY,
    output          [1 : 0]                         S_AXI_BRESP,
    output                                          S_AXI_BVALID,
    input                                           S_AXI_BREADY,
    input           [S_AXI_ADDR_WIDTH-1 : 0]        S_AXI_ARADDR,
    input           [2 : 0]                         S_AXI_ARPROT,
    input                                           S_AXI_ARVALID,
    output                                          S_AXI_ARREADY,
    output          [S_AXI_DATA_WIDTH-1 : 0]        S_AXI_RDATA,
    output          [1 : 0]                         S_AXI_RRESP,
    output                                          S_AXI_RVALID,
    input                                           S_AXI_RREADY,
    
    input           [31:0]                          data_R2,
    input           [31:0]                          data_N         ,      
    input           [31:0]                          data_M         ,      
    input           [31:0]                          data_phi_N     ,  
    input           [31:0]                          data_Ei        ,     
           
    input                                           empty_0    ,     
    input                                           empty_1    ,     
    input                                           empty_2    ,     
    input                                           empty_3    ,     
    input                                           empty_4 ,         

    output          [31:0]                          din_0,
    output          [31:0]                          din_1,
    output          [31:0]                          din_2,
    output          [31:0]                          din_3,
    output          [31:0]                          din_4,
    
    output                                          wr_en_0,
    output                                          wr_en_1,
    output                                          wr_en_2,
    output                                          wr_en_3,
    output                                          wr_en_4,
    
    output                                          RD_R2_EN, 
    output                                          RD_N_EN, 
    output                                          RD_M_EN,
    output                                          RD_Phi_EN, 
    output                                          RD_Ei_EN

);

    wire                                           full_0,full_1,full_2,full_3,full_4;  
    

 
    wire                                           done;
    wire            [31:0]                         data_modular  ;    
    wire                                           rd_fifo_en;
    
    wire 	        [S_AXI_DATA_WIDTH-1:0]          CMD_register;
    //wire            [S_AXI_DATA_WIDTH-1:0]          STATE_register;    
    wire            [S_AXI_DATA_WIDTH-1:0]          soft_reset ; 
    wire            [S_AXI_DATA_WIDTH-1:0]          random_seed  ; 
    wire            [S_AXI_DATA_WIDTH-1:0]          adjust_factor ;

    
    RSA_MODULAR_WRP U_RSA_MODULAR_WRP( 
        .clk            (clk          ),               
        .rstn           (rstn         ),              
        //input fifo empty ctl from fifo           
        .empty_0        (empty_0      ),           
        .empty_1        (empty_1      ),           
        .empty_2        (empty_2      ),           
        .empty_3        (empty_3      ),           
        .empty_4        (empty_4      ),           
        //input full ctl signal from AXI                               
        .full_0         (full_0       ),            
        .full_1         (full_1       ),            
        .full_2         (full_2       ),            
        .full_3         (full_3       ),            
        .full_4         (full_4       ),            
        //input [31:0] data from axi read from ram                                     
        .dout_0         (data_R2      ),            
        .dout_1         (data_N       ),            
        .dout_2         (data_M       ),            
        .dout_3         (data_phi_N   ),            
        .dout_4         (data_Ei      ),            
                                      
        .seed_exp_mask  (random_seed[15:0]),        //seed from software ctl
        .seed_pseudo    (random_seed[26:16] ),        //seed from software ctl  
        .M_q_in         (adjust_factor[15:0]),        //M' from software ctl
        
        .MODE           (CMD_register[2:1]),    //work mode 00--2048, 01-- 1024   10-- 512  other--reserved
                                  
        .RD_R2_EN       (RD_R2_EN     ),        //output read to fifo ctl      
        .RD_N_EN        (RD_N_EN      ),           
        .RD_M_EN        (RD_M_EN      ),           
        .RD_Phi_EN      (RD_Phi_EN    ),         
        .RD_Ei_EN       (RD_Ei_EN     ),
        
        .done           (done         ),        //modular calcaulte done flag
        .data_CS_o      (data_modular ),        //done data path to axi for trans to ram
        .rd_fifo_en     (rd_fifo_en   )         //done read fifo data ctl
    );
        
    /*
    //ext fifo                                    
    FIFO_WRP  U_FIFO_WRP(
        .clka           (clk        ),                            
        .rstn           (rstn       ),      
        //FIFO wr data from RAM , data buffer                      
        .din_0          (din_0      ),       
        .din_1          (din_1      ),       
        .din_2          (din_2      ),       
        .din_3          (din_3      ),       
        .din_4          (din_4      ),       
        //FIFO wr data ctl           
        .wr_en_0        (wr_en_0    ),     
        .wr_en_1        (wr_en_1    ),     
        .wr_en_2        (wr_en_2    ),     
        .wr_en_3        (wr_en_3    ),     
        .wr_en_4        (wr_en_4    ),     
        //fifo read ctl                     
        .rd_en_0        (RD_R2_EN   ),     
        .rd_en_1        (RD_N_EN    ),     
        .rd_en_2        (RD_M_EN    ),     
        .rd_en_3        (RD_Phi_EN  ),     
        .rd_en_4        (RD_Ei_EN   ),
        //fifo read data path            
        .dout_R2        (dout_0     ),     
        .dout_N         (dout_1     ),      
        .dout_M         (dout_2     ),      
        .dout_phi_N     (dout_3     ),  
        .dout_Ei        (dout_4     ),     
        //ouput fifo empty ctl signal      
        .OUT_empty_0    (empty_0    ),     
        .OUT_empty_1    (empty_1    ),     
        .OUT_empty_2    (empty_2    ),     
        .OUT_empty_3    (empty_3    ),     
        .OUT_empty_4    (empty_4    )      
    ); 
    */
      
    //AXI 
    AXI_MASTER_INTERFACE #( .ADDR_WIDTH(32), .DATA_WIDTH(32)) U_AXI_MASTER_INTERFACE (
        .clk                   (clk             ),
        .rstn                  (rstn            ),
        .M_AXI_AWID            (M_AXI_AWID      ),
        .M_AXI_AWADDR          (M_AXI_AWADDR    ),
        .M_AXI_AWLEN           (M_AXI_AWLEN     ),  //burst length 0-255
        .M_AXI_AWSIZE          (M_AXI_AWSIZE    ),
        .M_AXI_AWBURST         (M_AXI_AWBURST   ),
        .M_AXI_AWLOCK          (M_AXI_AWLOCK    ),
        .M_AXI_AWCACHE         (M_AXI_AWCACHE   ),
        .M_AXI_AWPROT          (M_AXI_AWPROT    ),
        .M_AXI_AWQOS           (M_AXI_AWQOS     ),
        .M_AXI_AWUSER          (M_AXI_AWUSER    ),
        .M_AXI_AWVALID         (M_AXI_AWVALID   ),
        .M_AXI_AWREADY         (M_AXI_AWREADY   ),
       // master write data 
        .M_AXI_WDATA           (M_AXI_WDATA     )     ,
        .M_AXI_WSTRB           (M_AXI_WSTRB     ) ,
        .M_AXI_WLAST           (M_AXI_WLAST     ) ,
        .M_AXI_WUSER           (M_AXI_WUSER     ) ,
        .M_AXI_WVALID          (M_AXI_WVALID    ) ,
        .M_AXI_WREADY          (M_AXI_WREADY    ) ,
       //master write response 
        .M_AXI_BID             (M_AXI_BID       ),
        .M_AXI_BRESP           (M_AXI_BRESP     ),
        .M_AXI_BUSER           (M_AXI_BUSER     ),
        .M_AXI_BVALID          (M_AXI_BVALID    ),
        .M_AXI_BREADY          (M_AXI_BREADY    ),
       //master read address 
        .M_AXI_ARID            (M_AXI_ARID      ),
        .M_AXI_ARADDR          (M_AXI_ARADDR    ),
        .M_AXI_ARLEN           (M_AXI_ARLEN     ),
        .M_AXI_ARSIZE          (M_AXI_ARSIZE    ),
        .M_AXI_ARBUSRT         (M_AXI_ARBUSRT   ),
        .M_AXI_ARLOCK          (M_AXI_ARLOCK    ),
        .M_AXI_ARCACHE         (M_AXI_ARCACHE   ),
        .M_AXI_ARPROT          (M_AXI_ARPROT    ),
        .M_AXI_ARQOS           (M_AXI_ARQOS     ),
        .M_AXI_ARUSER          (M_AXI_ARUSER    ),
        .M_AXI_ARVALID         (M_AXI_ARVALID   ),
        .M_AXI_ARREADY         (M_AXI_ARREADY   ),
        // Master Read Data 
        .M_AXI_RID             (M_AXI_RID       ),
        .M_AXI_RDATA           (M_AXI_RDATA     ),
        .M_AXI_RRESP           (M_AXI_RRESP     ),
        .M_AXI_RLAST           (M_AXI_RLAST     ),
        .M_AXI_RUSER           (M_AXI_RUSER     ),
        .M_AXI_RVALID          (M_AXI_RVALID    ),
        .M_AXI_RREADY          (M_AXI_RREADY    ),
        .start                 (CMD_register[0] ) ,     //CMD_register[0]    start flag 
        .rsa_mode              (CMD_register[2:1]),     //CMD_register[2:1]  mode

        .wr_en0                (wr_en_0         ),      //output write ctl to fifo
        .wr_en1                (wr_en_1         ),
        .wr_en2                (wr_en_2         ),
        .wr_en3                (wr_en_3         ),
        .wr_en4                (wr_en_4         ),
        
        .din0                  (din_0           ),      //output [31:0] writa data to fifo from axi 
        .din1                  (din_1           ),     
        .din2                  (din_2           ),        
        .din3                  (din_3           ),       
        .din4                  (din_4           ),
                                                
        .fifo_full_0           (full_0          ),      //output full flag to RSA CTL module 
        .fifo_full_1           (full_1          ),      
        .fifo_full_2           (full_2          ),
        .fifo_full_3           (full_3          ),
        .fifo_full_4           (full_4          ),
                                              
        .wr_start              (done            ),      //input modular done flag
        .rd_fifo_data          (data_modular    ),      //input modular done data path to axi/ram
        .rd_fifo_empty         (1'b0            ),  
        .rd_fifo_en            (rd_fifo_en      )       //outout read fifo for done data
    
   );
    
    //AXI slave reseave ctl signal /data from CPU 
    AXI_SLAVE #(  .S_AXI_DATA_WIDTH (32),
                 .S_AXI_ADDR_WIDTH (12) ) 
    U_AXI_SLAVE (
        //AXI Lite
        // Global Clock Signal
       .S_AXI_ACLK          (clk            ),
       .S_AXI_ARESETN       (rstn           ),
       .S_AXI_AWADDR        (S_AXI_AWADDR   ),
       .S_AXI_AWPROT        (S_AXI_AWPROT   ),
       .S_AXI_AWVALID       (S_AXI_AWVALID  ),
       .S_AXI_AWREADY       (S_AXI_AWREADY  ),
       .S_AXI_WDATA         (S_AXI_WDATA    ),
       .S_AXI_WSTRB         (S_AXI_WSTRB    ),
       .S_AXI_WVALID        (S_AXI_WVALID   ),
       .S_AXI_WREADY        (S_AXI_WREADY   ),
       .S_AXI_BRESP         (S_AXI_BRESP    ),
       .S_AXI_BVALID        (S_AXI_BVALID   ),
       .S_AXI_BREADY        (S_AXI_BREADY   ),
       .S_AXI_ARADDR        (S_AXI_ARADDR   ),
       .S_AXI_ARPROT        (S_AXI_ARPROT   ),
       .S_AXI_ARVALID       (S_AXI_ARVALID  ),
       .S_AXI_ARREADY       (S_AXI_ARREADY  ),
       .S_AXI_RDATA         (S_AXI_RDATA    ),
       .S_AXI_RRESP         (S_AXI_RRESP    ),
       .S_AXI_RVALID        (S_AXI_RVALID   ),
       .S_AXI_RREADY        (S_AXI_RREADY   ),
       .CMD_register        (CMD_register   ),          //register configure mode
       .STATE_register      (32'h0          ),
       .soft_reset          (soft_reset     ),  
       .random_seed         (random_seed    ),
       .adjust_factor       (adjust_factor  )
       
       
    );
        
endmodule 
