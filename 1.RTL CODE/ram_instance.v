`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: shaomignhe
// 
// Create Date: 2020/08/04 14:16:36
// Module Name: axi_ram_slave
// Project Name: 
// Description: 
// 
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ram_instance  #(parameter DATA_WIDTH =32 , ADDR_WIDTH=10,DEEP_LENGTH=1024 ) 
(
		input       clk  ,
		input       rstn,
		input       wea  ,    // write enable 
		input   [ADDR_WIDTH-1:0] 	addra,  // input data address   [9:0]
		input 	[DATA_WIDTH-1:0]	dina ,  // input write data 	[31:0]
		input   [ADDR_WIDTH-1:0]    addrb,  // read data address 
		output  [DATA_WIDTH-1:0]    doutb   // read data 
);
reg [DATA_WIDTH-1:0] bram [0:DEEP_LENGTH-1] ;

reg [DATA_WIDTH-1:0] reg_doutb;

// can't use  \  \  \ .txt  only  use  /  /  /  .txt  

//initial begin

// $readmemh("D:/1_Project/5_RSA/4_project_vivado/RSA_radix16/RSA_HUAWEI_1/RSA_HUAWEI.srcs/sources_1/ram_initial/ram_4096.txt", bram);
//end

    always@(posedge clk or negedge rstn )begin 
        if(!rstn) 
            reg_doutb <=0;
        else if(!wea)
            reg_doutb <=bram[addrb];
    end 

    always@(posedge clk  )begin 
        if(wea)
            bram[addra]<=dina;
    end 


assign doutb    =   reg_doutb;

endmodule 

