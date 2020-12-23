`timescale 1ns / 1ps

//===================================================================
// File Name	:  RSA_TOP_WRAPPER.v
// Project Name	:  RSA_TOP_WRAPPER 
// Create Date	:  2020/05/05
// Author		:  shaomignhe
// Description	:  RSA_TOP_WRAPPER
//===================================================================


module RSA_TOP_WRP  #(parameter ADDR_WIDTH       = 32,
                                      DATA_WIDTH       = 32,
                                      S_AXI_DATA_WIDTH = 32, 
                                      S_AXI_ADDR_WIDTH = 12) (
    input                                    clk  ,
    input                                    rstn ,
    //AXI                                    Lite
    input      [S_AXI_ADDR_WIDTH-1 : 0]      S_AXI_AWADDR,
    input      [2 : 0]                       S_AXI_AWPROT,
    input                                    S_AXI_AWVALID,
    output                                   S_AXI_AWREADY,
    input      [S_AXI_DATA_WIDTH-1 : 0]      S_AXI_WDATA,
    input      [(S_AXI_DATA_WIDTH/8)-1 : 0]  S_AXI_WSTRB,
    input                                    S_AXI_WVALID,
    output                                   S_AXI_WREADY,
    output     [1 : 0]                       S_AXI_BRESP,
    output                                   S_AXI_BVALID,
    input                                    S_AXI_BREADY,
    input      [S_AXI_ADDR_WIDTH-1 : 0]      S_AXI_ARADDR,
    input      [2 : 0]                       S_AXI_ARPROT,
    input                                    S_AXI_ARVALID,
    output                                   S_AXI_ARREADY,
    output     [S_AXI_DATA_WIDTH-1 : 0]      S_AXI_RDATA,
    output     [1 : 0]                       S_AXI_RRESP,
    output                                   S_AXI_RVALID,
    input                                    S_AXI_RREADY
    );
    
 
    wire      [3:0]                 s_axi_awid       ;
    wire      [31:0]                s_axi_awaddr     ;
    wire      [7:0]                 s_axi_awlen      ;
    wire      [2:0]                 s_axi_awsize     ;
    wire      [1:0]                 s_axi_awburst    ;
    wire                            s_axi_awvalid    ;
    wire                            s_axi_awready    ;
    wire      [31:0]                s_axi_wdata      ;
    wire      [3:0]                 s_axi_wstrb      ;
    wire                            s_axi_wlast      ;
    wire                            s_axi_wvalid     ;
    wire                            s_axi_wready     ;
    wire       [3:0]                s_axi_bid        ;
    wire       [1:0]                s_axi_bresp      ;
    wire                            s_axi_bvalid     ;
    wire                            s_axi_bready     ;
    wire       [3:0]                s_axi_arid       ;
    wire       [31:0]               s_axi_araddr     ;
    wire       [7:0]                s_axi_arlen      ;
    wire       [2:0]                s_axi_arsize     ;
    wire       [1:0]                s_axi_arburst    ;
    wire                            s_axi_arvalid    ;
    wire                            s_axi_arready    ;
    wire       [3:0]                s_axi_rid        ;
    wire       [31:0]               s_axi_rdata      ;
    wire       [1:0]                s_axi_rresp      ;
    wire                            s_axi_rlast      ;
    wire                            s_axi_rvalid     ;
    wire                            s_axi_rready     ;
    
    
    wire                                           wr_en_0,wr_en_1,wr_en_2,wr_en_3,wr_en_4;
    wire            [31:0]                         din_0 ,din_1,din_2,din_3,din_4;
    

   
    wire            [31:0]                         dout_0,dout_1,dout_2,dout_3,dout_4;
    wire                                           empty_0,empty_1,empty_2,empty_3,empty_4;

    wire                                           RD_R2_EN, RD_N_EN, RD_M_EN;
    wire                                           RD_Phi_EN, RD_Ei_EN;



    RSA_TOP   #(        .ADDR_WIDTH(32),
                        .DATA_WIDTH(32),
                        .S_AXI_DATA_WIDTH(32), 
                        .S_AXI_ADDR_WIDTH(12)  )  
    U_RSA_TOP(
         .clk              (clk              ),
         .rstn             (rstn             ),
         .M_AXI_AWID       (s_axi_awid       ),
         .M_AXI_AWADDR     (s_axi_awaddr     ),
         .M_AXI_AWLEN      (s_axi_awlen      ),  //burst length 0-255
         .M_AXI_AWSIZE     (s_axi_awsize     ),
         .M_AXI_AWBURST    (s_axi_awburst    ),
         .M_AXI_AWLOCK     (                 ),
         .M_AXI_AWCACHE    (                 ),
         .M_AXI_AWPROT     (                 ),
         .M_AXI_AWQOS      (                 ),
         .M_AXI_AWUSER     (                 ),
         .M_AXI_AWVALID    (s_axi_awvalid    ),
         .M_AXI_AWREADY    (s_axi_awready    ),
        
        // master write data 
         .M_AXI_WDATA      (s_axi_wdata      ) ,
         .M_AXI_WSTRB      (s_axi_wstrb      ) ,
         .M_AXI_WLAST      (s_axi_wlast      ) ,
         .M_AXI_WUSER      (                 ) ,
         .M_AXI_WVALID     (s_axi_wvalid     ) ,
         .M_AXI_WREADY     (s_axi_wready     ) ,
        
        //master write response 
         .M_AXI_BID        (s_axi_bid        ),
         .M_AXI_BRESP      (s_axi_bresp      ),
         .M_AXI_BUSER      (1'b0             ),
         .M_AXI_BVALID     (s_axi_bvalid     ),
         .M_AXI_BREADY     (s_axi_bready     ),
        
        //master read address 
        . M_AXI_ARID       (s_axi_arid       ),
        . M_AXI_ARADDR     (s_axi_araddr     ),
        . M_AXI_ARLEN      (s_axi_arlen      ),
        . M_AXI_ARSIZE     (s_axi_arsize     ),
        . M_AXI_ARBUSRT    (s_axi_arburst    ),
        . M_AXI_ARLOCK     (                 ),
        . M_AXI_ARCACHE    (                 ),
        . M_AXI_ARPROT     (                 ),
        . M_AXI_ARQOS      (                 ),
        . M_AXI_ARUSER     (                 ),
        . M_AXI_ARVALID    (s_axi_arvalid    ),
        . M_AXI_ARREADY    (s_axi_arready    ),
        
         // Master Read Data 
         .M_AXI_RID        (s_axi_rid        ),
         .M_AXI_RDATA      (s_axi_rdata      ),
         .M_AXI_RRESP      (s_axi_rresp      ),
         .M_AXI_RLAST      (s_axi_rlast      ),
         .M_AXI_RUSER      (1'b0              ),
         .M_AXI_RVALID     (s_axi_rvalid     ),
         .M_AXI_RREADY     (s_axi_rready     ),
         
        //AXI Lite
         .S_AXI_AWADDR     (S_AXI_AWADDR     ) ,
         .S_AXI_AWPROT     (S_AXI_AWPROT     ) ,
         .S_AXI_AWVALID    (S_AXI_AWVALID    ) ,
         .S_AXI_AWREADY    (S_AXI_AWREADY    ) ,
         .S_AXI_WDATA      (S_AXI_WDATA      ) ,
         .S_AXI_WSTRB      (S_AXI_WSTRB      ) ,
         .S_AXI_WVALID     (S_AXI_WVALID     ) ,
         .S_AXI_WREADY     (S_AXI_WREADY     ) ,
         .S_AXI_BRESP      (S_AXI_BRESP      ) ,
         .S_AXI_BVALID     (S_AXI_BVALID     ) ,
         .S_AXI_BREADY     (S_AXI_BREADY     ) ,
         .S_AXI_ARADDR     (S_AXI_ARADDR     ) ,
         .S_AXI_ARPROT     (S_AXI_ARPROT     ) ,
         .S_AXI_ARVALID    (S_AXI_ARVALID    ) ,
         .S_AXI_ARREADY    (S_AXI_ARREADY    ) ,
         .S_AXI_RDATA      (S_AXI_RDATA      ) ,
         .S_AXI_RRESP      (S_AXI_RRESP      ) ,
         .S_AXI_RVALID     (S_AXI_RVALID     ) ,
         .S_AXI_RREADY     (S_AXI_RREADY     ) ,
         
         .data_R2          (dout_0           ),
         .data_N           (dout_1           ) ,      
         .data_M           (dout_2           ),      
         .data_phi_N       (dout_3           ),  
         .data_Ei          (dout_4           ),     
         
         .empty_0          (empty_0          ),     
         .empty_1          (empty_1          ),     
         .empty_2          (empty_2          ),     
         .empty_3          (empty_3          ),     
         .empty_4          (empty_4          ),         

         .din_0            (din_0),
         .din_1            (din_1),
         .din_2            (din_2),
         .din_3            (din_3),
         .din_4            (din_4),
         
         .wr_en_0          (wr_en_0         ),
         .wr_en_1          (wr_en_1         ),
         .wr_en_2          (wr_en_2         ),
         .wr_en_3          (wr_en_3         ),
         .wr_en_4          (wr_en_4         ),
         
         .RD_R2_EN         (RD_R2_EN), 
         .RD_N_EN          (RD_N_EN), 
         .RD_M_EN          (RD_M_EN),
         .RD_Phi_EN        (RD_Phi_EN), 
         .RD_Ei_EN         (RD_Ei_EN)
    );
    
    
    SRAM_INTERFACE  #(. DATA_WIDTH(32) , .ADDR_WIDTH(10),.DEEP_LENGTH(1024) )  U_SRAM (
         .clk              (clk              ),          // input wire s_aclk
         .rstn             (rstn             ),          // input wire s_aresetn
         
         .s_axi_awid       (s_axi_awid       ),          // input wire [3 : 0] s_axi_awid
         .s_axi_awaddr     (s_axi_awaddr     ),          // input wire [31 : 0] s_axi_awaddr
         .s_axi_awlen      (s_axi_awlen      ),          // input wire [7 : 0] s_axi_awlen
         .s_axi_awsize     (s_axi_awsize     ),          // input wire [2 : 0] s_axi_awsize
         .s_axi_awburst    (s_axi_awburst    ),          // input wire [1 : 0] s_axi_awburst
         .s_axi_awvalid    (s_axi_awvalid    ),          // input wire s_axi_awvalid
         .s_axi_awready    (s_axi_awready    ),          // output wire s_axi_awready
         .s_axi_wdata      (s_axi_wdata      ),          // input wire [31 : 0] s_axi_wdata
         .s_axi_wstrb      (s_axi_wstrb      ),          // input wire [3 : 0] s_axi_wstrb
         .s_axi_wlast      (s_axi_wlast      ),          // input wire s_axi_wlast
         .s_axi_wvalid     (s_axi_wvalid     ),          // input wire s_axi_wvalid
         .s_axi_wready     (s_axi_wready     ),          // output wire s_axi_wready
         .s_axi_bid        (s_axi_bid        ),          // output wire [3 : 0] s_axi_bid
         .s_axi_bresp      (s_axi_bresp      ),          // output wire [1 : 0] s_axi_bresp
         .s_axi_bvalid     (s_axi_bvalid     ),          // output wire s_axi_bvalid
         .s_axi_bready     (s_axi_bready     ),          // input wire s_axi_bready
         
         .s_axi_arid       (s_axi_arid       ),          // input wire [3 : 0] s_axi_arid
         .s_axi_araddr     (s_axi_araddr     ),          // input wire [31 : 0] s_axi_araddr
         .s_axi_arlen      (s_axi_arlen      ),          // input wire [7 : 0] s_axi_arlen
         .s_axi_arsize     (s_axi_arsize     ),          // input wire [2 : 0] s_axi_arsize
         .s_axi_arburst    (s_axi_arburst    ),          // input wire [1 : 0] s_axi_arburst
         .s_axi_arvalid    (s_axi_arvalid    ),          // input wire s_axi_arvalid
         .s_axi_arready    (s_axi_arready    ),          // output wire s_axi_arready
         .s_axi_rid        (s_axi_rid        ),          // output wire [3 : 0] s_axi_rid
         .s_axi_rdata      (s_axi_rdata      ),          // output wire [31 : 0] s_axi_rdata
         .s_axi_rresp      (s_axi_rresp      ),          // output wire [1 : 0] s_axi_rresp
         .s_axi_rlast      (s_axi_rlast      ),          // output wire s_axi_rlast
         .s_axi_rvalid     (s_axi_rvalid     ),          // output wire s_axi_rvalid
         .s_axi_rready     (s_axi_rready     )           // input wire s_axi_rready
    ); 
    
    //Buffer
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

  

endmodule
