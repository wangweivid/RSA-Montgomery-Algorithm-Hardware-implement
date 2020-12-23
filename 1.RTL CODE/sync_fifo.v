`timescale 1ns / 1ps

//===================================================================
// File Name	:  sync_fifo.v
// Project Name	:  sync_fifo
// Create Date	:  2020/05/05
// Author		:  wangwei
// Description	:  sync_fifo   fifo for exponent A fifo controller verilog description.
// 
//===================================================================

`include "/nfs54/project/spiderman/wangwei5/workspace/rsa/code_base16_0805/rtl/parameter.v"

module sync_fifo # (parameter FIFO_WIDTH = 32,FIFO_DEPTH = 64 )(
     clk,
     rst_n,
     buf_in,                    //data in [31:0]
     buf_out,
     wr_en,
     rd_en,
     buf_empty,
     buf_full,
     fifo_cnt
 );
 
	input                              clk,rst_n;
	input                              wr_en,rd_en;
	input          [FIFO_WIDTH-1:0]    buf_in;                     // data input to be pushed to buffer
	
	output reg     [FIFO_WIDTH-1:0]    buf_out ;                   // port to output the data using pop.
	output wire                        buf_empty,buf_full;         // buffer empty and full indication 	
	output reg     [7:0]               fifo_cnt;                   // number of data pushed in to buffer  
	                                               
	
	reg        [FIFO_WIDTH-2:0]        rd_ptr,wr_ptr;  
	//reg        [FIFO_WIDTH-1:0]        buf_mem[0:FIFO_DEPTH-1] ;
	(*ram_style = "block"*) reg [FIFO_WIDTH - 1 : 0] buf_mem[0 : FIFO_DEPTH - 1];
	
	assign     buf_empty = (fifo_cnt == 0);  
	assign     buf_full  = (fifo_cnt == FIFO_DEPTH+ 1);
	
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)
			fifo_cnt <= 0;
		else if((!buf_full&&wr_en)&&(!buf_empty&&rd_en)) //同时读写，数量不变
			fifo_cnt <= fifo_cnt;
		else if(!buf_full && wr_en)          //write
			fifo_cnt <= fifo_cnt + 1;
		else if(!buf_empty && rd_en)         //read
			fifo_cnt <= fifo_cnt-1;
		else 
			fifo_cnt <= fifo_cnt;
	end
	
	//read
	always @(posedge clk or negedge rst_n) begin   
		if(!rst_n)
			buf_out <= 0;
		else if(rd_en && !buf_empty)
			buf_out <= buf_mem[rd_ptr];
	end
	
	 //write
	always @(posedge clk) begin
		if(wr_en && !buf_full)
			buf_mem[wr_ptr] <= buf_in;
	end
	
	// ptr for read/write 
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			wr_ptr <= 0;
		end
		else begin 
			if(!buf_full && wr_en)
				wr_ptr <= wr_ptr + 1;	
			else if (buf_full)
			    wr_ptr <= 0;  
			else if (!buf_empty & rd_en) 
			    wr_ptr <= wr_ptr - 1;	
		end
	end
	
	always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            rd_ptr <= 0;
        end
        else begin    
            if(!buf_empty && rd_en)
                rd_ptr <= rd_ptr + 1;
            else if (buf_empty)
                rd_ptr <= 0;
        end
    end
endmodule 
