`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: shaominghe
// 
// Create Date: 2020/08/04 10:42:18
// Module Name: SRAM_INTERFACE
// Project Name: 
// Description: 
// 
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module SRAM_INTERFACE   #(parameter DATA_WIDTH =32 ,ADDR_WIDTH=10, DEEP_LENGTH=1024 ) 
(

     input                         clk                 ,
     input                         rstn             ,
     input   [3:0]                 s_axi_awid       ,
     input   [31:0]                s_axi_awaddr     ,
     input   [7:0]                 s_axi_awlen      ,
     input   [2:0]                 s_axi_awsize     ,
     input   [1:0]                 s_axi_awburst    ,
     input                         s_axi_awvalid    ,
     output                        s_axi_awready    ,
     input   [31:0]                s_axi_wdata      ,
     input   [3:0]                 s_axi_wstrb      ,
     input                         s_axi_wlast      ,
     input                         s_axi_wvalid     ,
     output                        s_axi_wready     ,
     
     output    [3:0]               s_axi_bid        ,
     output    [1:0]               s_axi_bresp      ,
     output                        s_axi_bvalid     ,
     input                         s_axi_bready     ,
     
     input    [3:0]                s_axi_arid       ,
     input    [31:0]               s_axi_araddr     ,
     input    [7:0]                s_axi_arlen      ,
     input    [2:0]                s_axi_arsize     ,
     input    [1:0]                s_axi_arburst    ,
     input                         s_axi_arvalid    ,
     output                        s_axi_arready    ,
     output    [3:0]               s_axi_rid        ,
     output    [31:0]              s_axi_rdata      ,
     output    [1:0]               s_axi_rresp      ,
     output                        s_axi_rlast      ,
     output                        s_axi_rvalid     ,
     input                         s_axi_rready     

);



   reg [2:0] wr_state;// wr_state_next;
   
   reg [31:0] wr_addr;//  START address 
   reg [7:0]  wr_len;
   reg        wr_ram_en;
   reg  reg_awready;
   reg  reg_wready;
   reg  reg_bvalid;

   localparam   
               WA_IDLE     =   3'b000,
               WD_WAIT     =   3'b010,
               WD_PROC     =   3'b011,
               WR_WAIT     =   3'b100,
               WR_DONE     =   3'b101;

   
   always@(posedge clk or negedge rstn)begin 
       if(~rstn)begin 
       // reg_awready<=1'b;
       // reg_wready<=1'b1;
       reg_awready<=1'b0;
       reg_wready<=1'b0;    
       reg_bvalid<=1'b0;         
       wr_len<=0;
       wr_addr<=0;
       wr_ram_en<=0;
       wr_state<=WA_IDLE;
       end 
       else begin 
           case(wr_state)
               WA_IDLE: 
                   if(s_axi_awvalid)begin         
                   wr_addr  <=s_axi_awaddr;       
                   reg_awready<=1'b1;
                   wr_len<=s_axi_awlen;
                   wr_state<=WD_WAIT;
                   end 
               WD_WAIT: 
                   if(s_axi_wvalid)begin 
                   reg_awready<=1'b0;
                   reg_wready<=1'b1;    
                   wr_state<=WD_PROC;
                   wr_ram_en<=1'b1;
                   end 
               WD_PROC:
                   if(wr_len==8'd0)begin
                   wr_ram_en<=1'b0;
                   reg_wready<=1'b0;
                   reg_bvalid<=1'b1;
                   wr_state<=WR_WAIT;
                   end 
                   else begin 
                   wr_len<=wr_len -1'b1;
                   wr_addr<=wr_addr+1'b1;
                   end 
               WR_WAIT:
                   if(s_axi_bready)begin 
                   reg_bvalid<=1'b0;
                   wr_state<=WR_DONE;
                   end 
               WR_DONE:
                   wr_state<=WA_IDLE;
               default :
                   wr_state<=WA_IDLE;
           endcase
       end 
   end 

   assign   s_axi_awready    = reg_awready;
   assign   s_axi_wready     = reg_wready;
   assign   s_axi_bid        = 4'b0000;
   assign   s_axi_bresp      =(s_axi_awid==4'b0) ? 2'b0 : 2'b1;
   assign   s_axi_bvalid     =reg_bvalid;
   
   
     reg reg_arready ;
     //reg reg_rlast;
     reg reg_rvalid;
     reg [31:0]rd_addr ;
     reg [7:0]rd_len;
     wire [31:0] doutb; 
     
     reg [2:0] rd_state;
     
    
   localparam    
               RA_IDLE     =   3'b000,
               RA_WAIT     =   3'b001,
               RD_WAIT     =   3'b010,
               RD_PROC     =   3'b011,
               RD_DONE     =   3'b100;

   always@(posedge clk or negedge rstn)begin 
       if(~rstn)begin 
           reg_arready<=0;
           //reg_rlast<=0;
           reg_rvalid<=0;
           rd_addr<=0;
           rd_len<=0;
           rd_state<=RA_IDLE;
       
       end
       else begin 
           case(rd_state)
               RA_IDLE: 
                   if(s_axi_arvalid)begin 
                   reg_arready<=1'b1;
                   rd_addr<=s_axi_araddr;
                   rd_len<=s_axi_arlen;
                   rd_state<=RA_WAIT;
                   end 
                   else begin                 
                   rd_state<=RA_IDLE;
                   end 
               RA_WAIT: begin 
                   reg_arready<=1'b0;
                   rd_state<=RD_WAIT;
                   end 
               RD_WAIT: 
                   begin 
                   reg_rvalid<=1'b1;
                   rd_addr<=rd_addr+1'b1;
                   rd_state<=RD_PROC;    
                   end                     
               RD_PROC:             
                   begin 
                       if(rd_len>8'd1)begin 
                       rd_len<=rd_len -1'b1;
                       rd_addr<=rd_addr+1'b1;
                       end 
                       else if(rd_len==8'd1) begin 
                       rd_len<=rd_len -1'b1;
                       end
                       else  if(rd_len==8'd0)begin
                       reg_rvalid<=1'b0;
                       rd_state<=RD_DONE;
                       end
                   end 
               RD_DONE: 
                   rd_state<=RA_IDLE;
               default: 
                   rd_state<=RA_IDLE;
           endcase
       end 
   end 

assign    s_axi_arready= reg_arready;
assign    s_axi_rid    = 4'b0000;
assign    s_axi_rdata  =doutb;
assign    s_axi_rlast  =(rd_len ==8'd0  & rd_state==RD_PROC)? 1:0;
assign    s_axi_rvalid =reg_rvalid;
assign    s_axi_rresp  = (s_axi_arid==4'b0) ? 2'b0 : 2'b1;


ram_instance  #(. DATA_WIDTH(32) , .ADDR_WIDTH(10),.DEEP_LENGTH(1024))  u_ram_instance(
          .clk  (clk),
          .rstn(rstn),
          .wea  (wr_ram_en),    // write enable 
          .addra(wr_addr[9:0]),  // input data address   [9:0]
          .dina (s_axi_wdata),  // input write data     [31:0]
          .addrb(rd_addr[9:0]),  // read data address 
          .doutb(doutb)   // read data     
   ); 
   
   
   
   
   

endmodule  


 
