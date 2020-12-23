`timescale 1ns / 1ps
//===================================================================
// File Name	:  AXI_INTERFACE.v
// Project Name	:  AXI_INTERFACE 
// Create Date	:  2020/05/05
// Author		:  shaomignhe
// Description	:  AXI_INTERFACE:
//						1. AXI CTL to RAM;
//						2. AXI CTL to Modular
//===================================================================


module AXI_MASTER_INTERFACE  #(parameter ADDR_WIDTH=32, DATA_WIDTH=32)   (
    input                             clk,
    input                             rstn,
    output      [3:0]                 M_AXI_AWID,
    output      [ADDR_WIDTH-1:0]      M_AXI_AWADDR,
    output      [7:0]                 M_AXI_AWLEN,  //burst length 0-255
    output      [2:0]                 M_AXI_AWSIZE,
    output      [1:0]                 M_AXI_AWBURST,
    output      [1:0]                 M_AXI_AWLOCK,
    output      [3:0]                 M_AXI_AWCACHE,
    output      [2:0]                 M_AXI_AWPROT,
    output      [3:0]                 M_AXI_AWQOS,
    output      [0:0]                 M_AXI_AWUSER,
    output                            M_AXI_AWVALID,
    input                             M_AXI_AWREADY,
    // master wrrte
    output      [DATA_WIDTH-1:0]      M_AXI_WDATA,
    output      [3:0]                 M_AXI_WSTRB,
    output                            M_AXI_WLAST,
    output      [0:0]                 M_AXI_WUSER,
    output                            M_AXI_WVALID,
    input                             M_AXI_WREADY,
    //master write res
    input       [3:0]                 M_AXI_BID,
    input       [1:0]                 M_AXI_BRESP,
    input       [0:0]                 M_AXI_BUSER,
    input                             M_AXI_BVALID,
    output                            M_AXI_BREADY,
    //master read ad
    output      [3:0]                 M_AXI_ARID,
    output      [ADDR_WIDTH-1:0]      M_AXI_ARADDR,
    output      [7:0]                 M_AXI_ARLEN,
    output      [2:0]                 M_AXI_ARSIZE,
    output      [1:0]                 M_AXI_ARBUSRT,
    output      [1:0]                 M_AXI_ARLOCK,
    output      [3:0]                 M_AXI_ARCACHE,
    output      [2:0]                 M_AXI_ARPROT,
    output      [3:0]                 M_AXI_ARQOS,
    output      [0:0]                 M_AXI_ARUSER,
    output                            M_AXI_ARVALID,
    input                             M_AXI_ARREADY,
     // Master Read
    input       [3:0]                 M_AXI_RID,
    input       [DATA_WIDTH-1:0]      M_AXI_RDATA,
    input       [1:0]                 M_AXI_RRESP,
    input                             M_AXI_RLAST,
    input       [0:0]                 M_AXI_RUSER,
    input                             M_AXI_RVALID,
    output                            M_AXI_RREADY,

    input       [1:0]                 rsa_mode,
    // read axi write
    input                             start,    
    output                            wr_en0,
    output      [31:0]                din0,
    output                            wr_en1,
    output      [31:0]                din1,
    output                            wr_en2,
    output      [31:0]                din2,
    output                            wr_en3,
    output      [31:0]                din3,
    output                            wr_en4,
    output      [31:0]                din4,

    output                            fifo_full_0,
    output                            fifo_full_1,
    output                            fifo_full_2,
    output                            fifo_full_3,
    output                            fifo_full_4,

    input                             wr_start,
    input       [31:0]                rd_fifo_data ,  
    input                             rd_fifo_empty ,
    output                            rd_fifo_en                 
);
    
    // master read data store in fifo 
    reg     [31:0]          RD_ADRS             ;  //
    reg     [31:0]          RD_LENS             ;  // 
    reg                     rd_start            ;
    wire                    rd_ready            ;
    wire                    axi_rd_done         ;  //The burst read is completed
    wire                    wr_fifo_we          ;  //
    wire                    wr_fifo_full        ;  //Write enable signal for writing fifo
    wire    [31:0]          wr_fifo_data;          //Write the data read by axi to FIFO
    
    reg                     rd_start_flag0;  
    reg     [7:0]           rd_count;
    reg                     wr_en_0;
    reg     [31:0]          din_0;
    reg                     wr_en_1;
    reg     [31:0]          din_1;
    reg                     wr_en_2;
    reg     [31:0]          din_2;
    reg                     wr_en_3;
    reg     [31:0]          din_3;
    reg                     wr_en_4;
    reg     [31:0]          din_4;

    // read fifo and  axi  master write data 
    reg     [31:0]          WR_ADRS       ;  
    reg     [31:0]          WR_LENS       ;       // WR_LENS
    wire                    wr_ready           ;  // In idle state, you can initiate a write operation
    wire                    axi_wr_done        ;

    reg                     full_0;
    reg                     full_1;
    reg                     full_2;
    reg                     full_3;
    reg                     full_4;
    
    reg                     rsa_mode4096_flag;     //fifo 128 deep lentgh 
    reg                     rsa_mode2048_flag;     //fifo 64 deep lentgh     
    reg                     rsa_mode1024_flag;     //fifo 32 deep lentgh  
    reg                     rsa_mode512_flag;      //fifo 16 deep lentgh  
    
    wire     [31:0]         rd_fifo_data_in;
    
    assign    rd_fifo_data_in = wr_start == 1'b1 ? rd_fifo_data : 0;


   AXI_MASTER U_AXI_MASTER(
        .clk                (clk),
        .rstn               (rstn),
        .M_AXI_AWID         (M_AXI_AWID),
        .M_AXI_AWADDR       (M_AXI_AWADDR),
        .M_AXI_AWLEN        (M_AXI_AWLEN),  //burst length 0-255
        .M_AXI_AWSIZE       (M_AXI_AWSIZE),
        .M_AXI_AWBURST      (M_AXI_AWBURST),
        .M_AXI_AWLOCK       (M_AXI_AWLOCK),
        .M_AXI_AWCACHE      (M_AXI_AWCACHE),
        .M_AXI_AWPROT       (M_AXI_AWPROT),
        .M_AXI_AWQOS        (M_AXI_AWQOS),
        .M_AXI_AWUSER       (M_AXI_AWUSER),
        .M_AXI_AWVALID      (M_AXI_AWVALID),
        .M_AXI_AWREADY      (M_AXI_AWREADY),
         // master write data 
        .M_AXI_WDATA        (M_AXI_WDATA) ,
        .M_AXI_WSTRB        (M_AXI_WSTRB) ,
        .M_AXI_WLAST        (M_AXI_WLAST) ,
        .M_AXI_WUSER        (M_AXI_WUSER) ,
        .M_AXI_WVALID       (M_AXI_WVALID) ,
        .M_AXI_WREADY       (M_AXI_WREADY) ,
         //master write response 
        .M_AXI_BID          (M_AXI_BID),
        .M_AXI_BRESP        (M_AXI_BRESP),
        .M_AXI_BUSER        (M_AXI_BUSER),
        .M_AXI_BVALID       (M_AXI_BVALID),
        .M_AXI_BREADY       (M_AXI_BREADY),
          //master read address 
        . M_AXI_ARID        (M_AXI_ARID),
        . M_AXI_ARADDR      (M_AXI_ARADDR),
        . M_AXI_ARLEN       (M_AXI_ARLEN),
        . M_AXI_ARSIZE      (M_AXI_ARSIZE),
        . M_AXI_ARBUSRT     (M_AXI_ARBUSRT),
        . M_AXI_ARLOCK      (M_AXI_ARLOCK),
        . M_AXI_ARCACHE     (M_AXI_ARCACHE),
        . M_AXI_ARPROT      (M_AXI_ARPROT),
        . M_AXI_ARQOS       (M_AXI_ARQOS),
        . M_AXI_ARUSER      (M_AXI_ARUSER),
        . M_AXI_ARVALID     (M_AXI_ARVALID),
        . M_AXI_ARREADY     (M_AXI_ARREADY),
           // Master Read Data 
        .M_AXI_RID          (M_AXI_RID),
        .M_AXI_RDATA        (M_AXI_RDATA),
        .M_AXI_RRESP        (M_AXI_RRESP),
        .M_AXI_RLAST        (M_AXI_RLAST),
        .M_AXI_RUSER        (M_AXI_RUSER),
        .M_AXI_RVALID       (M_AXI_RVALID),
        .M_AXI_RREADY       (M_AXI_RREADY),
          // master read data store in fifo 
        .RD_ADRS            (RD_ADRS),  //
        .RD_LENS            (RD_LENS),  // 
        .rd_start           (rd_start),
        .rd_ready           (rd_ready),
        .axi_rd_done        (axi_rd_done), 		//The burst read is completed
        .wr_fifo_we         (wr_fifo_we), 		//Write enable signal for writing fifo
        .wr_fifo_full       (full_4),  			//fifo full signal, can't write anymore
        .wr_fifo_data       (wr_fifo_data),		//Write the data read by axi to FIFO
          // read fifo and  axi  master write data 
        . WR_ADRS           (WR_ADRS),  
        . WR_LENS           (WR_LENS),  		// WR_LENS
        . wr_start          (wr_start), 
        . wr_ready          (wr_ready),  		//In idle state, you can initiate a write operation
        . axi_wr_done       (axi_wr_done),
        . rd_fifo_re        ( ),		//Read enable signal for reading fifo
        . rd_fifo_empty     (rd_fifo_empty),
        . rd_fifo_data      (rd_fifo_data_in)
);      
 
//////////////////when rsa done read fifo and axi write ram ///////////////////
        reg [31:0] WR_ADRS_r;
        reg [31:0] WR_LENS_r;
        reg        rd_fifo_en_r;
        
    always@(posedge clk or negedge rstn)begin 
        if(~rstn)begin 
            WR_ADRS<=0       ;  
            WR_LENS<=0       ;       		// WR_LENS   
            WR_ADRS_r<=0      ;
            WR_LENS_r<=0      ;     
        end
        else  begin 
            if(wr_start) begin 
                WR_ADRS_r<=32'h300  ;  // Write the result uniformly at the beginning of the ram address 0- 400（0-1024）
                
                if(rsa_mode4096_flag)
                    WR_LENS_r<=32'h200   ; 
                else if(rsa_mode2048_flag)
                    WR_LENS_r<=32'h100   ;   
                else if(rsa_mode1024_flag)
                    WR_LENS_r<=32'h80   ; 
                else if(rsa_mode512_flag)
                    WR_LENS_r<=32'h40   ;         
            end 
            WR_ADRS<=WR_ADRS_r       ;  
            WR_LENS<=WR_LENS_r       ;      
         end 
    end 

    reg [7:0]       rd_fifo_cnt;
    reg             wr_start_flag;
    reg             wr_axi_start;
    wire            wr_axi_pos;
    
    always@(posedge clk or negedge rstn)begin 
        if(~rstn)
            wr_axi_start<=1'b0;
        else 
            wr_axi_start<=wr_start;                
    end 
    
    assign  wr_axi_pos= wr_start &~wr_axi_start;
    
    //rd_fifo_en  在done( wr_start) 的4拍后拉高
    assign rd_fifo_en = rd_fifo_en_r;
    
    
    always@(posedge clk or negedge rstn)begin 
        if(~rstn)
            wr_start_flag<=1'b0;
        else if(wr_axi_pos==1)
            wr_start_flag<=1;
        else if(rd_fifo_cnt==8'd19 || rd_fifo_cnt==8'd35 || rd_fifo_cnt==8'd67 ||  rd_fifo_cnt==8'd131)
            wr_start_flag<=0;         
    end 
    
    always@(posedge clk or negedge rstn)begin 
        if(~rstn)begin 
            rd_fifo_cnt<=1'b0;
            rd_fifo_en_r<=0;
        end 
        else if(wr_start_flag==1)begin 
                if(rsa_mode512_flag)begin 
                    if(rd_fifo_cnt < 8'd21)
                        rd_fifo_cnt <= rd_fifo_cnt + 1'b1;
                    else 
                        rd_fifo_cnt <= rd_fifo_cnt;
                    
                    if(rd_fifo_cnt >= 8'd4 && rd_fifo_cnt < 8'd20)
                        rd_fifo_en_r <= 1;
                     else 
                        rd_fifo_en_r <= 0;                     
                end 
                
                else if(rsa_mode1024_flag)begin 
                    if(rd_fifo_cnt <8'd37)
                        rd_fifo_cnt <= rd_fifo_cnt + 1'b1;
                    else 
                        rd_fifo_cnt <= rd_fifo_cnt;  
                    
                    if(rd_fifo_cnt >= 8'd4 && rd_fifo_cnt < 8'd36)
                         rd_fifo_en_r <= 1;
                    else 
                         rd_fifo_en_r <= 0;      
                end  
                                  
                else if(rsa_mode2048_flag)begin 
                    if(rd_fifo_cnt < 8'd69)
                        rd_fifo_cnt <= rd_fifo_cnt + 1'b1;
                    else 
                        rd_fifo_cnt <= rd_fifo_cnt;  
                    
                    if(rd_fifo_cnt >= 8'd4 && rd_fifo_cnt < 8'd68)
                        rd_fifo_en_r <= 1;
                    else 
                        rd_fifo_en_r <= 0;                                        
                end 
                
                else if(rsa_mode4096_flag)begin 
                    if(rd_fifo_cnt < 8'd133)
                        rd_fifo_cnt <= rd_fifo_cnt+1'b1;
                    else 
                        rd_fifo_cnt <= rd_fifo_cnt;  
                    
                    if(rd_fifo_cnt>=8'd4 && rd_fifo_cnt < 8'd132)
                        rd_fifo_en_r <= 1;
                    else 
                        rd_fifo_en_r <= 0;                                        
                end 
                                         
        end 
        else 
               rd_fifo_cnt <= 1'b0;
    end 


  //////////////////////axi read and write fifo ////////////////////////  
    reg             start_r ;
    wire            start_flag;
    
    always@(posedge  clk or negedge rstn)begin 
        if(~rstn)
            start_r<=1'b0;
        else 
            start_r<=start;
    end 
    
    assign start_flag   = start & ~start_r;
   

    always@(*)begin 
        case(rsa_mode)
            2'b00   :    begin   
                            rsa_mode4096_flag  <=1'b1;       
                            rsa_mode2048_flag  <=1'b0;
                            rsa_mode1024_flag  <=1'b0;        
                            rsa_mode512_flag   <=1'b0; 
                         end
            2'b01   :    begin                         
                            rsa_mode4096_flag  <=1'b0; 
                            rsa_mode2048_flag  <=1'b1; 
                            rsa_mode1024_flag  <=1'b0; 
                            rsa_mode512_flag   <=1'b0; 
                         end                           
            2'b10   :    begin                         
                            rsa_mode4096_flag  <=1'b0; 
                            rsa_mode2048_flag  <=1'b0; 
                            rsa_mode1024_flag  <=1'b1; 
                            rsa_mode512_flag   <=1'b0; 
                         end                           
            2'b11   :    begin                          
                            rsa_mode4096_flag  <=1'b0;  
                            rsa_mode2048_flag  <=1'b0;  
                            rsa_mode1024_flag  <=1'b0;  
                            rsa_mode512_flag   <=1'b1;  
                         end                             
            default:   ;  
        endcase
    end 
 
    reg         axi_rlast,axi_rlast1; 
    
    always@(posedge clk or negedge rstn )begin 
        if(~rstn)begin 
            axi_rlast   <=  1'b0;
            axi_rlast1  <=  1'b0;
        end 
        else begin 
            axi_rlast   <=  M_AXI_RLAST;
            axi_rlast1  <=  axi_rlast;
        end 
    end
    
    reg         full_0_flag,full_1_flag,full_2_flag,full_3_flag;
     // busrt read signal 
    always@(posedge clk or negedge rstn )begin 
        if(~rstn)begin 
            rd_start    <=  1'b0;
        end 
        else begin 
            if(start_flag)
                rd_start    <=  1'b1;
            else if(axi_rlast1 & ~full_1 &&  ~full_1_flag  )
                rd_start    <=  1'b1;
            else if(axi_rlast1 & ~full_2  && ~full_2_flag )
                rd_start    <=  1'b1; 
            else if(axi_rlast1 & ~full_3 &&  ~full_3_flag )
                rd_start    <=  1'b1;         
            else if(axi_rlast1 & ~full_4 )
                rd_start    <=  1'b1;        
            else if(rd_fifo_cnt==8'd19 ||rd_fifo_cnt==8'd35 ||rd_fifo_cnt==8'd67 || rd_fifo_cnt==8'd131)// write axi and read test
                rd_start    <=  1'b1; 
            else 
                rd_start    <=  1'b0; 
        end 
    end 
    
 // generate count signals    full  
    always@(posedge clk or negedge rstn)begin 
        if(~rstn)begin 
            rd_start_flag0  <=  1'b0;
            full_0  <=  1'b0;
            full_1  <=  1'b0;
            full_2  <=  1'b0;
            full_3  <=  1'b0;
            full_4  <=  1'b0;  
         end 
        else if(start_flag | (axi_rlast1 & ~full_1 && ~full_1_flag ) | (axi_rlast1 & ~full_2 &&~full_2_flag ) |(axi_rlast1 & ~full_3 &&~full_3_flag)  | (axi_rlast1 & ~full_4 ) )begin 
            rd_start_flag0  <=  1'b1;
        end 
        else begin 
            if(rsa_mode4096_flag==1'b1) begin
                 if(rd_count==8'd133  ) begin //128+3
                           rd_start_flag0  <=  1'b0;
                           full_0<=1'b1;
                           if(full_0)
                               full_1<=1'b1;
                           if(full_0 & full_1)
                               full_2<=1'b1;
                           if(full_0 & full_1 & full_2)                    
                               full_3<=1'b1;
                           if(full_0 & full_1 & full_2 & full_3)                        
                               full_4<=1'b1;  
                 end 
            end 
            else if(rsa_mode2048_flag==1'b1) begin
                if(rd_count==8'd69  ) begin //64+3
                        rd_start_flag0  <=  1'b0;
                        full_0<=1'b1;
                        if(full_0)
                            full_1<=1'b1;
                        if(full_0 & full_1)
                            full_2<=1'b1;
                        if(full_0 & full_1 & full_2)                    
                            full_3<=1'b1;
                        if(full_0 & full_1 & full_2 & full_3)                        
                            full_4<=1'b1;  
                 end    
             end   
             else if(rsa_mode1024_flag==1'b1) begin
                 if(rd_count==8'd37  )begin 
                     rd_start_flag0  <=  1'b0;
                     full_0<=1'b1;
                     if(full_0)
                        full_1<=1'b1;
                     if(full_0 & full_1)
                        full_2<=1'b1;
                     if(full_0 & full_1 & full_2)                    
                        full_3<=1'b1;
                     if(full_0 & full_1 & full_2 & full_3)                        
                        full_4<=1'b1;  
               end  
             end      
             else if(rsa_mode512_flag==1'b1) begin
                 if(rd_count==8'd21  )begin 
                      rd_start_flag0  <=  1'b0;
                      full_0<=1'b1;
                      if(full_0)
                        full_1<=1'b1;
                      if(full_0 & full_1)
                        full_2<=1'b1;
                      if(full_0 & full_1 & full_2)                    
                        full_3<=1'b1;
                      if(full_0 & full_1 & full_2 & full_3)                        
                        full_4<=1'b1;  
                end  
            end             
         end 
    end
    
    always@(posedge clk or negedge rstn)begin 
        if(~rstn)
            rd_count    <=  8'b0;
        else if(rd_start_flag0)
            rd_count    <=  rd_count+1'b1;
        else 
            rd_count    <=  8'd0;
    end

    always@(posedge clk or negedge rstn)begin 
        if(~rstn)begin 
            full_0_flag <=  1'b0;
            full_1_flag <=  1'b0;
            full_2_flag <=  1'b0;
            full_3_flag <=  1'b0;    
        end 
        else begin 
            if(full_0)
               full_0_flag  <=  1'b1;
            else if(full_4) 
               full_0_flag <=  1'b0;

            if(full_1)
               full_1_flag  <=  1'b1;           
            else if(full_4) 
                full_1_flag <=  1'b0;

            if(full_2)
               full_2_flag  <=  1'b1;        
            else if(full_4) 
                full_2_flag <=  1'b0;

            if(full_3)
               full_3_flag  <=  1'b1; 
            else if(full_4) 
                full_3_flag <=  1'b0;
             
        end 
    end
     
    always@(posedge clk or negedge rstn)begin 
        if(~rstn)begin 
            wr_en_0 <=  1'b0;
            wr_en_1 <=  1'b0;
            wr_en_2 <=  1'b0; 
            wr_en_3 <=  1'b0;
            wr_en_4 <=  1'b0;    
            din_0   <=  0;
            din_1   <=  0;
            din_2   <=  0; 
            din_3   <=  0;    
            din_4   <=  0;    
        end 
        else begin 
           if(rsa_mode4096_flag) begin
                 if(  ( rd_count>=8'd5 &  rd_count<=8'd132) & ~full_0 &~full_0_flag )begin
                    din_0    <=  wr_fifo_data;
                    wr_en_0  <=  1'b1;
                 end
                 else if( ( rd_count>=8'd5 &  rd_count<=8'd132) & ~full_1 &~full_1_flag )begin
                    din_1    <=  wr_fifo_data;
                    wr_en_1  <=  1'b1;
                 end            
                 else if(  ( rd_count>=8'd5 &  rd_count<=8'd132) & ~full_2 &~full_2_flag )begin
                    din_2    <=  wr_fifo_data;
                    wr_en_2  <=  1'b1;
                 end  
                 else if( ( rd_count>=8'd5 &  rd_count<=8'd132) & ~full_3 &~full_3_flag )begin
                    din_3    <=  wr_fifo_data;
                    wr_en_3  <=  1'b1;
                 end              
                 else if(( rd_count>=8'd5 &  rd_count<=8'd132) & ~full_4)begin
                    din_4    <=  wr_fifo_data;
                    wr_en_4  <=  1'b1;
                 end     
                 else begin 
                    din_0   <=  0;
                    din_1   <=  0;        
                    din_2   <=  0;   
                    din_3   <=  0;        
                    din_4   <=  0; 
                    wr_en_0 <=  1'b0;
                    wr_en_1 <=  1'b0;
                    wr_en_2 <=  1'b0; 
                    wr_en_3 <=  1'b0;
                    wr_en_4 <=  1'b0;                     
                end    
           end
         
           else if(rsa_mode2048_flag) begin
                if(  ( rd_count>=8'd5 &  rd_count<=8'd68) & ~full_0 &~full_0_flag )begin
                   din_0    <=  wr_fifo_data;
                   wr_en_0  <=  1'b1;
                end
                else if( ( rd_count>=8'd5 &  rd_count<=8'd68) & ~full_1 &~full_1_flag )begin
                   din_1    <=  wr_fifo_data;
                   wr_en_1  <=  1'b1;
                end            
                else if(  ( rd_count>=8'd5 &  rd_count<=8'd68) & ~full_2 &~full_2_flag )begin
                   din_2    <=  wr_fifo_data;
                   wr_en_2  <=  1'b1;
                end  
                else if( ( rd_count>=8'd5 &  rd_count<=8'd68) & ~full_3 &~full_3_flag )begin
                   din_3    <=  wr_fifo_data;
                   wr_en_3  <=  1'b1;
                end              
                 else if(( rd_count>=8'd5 &  rd_count<=8'd68) & ~full_4)begin
                   din_4    <=  wr_fifo_data;
                   wr_en_4  <=  1'b1;
                end     
                else begin 
                   din_0   <=  0;
                   din_1   <=  0;        
                   din_2   <=  0;   
                   din_3   <=  0;        
                   din_4   <=  0; 
                   wr_en_0 <=  1'b0;
                   wr_en_1 <=  1'b0;
                   wr_en_2 <=  1'b0; 
                   wr_en_3 <=  1'b0;
                   wr_en_4 <=  1'b0;                     
                 end    
            end
            
            else if(rsa_mode1024_flag)  begin          
                if(  ( rd_count>=8'd5 &  rd_count<=8'd36) & ~full_0 &~full_0_flag )begin
                   din_0    <=  wr_fifo_data;
                   wr_en_0  <=  1'b1;
                end
                else if(  ( rd_count>=8'd5 &  rd_count<=8'd36) & ~full_1 &~full_1_flag )begin
                   din_1    <=  wr_fifo_data;
                   wr_en_1  <=  1'b1;
                end            
                else if( ( rd_count>=8'd5 &  rd_count<=8'd36) & ~full_2 &~full_2_flag )begin
                   din_2    <=  wr_fifo_data;
                   wr_en_2  <=  1'b1;
                end  
                else if( ( rd_count>=8'd5 &  rd_count<=8'd36) & ~full_3 &~full_3_flag )begin
                   din_3    <=  wr_fifo_data;
                   wr_en_3  <=  1'b1;
                end              
                 else if(  ( rd_count>=8'd5 &  rd_count<=8'd36) & ~full_4)begin
                   din_4    <=  wr_fifo_data;
                   wr_en_4  <=  1'b1;
                end      
                else begin 
                   din_0   <=  0;
                   din_1   <=  0;        
                   din_2   <=  0;   
                   din_3   <=  0;        
                   din_4   <=  0; 
                   wr_en_0 <=  1'b0;
                   wr_en_1 <=  1'b0;
                   wr_en_2 <=  1'b0; 
                   wr_en_3 <=  1'b0;
                   wr_en_4 <=  1'b0;                     
                 end  
             end 
             
             else if(rsa_mode512_flag) begin 
                if( ( rd_count>=8'd5 &  rd_count<=8'd20) & ~full_0 &~full_0_flag )begin
                   din_0    <=  wr_fifo_data;
                   wr_en_0  <=  1'b1;
                end
                else if( ( rd_count>=8'd5 &  rd_count<=8'd20) & ~full_1 &~full_1_flag )begin
                   din_1    <=  wr_fifo_data;
                   wr_en_1  <=  1'b1;
                end            
                else if( ( rd_count>=8'd5 &  rd_count<=8'd20) & ~full_2 &~full_2_flag )begin
                   din_2    <=  wr_fifo_data;
                   wr_en_2  <=  1'b1;
                end  
                else if( ( rd_count>=8'd5 &  rd_count<=8'd20) & ~full_3 &~full_3_flag )begin
                   din_3    <=  wr_fifo_data;
                   wr_en_3  <=  1'b1;
                end              
                else if(  ( rd_count>=8'd5 &  rd_count<=8'd20) & ~full_4)begin
                   din_4    <=  wr_fifo_data;
                   wr_en_4  <=  1'b1;
                end                
                else begin 
                   din_0   <=  0;
                   din_1   <=  0;        
                   din_2   <=  0;   
                   din_3   <=  0;        
                   din_4   <=  0; 
                   wr_en_0 <=  1'b0;
                   wr_en_1 <=  1'b0;
                   wr_en_2 <=  1'b0; 
                   wr_en_3 <=  1'b0;
                   wr_en_4 <=  1'b0;                     
                 end  
             end 
            
          end 
    end  
    
    
    always@(posedge clk or negedge rstn)begin 
        if(~rstn)begin 
            RD_ADRS <=  32'h0;
            RD_LENS <=  32'h0;
        end 
        else if(start_flag)begin 
           if(rsa_mode4096_flag)begin 
                RD_ADRS <=  32'h0;
                RD_LENS <=  32'h200;//128*4=512 bytes           
           end         

           else if(rsa_mode2048_flag)begin 
			   RD_ADRS <=  32'h0;
			   RD_LENS <=  32'h100;//64*4=256 bytes           
           end 
           
           else if(rsa_mode1024_flag)begin 
			   RD_ADRS <=  32'h0;
			   RD_LENS <=  32'h80;//32*4=128 bytes           
           end 
           
           else if(rsa_mode512_flag)begin 
			   RD_ADRS <=  32'h0;
			   RD_LENS <=  32'h40;//16*4=64 bytes           
           end           
        end 
        else if(axi_rlast1 & ~full_1 &&~full_1_flag )begin 
            if(rsa_mode4096_flag)begin 
                RD_ADRS <=  32'h80;
                RD_LENS <=  32'h200;//128*4=512 bytes           
            end 
            else if(rsa_mode2048_flag)begin 
				RD_ADRS <=  32'h40;
				RD_LENS <=  32'h100;//64*4=256 bytes           
            end 
            else if(rsa_mode1024_flag)begin 
				RD_ADRS <=  32'h20;
				RD_LENS <=  32'h80;//32*4=128 bytes           
            end 
            else if(rsa_mode512_flag)begin 
				RD_ADRS <=  32'h10;
				RD_LENS <=  32'h40;//16*4=64 bytes           
            end  
        end 
        else if(axi_rlast1 & ~full_2 &&~full_2_flag)begin 
            if(rsa_mode4096_flag)begin 
                RD_ADRS <=  32'h100;
                RD_LENS <=  32'h200;//128*4=512 bytes
            end
            else if(rsa_mode2048_flag)begin 
				RD_ADRS <=  32'h80;
				RD_LENS <=  32'h100;//64*4=256 bytes           
            end 
            else if(rsa_mode1024_flag)begin 
				RD_ADRS <=  32'h40;
				RD_LENS <=  32'h80;//32*4=128 bytes           
            end 
            else if(rsa_mode512_flag)begin 
				RD_ADRS <=  32'h20;
				RD_LENS <=  32'h40;//16*4=64 bytes           
            end  
        end 
        else if(axi_rlast1 & ~full_3 &&~full_3_flag)begin 
        
            if(rsa_mode4096_flag)begin 
                RD_ADRS <=  32'h180;
                RD_LENS <=  32'h200;//128*4=512 bytes
            end
            else if(rsa_mode2048_flag)begin 
				RD_ADRS <=  32'hc0;
				RD_LENS <=  32'h100;//64*4=256 bytes           
            end 
            else if(rsa_mode1024_flag)begin 
				RD_ADRS <=  32'h60;
				RD_LENS <=  32'h80;//32*4=128 bytes           
            end 
            else if(rsa_mode512_flag)begin 
				RD_ADRS <=  32'h30;
				RD_LENS <=  32'h40;//16*4=64 bytes           
            end         
        
        end 
        else if(axi_rlast1 & ~full_4)begin 
            if(rsa_mode4096_flag)begin 
                RD_ADRS <=  32'h200;
                RD_LENS <=  32'h200;//128*4=512 bytes
            end
            else if(rsa_mode2048_flag)begin 
				RD_ADRS <=  32'h100;
				RD_LENS <=  32'h100;//64*4=256 bytes           
            end 
            else if(rsa_mode1024_flag)begin 
				RD_ADRS <=  32'h80;
				RD_LENS <=  32'h80;//32*4=128 bytes           
            end 
            else if(rsa_mode512_flag)begin 
				RD_ADRS <=  32'h40;
				RD_LENS <=  32'h40;//16*4=64 bytes           
            end        
        end 
        else begin 
            if(rd_fifo_cnt==8'd19 ||rd_fifo_cnt==8'd35 ||rd_fifo_cnt==8'd67 || rd_fifo_cnt==8'd131 )  begin 
                RD_ADRS <=  32'h300;
                if(rsa_mode4096_flag)begin 
                    RD_LENS <=  32'h200;//128*4=512 bytes           
                end 
                else if(rsa_mode2048_flag)begin 
                    RD_LENS <=  32'h100;//64*4=256 bytes           
                end 
                else if(rsa_mode1024_flag)begin 
                    RD_LENS <=  32'h80;//32*4=128 bytes           
                end 
                else if(rsa_mode512_flag)begin 
                    RD_LENS <=  32'h40;//16*4=64 bytes           
                end                
            end  
        end  
    end
    
    assign   wr_en0       =   wr_en_0 ;
    assign   din0         =   din_0   ;
    assign   wr_en1       =   wr_en_1 ;
    assign   din1         =   din_1   ;
    assign   wr_en2       =   wr_en_2 ;
    assign   din2         =   din_2   ;
    assign   wr_en3       =   wr_en_3 ;
    assign   din3         =   din_3   ;
    assign   wr_en4       =   wr_en_4 ;
    assign   din4         =   din_4   ;  
    
    assign   fifo_full_0  =   full_0;
    assign   fifo_full_1  =   full_1;
    assign   fifo_full_2  =   full_2;
    assign   fifo_full_3  =   full_3;
    assign   fifo_full_4  =   full_4;
    
endmodule 
