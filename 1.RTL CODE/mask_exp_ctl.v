`timescale 1ns / 1ps

//===================================================================
// File Name	:  mask_exp_ctl.v
// Project Name	:  mask_exp_ctl 
// Create Date	:  2020/05/05
// Author		:  wangwei
// Description	:  mask_exp_ctl modules
//                 expoen mask for Resistance to test channel attacks
//===================================================================

module mask_exp_ctl(
    clk,
    rstn,
    
    mode,               //rsa_config_mode
    Seed,               //random seed
    Phi_N,              //Euler function from RAM
    Ei,                 //source expoen from RAM
    
    Eepon_o,            //read exponent [31:0] data
    Rd_en_phi,          //read Euler function from EXIT FIFO
    Rd_en_Ei,           //read source expoen from EXIT FIFO
    
    Rd_en_expon,        //read expoent_FIFO 
    
    full_phi_N,         //phi_FIFO full ctl signal
    full_Ei,            //Ei_FIFO full ctl signal
    Phi_empty,          //phi_FIFO empty ctl signal
    Ei_empty            //Ei_FIFO empty ctl signal
);
    
    input                   clk;
    input                   rstn;
    
    input    [1:0]          mode;
    input    [15:0]         Seed;
    input    [31:0]         Phi_N;
    input    [31:0]         Ei;
    
    input                   full_phi_N;
    input                   full_Ei;
        
    output   [31:0]         Eepon_o;
    output                  Rd_en_phi;
    output                  Rd_en_Ei;
    
    input                   Rd_en_expon;
    
    input                   Phi_empty;
    input                   Ei_empty ;
    
    wire     [15:0]         Random_A;
    wire                    Wr_en_data;
    wire                    full_expo;
    wire                    enable;
    wire     [31:0]         E_o;
    reg                     full_exp;
    wire     [31:0]         Phi_N_mux,Ei_mux;
    
    assign    enable    =  full_phi_N & full_Ei;
    assign   Phi_N_mux  =  (enable & ~Phi_empty)  ? Phi_N : 0 ;
    assign   Ei_mux     =  (enable & ~Ei_empty)   ? Ei    : 0 ;
    
    lsfr_random_gen_16  U_lsfr_random_gen_16(
        .Clk        (clk        ),
        .Reset      (rstn       ),    
        .Enable     (enable     ),
        .Start      (1'b1       ),
        .Seed       (Seed       ),
        .LFSR_o     (Random_A   )  
    ); 
    
    
    mask_expon_gen      U_mask_expon_gen (
        .Clk        (clk        ),
        .Rstn       (rstn       ),
        .Enable     (enable     ),
        .Phi_N      (Phi_N_mux  ),
        .Ei         (Ei_mux     ),
        .Random_A   (Random_A   ),
        .E_o        (E_o        ),
        .Rd_en_phi  (Rd_en_phi  ),
        .Rd_en_Ei   (Rd_en_Ei   ),
        .Wr_en_data (Wr_en_data ),
        .Phi_empty  (Phi_empty  ),
        .Ei_empty   (Ei_empty   ),
        .full_expo  (full_exp   )
    );
    
   wire  [7:0]    fifo_cnt;
   //wire  [6:0]    fifo_cnt1;

   sync_fifo # (.FIFO_WIDTH (32),.FIFO_DEPTH(129) ) U_sync_fifo_expon(
         .clk       (clk            ),
         .rst_n     (rstn           ),
         .buf_in    (E_o            ),
         .buf_out   (Eepon_o        ),
         .wr_en     (Wr_en_data     ),
         .rd_en     (Rd_en_expon    ),
         .buf_empty (               ),
         .buf_full  (               ),
         .fifo_cnt  (fifo_cnt       )
    );
    
    
    always @(posedge clk or negedge rstn) begin
           if (! rstn)
                full_exp <= 0;
           else if (Rd_en_expon == 1'b1)
                full_exp <= 0;
           else begin
                if (mode == 2'b00) begin
                   if (fifo_cnt == 8'd127)
                       full_exp <= 1'b1;
                end
                if (mode == 2'b01) begin
                    if (fifo_cnt == 8'd63)
                        full_exp <= 1'b1;
                end
                if (mode == 2'b10) begin
                    if (fifo_cnt == 8'd31)
                        full_exp <= 1'b1;
                end
                if (mode == 2'b11) begin
                    if (fifo_cnt == 8'd15)
                        full_exp <= 1'b1;
                end
           end
    end
    
endmodule
