
`timescale 1ns / 1ps
//===================================================================
// File Name	:  AXI_MASTER.v
// Project Name	:  AXI_MASTER 
// Create Date	:  2020/05/05
// Author		:  shaomignhe
// Description	:  AXI_MASTER
//				   master for ram ctl
//					1.read data from ram using master
//					2.write modular data to ram using master
//===================================================================


module AXI_MASTER  # (parameter ADDR_WIDTH=32,
                                 DATA_WIDTH=32)(
    input                               clk,
    input                               rstn,
    output     [3:0]                    M_AXI_AWID,
    output     [ADDR_WIDTH-1:0]         M_AXI_AWADDR,
    output     [7:0]                    M_AXI_AWLEN,  //burst length 0-255
    output     [2:0]                    M_AXI_AWSIZE,
    output     [1:0]                    M_AXI_AWBURST,
    output     [1:0]                    M_AXI_AWLOCK,
    output     [3:0]                    M_AXI_AWCACHE,
    output     [2:0]                    M_AXI_AWPROT,
    output     [3:0]                    M_AXI_AWQOS,
    output     [0:0]                    M_AXI_AWUSER,
    output                              M_AXI_AWVALID,
    input                               M_AXI_AWREADY,
    // master write data 
    output      [DATA_WIDTH-1:0]        M_AXI_WDATA,
    output      [3:0]                   M_AXI_WSTRB,
    output                              M_AXI_WLAST,
    output      [0:0]                   M_AXI_WUSER,
    output       		                 M_AXI_WVALID,
    input                               M_AXI_WREADY,
    //mast      er write response 
    input       [3:0]                   M_AXI_BID,
    input       [1:0]                   M_AXI_BRESP,
    input       [0:0]                   M_AXI_BUSER,
    input                               M_AXI_BVALID,
    output                              M_AXI_BREADY,
    //master read address 
    output      [3:0]                   M_AXI_ARID,
    output      [ADDR_WIDTH-1:0]        M_AXI_ARADDR,
    output      [7:0]                   M_AXI_ARLEN,
    output      [2:0]                   M_AXI_ARSIZE,
    output      [1:0]                   M_AXI_ARBUSRT,
    output      [1:0]                   M_AXI_ARLOCK,
    output      [3:0]                   M_AXI_ARCACHE,
    output      [2:0]                   M_AXI_ARPROT,
    output      [3:0]                   M_AXI_ARQOS,
    output      [0:0]                   M_AXI_ARUSER,
    output                              M_AXI_ARVALID,
    input                               M_AXI_ARREADY,
     // Master Read Data 
    input       [3:0]                   M_AXI_RID,
    input       [DATA_WIDTH-1:0]        M_AXI_RDATA,
    input       [1:0]                   M_AXI_RRESP,
    input                               M_AXI_RLAST,
    input       [0:0]                   M_AXI_RUSER,
    input                               M_AXI_RVALID,
    output                              M_AXI_RREADY,
    // master read data store in fifo 
    input       [31:0]                  RD_ADRS,  
    input       [31:0]                  RD_LENS,  
    input                               rd_start,
    output                              rd_ready,
    output                              axi_rd_done, 	//The burst read is completed
    output                              wr_fifo_we, 	//Write enable signal for writing fifo
    input                               wr_fifo_full,  	//fifo full signal, can't write anymore
    output      [DATA_WIDTH-1:0]        wr_fifo_data,	//Write the data read by axi to FIFO
    // read fifo and  axi  master write data 
    input       [31:0]                  WR_ADRS,  
    input       [31:0]                  WR_LENS,  		// WR_LENS
    input                               wr_start, 
    output                              wr_ready,  		//In idle state, you can initiate a write operation
    output                              axi_wr_done ,
    output                              rd_fifo_re,		//Read enable signal for reading fifo
    input                               rd_fifo_empty,
    input       [DATA_WIDTH-1:0]        rd_fifo_data
    
);
    
    reg               reg_arvalid ,reg_r_last;
    reg     [31:0]    reg_rd_addr ;
    reg     [7:0]     rd_len;
    reg     [31:0]    reg_rd_len;
    reg     [2:0]     rd_state;
    reg     [2:0]     wr_state;
    
    localparam    
                RA_IDLE     =   3'b000,
                RA_WAIT     =   3'b001,
                RA_START    =   3'b010,
                RD_WAIT     =   3'b011,
                RD_PROC     =   3'b100,
                RD_DONE     =   3'b101;
    

    
    always@(posedge clk or negedge rstn)begin 
        if(~rstn)begin 
            reg_rd_addr <=  32'b0;
            rd_len      <=  8'b0;
            reg_rd_len  <=  32'b0;
            rd_state    <=  RA_IDLE;
            reg_arvalid <=  1'b0;
            reg_r_last  <=  1'b0;
        end 
        else begin 
            case(rd_state)
                RA_IDLE: 
                         if(rd_start)begin
                             rd_state    <=  RA_START;
                             reg_rd_addr <=  RD_ADRS;  		 //  Read data from RD_ADRS block ram
                             reg_rd_len  <=  RD_LENS-1'b1;   //  Read data length
                         end
                         else begin 
                             reg_arvalid <=1'b0;
                             rd_len      <=8'b0;
                         end 
                RA_START:begin 
                             rd_state           <=  RD_WAIT;
                             reg_arvalid        <=  1'b1;
                             reg_rd_len[31:10]  <=  reg_rd_len[31:10] -21'b1;
                             if(reg_rd_len[31:10]!=21'b0)begin 
                                 reg_r_last <=1'b0;
                                 rd_len     <=8'hFF;
                             end 
                             else begin 
                                 reg_r_last  <=1'b1;
                                 rd_len[7:0] <=reg_rd_len[9:2];				//size 32bit 
                             end 
                         end 
                RD_WAIT :
                    if(M_AXI_ARREADY)begin 
                        rd_state    <=  RD_PROC;
                        reg_arvalid <=  1'b0;
                    end
                RD_PROC:begin 
                    if(M_AXI_RVALID)
                        if(M_AXI_RLAST) 									//Last data
                            if(reg_r_last)
                                rd_state    <=  RD_DONE;
                            else begin 
                                rd_state    <=  RA_START;
                                reg_rd_addr <=  RD_ADRS + {rd_len,2'b00};  	//Read data from RD_ADRS block ram  
                            end 
                        else 
                            rd_len  <= rd_len -8'd1;
                    end 
                RD_DONE: 
                     rd_state <= RA_IDLE;
                default: 	
                     rd_state <= RA_IDLE;
            endcase
        end 
    
    end 
    assign M_AXI_ARID           =   4'b0;
    assign M_AXI_ARADDR[31:0]   =   reg_rd_addr[31:0];
    assign M_AXI_ARLEN [7:0]    =   rd_len[7:0] ;
    assign M_AXI_ARSIZE[2:0]    =   3'b010; 			//32 bit 
    assign M_AXI_ARBUSRT[1:0]   =   2'b01;
    assign M_AXI_ARLOCK[1:0]    =   2'b00;
    assign M_AXI_ARCACHE[3:0]   =   4'b0011;
    assign M_AXI_ARPROT [2:0]   =   3'b000;
    assign M_AXI_ARQOS[3:0]     =   4'b0000;
    assign M_AXI_ARUSER[0]      =   1'b1;
    assign M_AXI_ARVALID        =   reg_arvalid;
 //   assign M_AXI_RREADY         =   M_AXI_RVALID & ~wr_fifo_full;
    assign M_AXI_RREADY         =   M_AXI_RVALID ;   
    
    assign rd_ready             =   ((rd_state==RA_IDLE) ? 1'b1 : 1'b0);
    assign wr_fifo_we           =   M_AXI_RVALID ? 1'b1:1'b0;  			// Data is valid, write fifo
    assign wr_fifo_data         =   M_AXI_RDATA[31:0] ; 				// Read the data
     
     /////////////////// axi master write ///////////////////
     
    reg                 reg_awvalid, reg_wvalid, reg_w_last;
    reg     [31:0]      reg_wr_addr;
    reg     [31:0]      reg_wr_len;
    reg     [7:0]       wr_len;
    reg                 wr_start_r,wr_start_r1,wr_start_r2;

    wire                wr_start_flag;
     
    
    
    localparam   
                WA_IDLE     =   3'b000,
                WA_START    =   3'b001,
                WD_WAIT     =   3'b010,
                WD_PROC     =   3'b011,
                WR_WAIT     =   3'b100,
                WR_DONE     =   3'b101;
                
    assign axi_rd_done = (rd_state==RD_DONE ? 1'b1 :1'b0);
    assign axi_wr_done = (wr_state==WR_DONE ? 1'b1 :1'b0);
    
    always@(posedge clk or negedge rstn)begin
        if(~rstn)begin
            wr_start_r  <=0;
            wr_start_r1 <=0;            
            wr_start_r2 <=0;
         end 
        else begin
            wr_start_r  <=wr_start;
            wr_start_r1 <=wr_start_r;     
            wr_start_r2 <=wr_start_r1;                                                                         
        end 
    end 
    assign wr_start_flag= wr_start_r1 &~wr_start_r2;
                            
    always@(posedge clk or negedge rstn)begin
        if(~rstn)begin 
            wr_state    <=  WA_IDLE;
            reg_awvalid <=  1'b0;
            reg_wvalid  <=  1'b0;
            reg_w_last  <=  1'b0;
            reg_wr_addr <=  32'b0;
            reg_wr_len  <=  32'b0;
            wr_len      <=  8'b0;
        end 
        else begin 
            case(wr_state)
                WA_IDLE: 
                        if(wr_start_flag)begin 
                            wr_state    <=  WA_START;
                            reg_wr_addr <=  WR_ADRS;
                            reg_wr_len  <=  WR_LENS -1'b1;
                        end 
                        else begin 
                            reg_awvalid <=  1'b0;
                            reg_wvalid  <=  1'b0;
                            reg_w_last  <=  1'b0;
                            wr_len      <=  8'b0;
                        end 
                WA_START: begin 
                            wr_state            <=  WD_WAIT;
                            reg_awvalid         <=  1'b1;
                            reg_wr_len[31:10]   <=  reg_wr_len[31:10] -21'b1;
//                            if(reg_wr_len[31:10]!=22'd0)begin 
//                                wr_len[7:0] <=  8'hFF;
//                                reg_w_last  <=  1'b0;
//                            end 
//                            else 
                            begin 
                                wr_len      <=  reg_wr_len[9:2];
                                reg_w_last  <=  1'b1;
                            end 
                         end
                WD_WAIT: if(M_AXI_AWREADY)begin 
                             wr_state       <=  WD_PROC;
                             reg_awvalid    <=  1'b0;
                             reg_wvalid     <=  1'b1;
                         end 
                WD_PROC: if(M_AXI_WREADY )begin   						//Write data every cycle
                            if(wr_len==8'b0)begin 
                                wr_state    <=  WR_WAIT;
                                reg_wvalid  <=  1'b0;
                            end 
                            else 
                                wr_len      <=  wr_len -8'b1;
                          end 
                WR_WAIT:
                         if(M_AXI_BVALID)
                            if(reg_w_last)
                                wr_state    <=  WR_DONE;
//                            else begin 
//                                wr_state    <=  WA_START;
//                                reg_wr_addr <=  WR_ADRS + {wr_len,2'b00};
//                            end 
                WR_DONE:
                        wr_state    <=  WA_IDLE;
                default :
                        wr_state    <=  WA_IDLE;
            endcase		
        end 
    end 
    
      assign     M_AXI_AWID         =   4'b0000;
      assign     M_AXI_AWADDR[31:0] =   reg_wr_addr[31:0];
      assign     M_AXI_AWLEN[7:0]   =   wr_len[7:0];
      assign     M_AXI_AWSIZE[2:0]  =   3'b010;
      assign     M_AXI_AWBURST[1:0] =   2'b01;
      assign     M_AXI_AWLOCK       =   2'b00;
      assign     M_AXI_AWCACHE[3:0] =   4'b0011;
      assign     M_AXI_AWPROT[2:0]  =   3'b000;
      assign     M_AXI_AWQOS[3:0]   =   4'b0000;
      assign     M_AXI_AWUSER[0]    =   1'b1;
      assign     M_AXI_AWVALID      =   reg_awvalid;
    
      assign     M_AXI_WDATA        =   rd_fifo_data;
      assign     M_AXI_WSTRB[3:0]   =   (reg_wvalid & ~rd_fifo_empty) ? 4'hF : 4'h0;
      assign     M_AXI_WLAST        =   (wr_len[7:0] == 8'd0) ? 1'b1 : 1'b0;
      assign     M_AXI_WUSER        =   1'b1;
      assign     M_AXI_WVALID       =   reg_wvalid & ~rd_fifo_empty;
      assign     M_AXI_BREADY       =   M_AXI_BVALID;
      assign     wr_ready           =   wr_state == WA_IDLE;
      
//      assign     rd_fifo_re           =   M_AXI_WVALID ? 1'b1:1'b0;  		// The data is valid, write fifo
      
endmodule 
