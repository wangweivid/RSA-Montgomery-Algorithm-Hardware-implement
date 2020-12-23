`timescale 1ns / 1ps
//===================================================================
// File Name	:  AXI_SLVAE.v
// Project Name	:  AXI_SLVAE 
// Create Date	:  2020/05/05
// Author		:  shaomignhe
// Description	:  AXI_SLVAE 
//				   receieve CPU or other master signal,example: seed£¬CPU modular start control;
//===================================================================


module AXI_SLAVE #(
    parameter  S_AXI_DATA_WIDTH    = 32,
    parameter  S_AXI_ADDR_WIDTH    = 12)(
    //AXI Lite
    // Global Clock Signal
    input                                     S_AXI_ACLK,
    input                                     S_AXI_ARESETN,
    input     [S_AXI_ADDR_WIDTH-1 : 0]        S_AXI_AWADDR,
    input     [2 : 0]                         S_AXI_AWPROT,
    input                                     S_AXI_AWVALID,
    output                                    S_AXI_AWREADY,
    input     [S_AXI_DATA_WIDTH-1 : 0]        S_AXI_WDATA,
    input     [(S_AXI_DATA_WIDTH/8)-1 : 0]    S_AXI_WSTRB,
    input                                     S_AXI_WVALID,
    output                                    S_AXI_WREADY,
    output    [1 : 0]                         S_AXI_BRESP,
    output                                    S_AXI_BVALID,
    input                                     S_AXI_BREADY,
    input     [S_AXI_ADDR_WIDTH-1 : 0]        S_AXI_ARADDR,
    input     [2 : 0]                         S_AXI_ARPROT,
    input                                     S_AXI_ARVALID,
    output                                    S_AXI_ARREADY,
    output    [S_AXI_DATA_WIDTH-1 : 0]        S_AXI_RDATA,
    output    [1 : 0]                         S_AXI_RRESP,
    output                                    S_AXI_RVALID,
    input                                     S_AXI_RREADY,
    output    [S_AXI_DATA_WIDTH-1:0]          CMD_register,
    input     [S_AXI_DATA_WIDTH-1:0]          STATE_register,
    output    [S_AXI_DATA_WIDTH-1:0]          soft_reset,
    output    [S_AXI_DATA_WIDTH-1:0]          random_seed,
    output    [S_AXI_DATA_WIDTH-1:0]          adjust_factor
    
);
    
    // AXI4LITE signals   
    reg       [S_AXI_ADDR_WIDTH-1 : 0]        axi_awaddr;
    reg                                       axi_awready;
    reg                                       axi_wready;
  
    reg       [1:0]                           axi_bresp;
    reg                                       axi_bvalid;
    reg       [S_AXI_ADDR_WIDTH-1 : 0]        axi_araddr;
    reg                                       axi_arready;
    reg       [S_AXI_DATA_WIDTH-1 : 0]        axi_rdata;
    reg       [1 : 0]                         axi_rresp;
    reg                                       axi_rvalid;
    
    //-- Number of Slave Registers 2   CMD_reg, Status_reg
    reg       [S_AXI_DATA_WIDTH-1:0]          cmd_reg;
    reg       [S_AXI_DATA_WIDTH-1:0]          random_seed_reg;  
    reg       [S_AXI_DATA_WIDTH-1:0]          adjust_factor_reg;          
    reg       [S_AXI_DATA_WIDTH-1:0]          soft_reset_reg;
    
    reg       [S_AXI_DATA_WIDTH-1:0]          state_reg;

    wire                                      slv_reg_rden;
    wire                                      slv_reg_wren;
    reg       [S_AXI_DATA_WIDTH-1:0]          reg_data_out;

    reg                                       aw_en; 
    reg                                       start_clr;

    assign    CMD_register   =  cmd_reg;
    
    assign    S_AXI_AWREADY  =  axi_awready;
    assign    S_AXI_WREADY   =  axi_wready;
    assign    S_AXI_BRESP    =  axi_bresp;
    assign    S_AXI_BVALID   =  axi_bvalid;
    assign    S_AXI_ARREADY  =  axi_arready;
    assign    S_AXI_RDATA    =  axi_rdata;
    assign    S_AXI_RRESP    =  axi_rresp;
    assign    S_AXI_RVALID   =  axi_rvalid;
    
    // awready  signal
    always@(posedge S_AXI_ACLK or negedge S_AXI_ARESETN  )begin 
        if(S_AXI_ARESETN==1'b0)begin 
            axi_awready <=1'b0;
            aw_en       <=1'b1;
        end 
        else begin 
            if(~axi_awready && S_AXI_AWVALID && S_AXI_WVALID &&aw_en)begin 
                axi_awready <=1'b1;
                aw_en       <=1'b0;
            end 
            else if(S_AXI_BREADY && axi_bvalid )begin      		  //master  bready pull up earlier£¬wait last data£¬slave assert bvalid 
                aw_en       <=1'b1;                               //bvalid=1 data has sent done£¬ get read to awready=1
                axi_awready <=1'b0;
            end 
            else 
                axi_awready <=1'b0;
        end
    end
     
    // S_AXI_AWVALID and S_AXI_WVALID are valid. 
    always @( posedge S_AXI_ACLK or negedge S_AXI_ARESETN  )begin
        if ( S_AXI_ARESETN == 1'b0 )
            axi_awaddr  <= 0;
        else begin    
            if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
              begin
                // Write Address latching   The address is used to address the register (generally only need to use a few bits of addressing)
                axi_awaddr  <= S_AXI_AWADDR;
              end
        end 
    end       
    
    //data  wready  signal
    always@(posedge  S_AXI_ACLK or negedge S_AXI_ARESETN )begin 
        if(S_AXI_ARESETN==1'b0)
            axi_wready      <=1'b0;
        else begin 
            if(~axi_wready && S_AXI_WVALID && S_AXI_AWVALID &&aw_en)
                axi_wready  <=1'b1;
            else 
                axi_wready  <=1'b0;
        end 
    end 
    
    // Write address and write data to ready, start addressing write register
    assign slv_reg_wren  =  axi_wready && S_AXI_WVALID &&axi_awready && S_AXI_AWVALID;
    
    // Write command register
    always@(posedge S_AXI_ACLK or negedge S_AXI_ARESETN )begin 
            if(S_AXI_ARESETN==1'b0)begin
                soft_reset_reg<=0;
                cmd_reg <=0;
                random_seed_reg<=0;
                adjust_factor_reg<=0;
             end 
            else begin 
                if(slv_reg_wren)begin 
                    if(axi_awaddr[11:0]==12'h00) 
                        soft_reset_reg <=  S_AXI_WDATA;            
                    if(axi_awaddr[11:0]==12'h0c) 
                        cmd_reg <=  S_AXI_WDATA;
                    if(axi_awaddr[11:0]==12'h08) 
                        random_seed_reg <=  S_AXI_WDATA;
                    if(axi_awaddr[11:0]==12'h04) 
                        adjust_factor_reg <=  S_AXI_WDATA;                                                                           
                end          
                if (start_clr)
                        cmd_reg[0] <=  1'b0 ;            
            end 
    end 
    
    assign    soft_reset    = soft_reset_reg;
    assign    random_seed   = random_seed_reg;
    assign    adjust_factor = adjust_factor_reg;
    
   // bresp  bvalid  signals 
    always@(posedge S_AXI_ACLK or negedge S_AXI_ARESETN )begin 
        if(S_AXI_ARESETN==1'b0)begin 
            axi_bvalid  <=  1'b0;
            axi_bresp   <=  2'b0;
        end 
        else if(axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
            begin 
                axi_bvalid  <=  1'b1;
                axi_bresp   <=  2'b0;
            end
        else if(S_AXI_BREADY && axi_bvalid)
            axi_bvalid<=1'b0;
    end 
    
    // arready  ready 
    always@(posedge S_AXI_ACLK or negedge S_AXI_ARESETN )begin 
        if(S_AXI_ARESETN==1'b0)begin 
            axi_arready <=  1'b0;
            axi_araddr  <=  32'b0;
        end 
        else if(~axi_arready && S_AXI_ARVALID)begin
            axi_arready <=  1'b1;
            axi_araddr  <=  S_AXI_ARADDR;
        end 
        else 
            axi_arready <=  1'b0;
    end 
    
    // read valid rresp signals 
    always@(posedge S_AXI_ACLK or negedge S_AXI_ARESETN )begin 
        if(S_AXI_ARESETN==1'b0)begin
            axi_rvalid  <=  1'b0;
            axi_rresp   <=  2'b0;
        end 
        else if( axi_arready && S_AXI_ARVALID && ~axi_rvalid )begin 
            axi_rvalid  <=  1'b1;
            axi_rresp   <=  2'b0;
        end 
        else if(axi_rvalid && S_AXI_RREADY)
            axi_rvalid  <=  1'b0;
    end 
    
    assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid ;
    
    always@(posedge S_AXI_ACLK or negedge S_AXI_ARESETN ) begin 
        if(S_AXI_ARESETN==1'b0)
            reg_data_out <=  0;
        else if(axi_araddr[11:0]==12'h024)
            reg_data_out <= cmd_reg;
        else if(axi_araddr[11:0]==12'h028)
            reg_data_out <= state_reg;
    end 
    
    always@(posedge S_AXI_ACLK or negedge S_AXI_ARESETN ) begin 
        if(S_AXI_ARESETN==1'b0)
            axi_rdata   <=  0;
        else if(slv_reg_rden)
            axi_rdata   <=  reg_data_out;
    end 
    
    reg  cmd_reg_r;
    
    always@(posedge S_AXI_ACLK or negedge S_AXI_ARESETN)begin
        if(S_AXI_ARESETN==1'b0)
            cmd_reg_r<=1'b0;
        else 
            cmd_reg_r<=cmd_reg[0];
    end 
    
    always@(posedge S_AXI_ACLK or negedge S_AXI_ARESETN   ) begin
        if(S_AXI_ARESETN==1'b0)begin 
            start_clr   <=  1'b0;
            state_reg   <=  32'h0;
        end 
        else  begin 
            if(cmd_reg_r==1'b1)
            start_clr   <=  1'b1;
            else 
            start_clr   <=  1'b0;
            
            state_reg   <=  STATE_register;
        end 
    end
    
endmodule
