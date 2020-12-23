`timescale 1ns / 1ps

//===================================================================
// File Name	:  multi_Xi_Y0_decoder.v
// Project Name	:  multi_Xi_Y0_decoder 
// Create Date	:  2020/05/05
// Author		:  wangwei
// Description	:  multi_Xi_Y0_decoder
//                 Xi DECODE CTL FOR EACH 10 M.M 
//===================================================================


module multi_Xi_Y0_decoder(
    input                       clk,
    input                       rstn,
   
    input                       start,                  //start encode
    input                       valid,                  //decoder data valid 
    input           [3:0]       multi_Xi_Y0_encode,     //decoder address
                    
    input           [15:0]      mult_Xi_Y0,             //input [15:0] multiliy result 
    input           [15:0]      X_j,                    //input [15:0] MM module  X 
    
    output      reg [15:0]      Xi_0,                   //ouput [15:0] MM module decoder for X
    output      reg [15:0]      Xi_1,
    output      reg [15:0]      Xi_2,
    output      reg [15:0]      Xi_3,
    output      reg [15:0]      Xi_4,
    output      reg [15:0]      Xi_5,
    output      reg [15:0]      Xi_6,
    output      reg [15:0]      Xi_7,
    output      reg [15:0]      Xi_8,
    output      reg [15:0]      Xi_9,
                
    output      reg [15:0]      multi_X_Y_0,            //ouput [15:0] MM module decoder for Xi*Y0
    output      reg [15:0]      multi_X_Y_1,
    output      reg [15:0]      multi_X_Y_2,
    output      reg [15:0]      multi_X_Y_3,
    output      reg [15:0]      multi_X_Y_4,
    output      reg [15:0]      multi_X_Y_5,
    output      reg [15:0]      multi_X_Y_6,
    output      reg [15:0]      multi_X_Y_7,
    output      reg [15:0]      multi_X_Y_8,
    output      reg [15:0]      multi_X_Y_9,
                
    output      reg             csa_flag_0,             //ouput flag for MM module 
    output      reg             csa_flag_1,
    output      reg             csa_flag_2,
    output      reg             csa_flag_3,
    output      reg             csa_flag_4,
    output      reg             csa_flag_5,
    output      reg             csa_flag_6,
    output      reg             csa_flag_7,
    output      reg             csa_flag_8,
    output      reg             csa_flag_9
    
    );
    
    
    //input for X0*Y0
    always @(posedge clk or negedge rstn) begin
          if (! rstn)   begin
               multi_X_Y_0  <=  0;
               csa_flag_0   <=  0;
               Xi_0         <=  0;
          end
          else if (start == 1'b1 & multi_Xi_Y0_encode == 4'b0000 & (~valid)) begin
               multi_X_Y_0  <=  mult_Xi_Y0;
               csa_flag_0   <=  1'b1;
               Xi_0         <=  X_j;
          end
          else begin
               multi_X_Y_0  <=  multi_X_Y_0; 
               csa_flag_0   <=  0;
               Xi_0         <=  Xi_0;
          end
    end
    
    //input for X1*Y0
    always @(posedge clk or negedge rstn) begin
          if (! rstn)   begin
               multi_X_Y_1  <=  0;
               csa_flag_1   <=  0;
               Xi_1         <=  0;
          end
          else if (multi_Xi_Y0_encode == 4'b0001 & (~valid)) begin
               multi_X_Y_1  <=  mult_Xi_Y0;
               csa_flag_1   <=  1'b1;
               Xi_1         <=  X_j;
          end
          else  begin
               multi_X_Y_1  <=  multi_X_Y_1;
               csa_flag_1   <=  0;   
               Xi_1         <=  Xi_1; 
          end     
    end
    
    //input for X2*Y0
    always @(posedge clk or negedge rstn) begin
          if (! rstn)  begin
               multi_X_Y_2  <=  0;
               csa_flag_2   <=  0;
               Xi_2         <=  0;
          end
          else if (multi_Xi_Y0_encode == 4'b0010 & (~valid)) begin
               multi_X_Y_2  <=  mult_Xi_Y0;
               csa_flag_2   <=  1'b1;      
               Xi_2         <=  X_j;
          end
          else begin
               multi_X_Y_2  <=  multi_X_Y_2; 
               csa_flag_2   <=  0;   
               Xi_2         <=  Xi_2;
          end
    end
    
    //input for X3*Y0
    always @(posedge clk or negedge rstn) begin
          if (! rstn)  begin
               multi_X_Y_3  <=  0;
               csa_flag_3   <=  0;
               Xi_3         <=  0;
          end
          else if (multi_Xi_Y0_encode == 4'b0011 & (~valid)) begin
               multi_X_Y_3  <=  mult_Xi_Y0;
               csa_flag_3   <=  1'b1;      
               Xi_3         <=  X_j;
          end
          else begin
               multi_X_Y_3  <=  multi_X_Y_3; 
               csa_flag_3   <=  0;   
               Xi_3         <=  Xi_3;
          end
    end
    
    //input for X4*Y0
    always @(posedge clk or negedge rstn) begin
          if (! rstn)  begin
               multi_X_Y_4  <=  0;
               csa_flag_4   <=  0;
               Xi_4         <=  0;
          end
          else if (multi_Xi_Y0_encode == 4'b0100 & (~valid)) begin
               multi_X_Y_4  <=  mult_Xi_Y0;
               csa_flag_4   <=  1'b1;      
               Xi_4         <=  X_j;
          end
          else begin
               multi_X_Y_4  <=  multi_X_Y_4; 
               csa_flag_4   <=  0;   
               Xi_4         <=  Xi_4;         
          end
    end
    
    //input for X5*Y0
    always @(posedge clk or negedge rstn) begin
          if (! rstn)  begin
               multi_X_Y_5  <=  0;
               csa_flag_5   <=  0;
               Xi_5         <=  0;
          end
          else if (multi_Xi_Y0_encode == 4'b0101 & (~valid)) begin
               multi_X_Y_5  <=  mult_Xi_Y0;
               csa_flag_5   <=  1'b1;      
               Xi_5         <=  X_j;      
          end
          else begin
               multi_X_Y_5  <=  multi_X_Y_5; 
               csa_flag_5   <=  0;   
               Xi_5         <=  Xi_5;   
          end
    end

    //input for X5*Y0
    always @(posedge clk or negedge rstn) begin
          if (! rstn)  begin
               multi_X_Y_6  <=  0;
               csa_flag_6   <=  0;
               Xi_6         <=  0;
          end
          else if (multi_Xi_Y0_encode == 4'b0110 & (~valid)) begin
               multi_X_Y_6  <=  mult_Xi_Y0;
               csa_flag_6   <=  1'b1;      
               Xi_6         <=  X_j;      
          end
          else begin
               multi_X_Y_6  <=  multi_X_Y_6; 
               csa_flag_6   <=  0;   
               Xi_6         <=  Xi_6;   
          end
    end

    //input for X5*Y0
    always @(posedge clk or negedge rstn) begin
          if (! rstn)  begin
               multi_X_Y_7  <=  0;
               csa_flag_7   <=  0;
               Xi_7         <=  0;
          end
          else if (multi_Xi_Y0_encode == 4'b0111 & (~valid)) begin
               multi_X_Y_7  <=  mult_Xi_Y0;
               csa_flag_7   <=  1'b1;      
               Xi_7         <=  X_j;      
          end
          else begin
               multi_X_Y_7  <=  multi_X_Y_7; 
               csa_flag_7   <=  0;   
               Xi_7         <=  Xi_7;   
          end
    end
    
    
      //input for X5*Y0
    always @(posedge clk or negedge rstn) begin
          if (! rstn)  begin
               multi_X_Y_8  <=  0;
               csa_flag_8   <=  0;
               Xi_8         <=  0;
          end
          else if (multi_Xi_Y0_encode == 4'b1000 & (~valid)) begin
               multi_X_Y_8  <=  mult_Xi_Y0;
               csa_flag_8   <=  1'b1;      
               Xi_8         <=  X_j;      
          end
          else begin
               multi_X_Y_8  <=  multi_X_Y_8; 
               csa_flag_8   <=  0;   
               Xi_8         <=  Xi_8;   
          end
    end
    
     //input for X5*Y0
    always @(posedge clk or negedge rstn) begin
          if (! rstn)  begin
               multi_X_Y_9  <=  0;
               csa_flag_9   <=  0;
               Xi_9         <=  0;
          end
          else if (multi_Xi_Y0_encode == 4'b1001 & (~valid)) begin
               multi_X_Y_9  <=  mult_Xi_Y0;
               csa_flag_9   <=  1'b1;      
               Xi_9         <=  X_j;      
          end
          else begin
               multi_X_Y_9  <=  multi_X_Y_9; 
               csa_flag_9   <=  0;   
               Xi_9         <=  Xi_9;   
          end
    end      
    
endmodule
