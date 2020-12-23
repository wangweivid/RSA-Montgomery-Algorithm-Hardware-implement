`timescale 1ns / 1ps

//===================================================================
// File Name	:  booth_32_16_wrapper.v
// Project Name	:  booth_32_16_wrapper 
// Create Date	:  2020/05/05
// Author		:  wangwei
// Description	:  32bits * 16 bits modules
//                 multiplier[15:0] for booth encode;
//                 multiplicand[31:0] for partial product 
//===================================================================

//32bits * 16 bits modules
module booth_32_16_wrapper #(parameter WIDTH = 32)(
    clk,
    rstn,
    multiplier,
    multiplicand,
    Sum_1,
    Sum_2
    );

    input                                     clk;
    input                                     rstn;
    input        [15:0]                       multiplier;         //16bits
    input        [WIDTH-1:0]                  multiplicand;       //32bits

    output       [WIDTH-1:0]                  Sum_1;
    output       [WIDTH-1:0]                  Sum_2;
   
    wire         [WIDTH-1:0]                 Carry_low;
    wire         [WIDTH-1:0]                 Carry_high;
    wire         [WIDTH-1:0]                 Sum_low;
    wire         [WIDTH-1:0]                 Sum_high;
       
    reg          [31:0]                       reg_multiplicand;
    reg          [15:0]                       reg_multiplier;
    reg          [15:0]                       reg_multiplicand_comp_low;
    reg          [15:0]                       reg_multiplicand_comp_high;
    
    //compliment
    always @(posedge clk or negedge rstn) begin                     //Complementary code generate
            if (! rstn) begin
               reg_multiplier                   <=  0; 
               reg_multiplicand                 <=  0;
               reg_multiplicand_comp_low        <=  0;
               reg_multiplicand_comp_high       <=  0;
            end
            else begin
               reg_multiplier                   <=  multiplier;
               reg_multiplicand                 <=  multiplicand;
               reg_multiplicand_comp_low        <=  ~multiplicand[15:0]  + 1'b1;
               reg_multiplicand_comp_high       <=  ~multiplicand[31:16] + 1'b1;
            end
    end  
    
    wire         [16:0]                       multiplicand_comp_low_ext;
    wire         [16:0]                       multiplicand_comp_high_ext;
    wire         [16:0]                       multiplicand_ext_low;                  //17bits 
    wire         [16:0]                       multiplicand_ext_high;                 //17bits
    wire         [18:0]                       multi_ext; 
    
    assign  multiplicand_comp_low_ext       = {1'b1,reg_multiplicand_comp_low};       //low compliment 17bits
    assign  multiplicand_comp_high_ext      = {1'b1,reg_multiplicand_comp_high};      //high compliment 17bits
    
    assign  multiplicand_ext_low            = {1'b0, reg_multiplicand[15:0] };        //low source 17bits
    assign  multiplicand_ext_high           = {1'b0, reg_multiplicand[31:16] };       //high source 17bits
 
    assign  multi_ext                       = {2'b0,reg_multiplier,1'b0};             //extension
    
    reg          [17:0]                      P0_low,P1_low,P2_low,P3_low,P4_low,P5_low,P6_low,P7_low,P8_low;
    reg          [17:0]                      P0_high,P1_high,P2_high,P3_high,P4_high,P5_high,P6_high,P7_high,P8_high;
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    always@(posedge clk or negedge rstn )begin               //booth_wrapper encode for multiplicand                          
       if (! rstn ) begin
               P0_low     <=0;
               P1_low     <=0;
               P2_low     <=0;
               P3_low     <=0;
               P4_low     <=0;
               P5_low     <=0;
               P6_low     <=0;
               P7_low     <=0;
               P8_low     <=0;              
               P0_high    <=0;
               P1_high    <=0;
               P2_high    <=0;
               P3_high    <=0;
               P4_high    <=0;
               P5_high    <=0;
               P6_high    <=0;
               P7_high    <=0;
               P8_high    <=0; 
        end
        else begin
        //1st
        case(multi_ext[2:0] )
            3'b000:             begin 
                                    P0_low   <=  0;                                  // zero
                                    P0_high  <=  0;
                                end
            3'b010:             begin 
                                    P0_low   <=  {1'b0,multiplicand_ext_low};
                                    P0_high  <=  {1'b0,multiplicand_ext_high};
                                end
            3'b100:             begin 
                                    P0_low   <=  {multiplicand_comp_low_ext,1'b0};   // sub multi & shift left  1 bit
                                    P0_high  <=  {multiplicand_comp_high_ext,1'b0};
                                end
            3'b110:             begin
                                    P0_low   <=  {1'b1,multiplicand_comp_low_ext};
                                    P0_high  <=  {1'b1,multiplicand_comp_high_ext};
                                end 
            default:            begin 
                                    P0_low   <=  0;                      // zero
                                    P0_high  <=  0;
                                end                           
        endcase
  
        //2nd
        case(multi_ext[4:2] )
            3'b000,3'b111:      begin 
                                        P1_low   <=  0;                 // zero
                                        P1_high  <=  0;
                                end      
            3'b001,3'b010:      begin    
                                        P1_low   <=  {1'b0,multiplicand_ext_low};
                                        P1_high  <=  {1'b0,multiplicand_ext_high};
                                end      
            3'b011:             begin    
                                        P1_low   <=  {multiplicand_ext_low,1'b0};        // add multi & shift left  1 bit
                                        P1_high  <=  {multiplicand_ext_high,1'b0};
                                end      
            3'b100:             begin    
                                        P1_low   <=  {multiplicand_comp_low_ext,1'b0};   // sub multi & shift left  1 bit
                                        P1_high  <=  {multiplicand_comp_high_ext,1'b0};
                                end      
            3'b101,3'b110:      begin    
                                        P1_low   <=  {1'b1,multiplicand_comp_low_ext};
                                        P1_high  <=  {1'b1,multiplicand_comp_high_ext};
                                end            
        endcase
        
         //3rd
        case(multi_ext[6:4] )
            3'b000,3'b111:      begin 
                                        P2_low   <=  0;                 // zero
                                        P2_high  <=  0;
                                end      
            3'b001,3'b010:      begin    
                                        P2_low   <=  {1'b0,multiplicand_ext_low};
                                        P2_high  <=  {1'b0,multiplicand_ext_high};
                                end      
            3'b011:             begin    
                                        P2_low   <=  {multiplicand_ext_low,1'b0};        // add multi & shift left  1 bit
                                        P2_high  <=  {multiplicand_ext_high,1'b0};
                                end      
            3'b100:             begin    
                                        P2_low   <=  {multiplicand_comp_low_ext,1'b0};   // sub multi & shift left  1 bit
                                        P2_high  <=  {multiplicand_comp_high_ext,1'b0};
                                end      
            3'b101,3'b110:      begin    
                                        P2_low   <=  {1'b1,multiplicand_comp_low_ext};
                                        P2_high  <=  {1'b1,multiplicand_comp_high_ext};
                                end            
        endcase
        
        //4th
        case(multi_ext[8:6] )
            3'b000,3'b111:      begin 
                                        P3_low   <=  0;                 // zero
                                        P3_high  <=  0;
                                end      
            3'b001,3'b010:      begin    
                                        P3_low   <=  {1'b0,multiplicand_ext_low};
                                        P3_high  <=  {1'b0,multiplicand_ext_high};
                                end      
            3'b011:             begin    
                                        P3_low   <=  {multiplicand_ext_low,1'b0};        // add multi & shift left  1 bit
                                        P3_high  <=  {multiplicand_ext_high,1'b0};
                                end      
            3'b100:             begin    
                                        P3_low   <=  {multiplicand_comp_low_ext,1'b0};   // sub multi & shift left  1 bit
                                        P3_high  <=  {multiplicand_comp_high_ext,1'b0};
                                end      
            3'b101,3'b110:      begin    
                                        P3_low   <=  {1'b1,multiplicand_comp_low_ext};
                                        P3_high  <=  {1'b1,multiplicand_comp_high_ext};
                                end            
        endcase
        
        //5th
        case(multi_ext[10:8] )
            3'b000,3'b111:      begin 
                                        P4_low   <=  0;                 // zero
                                        P4_high  <=  0;
                                end      
            3'b001,3'b010:      begin    
                                        P4_low   <=  {1'b0,multiplicand_ext_low};
                                        P4_high  <=  {1'b0,multiplicand_ext_high};
                                end      
            3'b011:             begin    
                                        P4_low   <=  {multiplicand_ext_low,1'b0};        // add multi & shift left  1 bit
                                        P4_high  <=  {multiplicand_ext_high,1'b0};
                                end      
            3'b100:             begin    
                                        P4_low   <=  {multiplicand_comp_low_ext,1'b0};   // sub multi & shift left  1 bit
                                        P4_high  <=  {multiplicand_comp_high_ext,1'b0};
                                end      
            3'b101,3'b110:      begin    
                                        P4_low   <=  {1'b1,multiplicand_comp_low_ext};
                                        P4_high  <=  {1'b1,multiplicand_comp_high_ext};
                                end            
        endcase
        
        
        //6th
        case(multi_ext[12:10] )
            3'b000,3'b111:      begin
                                        P5_low   <=  0;                 // zero
                                        P5_high  <=  0;
                                end     
            3'b001,3'b010:      begin   
                                        P5_low   <=  {1'b0,multiplicand_ext_low};
                                        P5_high  <=  {1'b0,multiplicand_ext_high};
                                end     
            3'b011:             begin   
                                        P5_low   <=  {multiplicand_ext_low,1'b0};        // add multi & shift left  1 bit
                                        P5_high  <=  {multiplicand_ext_high,1'b0};
                                end     
            3'b100:             begin   
                                        P5_low   <=  {multiplicand_comp_low_ext,1'b0};   // sub multi & shift left  1 bit
                                        P5_high  <=  {multiplicand_comp_high_ext,1'b0};
                                end     
            3'b101,3'b110:      begin   
                                        P5_low   <=  {1'b1,multiplicand_comp_low_ext};
                                        P5_high  <=  {1'b1,multiplicand_comp_high_ext};
                                end           
        endcase
       
        //7t
        case(multi_ext[14:12] )
            3'b000,3'b111:      begin
                                        P6_low   <=  0;                 // zero
                                        P6_high  <=  0;
                                end      
            3'b001,3'b010:      begin    
                                        P6_low   <=  {1'b0,multiplicand_ext_low};
                                        P6_high  <=  {1'b0,multiplicand_ext_high};
                                end      
            3'b011:             begin    
                                        P6_low   <=  {multiplicand_ext_low,1'b0};        // add multi & shift left  1 bit
                                        P6_high  <=  {multiplicand_ext_high,1'b0};
                                end      
            3'b100:             begin    
                                        P6_low   <=  {multiplicand_comp_low_ext,1'b0};   // sub multi & shift left  1 bit
                                        P6_high  <=  {multiplicand_comp_high_ext,1'b0};
                                end      
            3'b101,3'b110:      begin    
                                        P6_low   <=  {1'b1,multiplicand_comp_low_ext};
                                        P6_high  <=  {1'b1,multiplicand_comp_high_ext};
                                end            
        endcase
        
        //8th
        case(multi_ext[16:14] )
            3'b000,3'b111:      begin 
                                        P7_low   <=  0;                 // zero
                                        P7_high  <=  0;
                                end      
            3'b001,3'b010:      begin    
                                        P7_low   <=  {1'b0,multiplicand_ext_low};
                                        P7_high  <=  {1'b0,multiplicand_ext_high};
                                end      
            3'b011:             begin    
                                        P7_low   <=  {multiplicand_ext_low,1'b0};        // add multi & shift left  1 bit
                                        P7_high  <=  {multiplicand_ext_high,1'b0};
                                end      
            3'b100:             begin    
                                        P7_low   <=  {multiplicand_comp_low_ext,1'b0};   // sub multi & shift left  1 bit
                                        P7_high  <=  {multiplicand_comp_high_ext,1'b0};
                                end      
            3'b101,3'b110:      begin    
                                        P7_low   <=  {1'b1,multiplicand_comp_low_ext};
                                        P7_high  <=  {1'b1,multiplicand_comp_high_ext};
                                end            
        endcase
        
        //9th
        case(multi_ext[18:16] )
            3'b000:      begin 
                                        P8_low   <=  0;                 // zero
                                        P8_high  <=  0;
                                end      
            3'b001:      begin    
                                        P8_low   <=  {1'b0,multiplicand_ext_low};
                                        P8_high  <=  {1'b0,multiplicand_ext_high};
                                end      
            default:            begin 
                                        P8_low   <=  0;                 // zero
                                        P8_high  <=  0;
                                end                                  
        endcase
        end
    end 
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    //wire         [(18*9)-1:0]                 result_low;
    //wire         [(18*9)-1:0]                 result_high;
    wire         [6:0]                        ptl_sign;    
    
    //wire          [161:0]                      reg_partial_low;
    //wire          [161:0]                      reg_partial_high;
    
    reg          [6:0]                        reg_ptl_sign_low;
    reg          [6:0]                        reg_ptl_sign_high;

    wire                                      zero_flag1,zero_flag2;

    //partial_sign for 0-6th encode
    assign      ptl_sign[0]    =       multi_ext[2]  & (~(multi_ext[1]  & multi_ext[0] ));
    assign      ptl_sign[1]    =       multi_ext[4]  & (~(multi_ext[3]  & multi_ext[2] ));
    assign      ptl_sign[2]    =       multi_ext[6]  & (~(multi_ext[5]  & multi_ext[4] ));
    assign      ptl_sign[3]    =       multi_ext[8]  & (~(multi_ext[7]  & multi_ext[6] ));
    assign      ptl_sign[4]    =       multi_ext[10] & (~(multi_ext[9]  & multi_ext[8] ));
    assign      ptl_sign[5]    =       multi_ext[12] & (~(multi_ext[11] & multi_ext[10]));
    assign      ptl_sign[6]    =       multi_ext[14] & (~(multi_ext[13] & multi_ext[12]));
    
    //if multiplican == 0, then not encode for multi
    assign      zero_flag1     =      (reg_multiplicand[15: 0] == 16'b0) ? 1'b0 : 1'b1;         //multiplicand == 0 flag for low 
    assign      zero_flag2     =      (reg_multiplicand[31:16] == 16'b0) ? 1'b0 : 1'b1;         //multiplicand == 0 flag for high
    
    reg     flag1_r,flag2_r;
    always @(posedge clk or negedge rstn) begin         
         if (! rstn) begin
            flag1_r <= 0;
            flag2_r <= 0;
         end
         else begin
            flag1_r <= zero_flag1;
            flag2_r <= zero_flag2;
         end
    end
      
     always @(posedge clk or negedge rstn) begin        //zero flag for partial sign zero / 
         if (! rstn) begin
            reg_ptl_sign_low            <=  0; 
            reg_ptl_sign_high           <=  0; 
         end   
         else begin 
            if (zero_flag1 == 1'b0) 
                reg_ptl_sign_low        <=  0;
            else
                reg_ptl_sign_low        <=  ptl_sign;
                
            if (zero_flag2 == 1'b0) 
                reg_ptl_sign_high       <=  0;
            else
                reg_ptl_sign_high       <=  ptl_sign;
         end       
    end
 
    //CSA 9:2 for multiplier low 
    CSA9_2 #(.DATA_WIDTH (16) ) u_CSA9_2_low (
        .clk            (clk                ), 
        .rstn           (rstn               ), 
        .data_0         (P0_low             ),   
        .data_1         (P1_low             ),   
        .data_2         (P2_low             ),   
        .data_3         (P3_low             ),   
        .data_4         (P4_low             ),   
        .data_5         (P5_low             ),   
        .data_6         (P6_low             ),   
        .data_7         (P7_low             ),   
        .data_8         (P8_low             ),   
        .flag_zero      (flag1_r            ),
        .shift_direct   (reg_ptl_sign_low   ),
        .Carry          (Carry_low          ),
        .Sum            (Sum_low            )
    );
    
    //CSA 9:2 for multiplier high
    CSA9_2 #(.DATA_WIDTH (16) ) u_CSA9_2_high (
        .clk            (clk                ), 
        .rstn           (rstn               ), 
        .data_0         (P0_high            ),    
        .data_1         (P1_high            ),    
        .data_2         (P2_high            ),    
        .data_3         (P3_high            ),    
        .data_4         (P4_high            ),    
        .data_5         (P5_high            ),    
        .data_6         (P6_high            ),    
        .data_7         (P7_high            ),    
        .data_8         (P8_high            ),    
        .flag_zero      (flag2_r            ),
        .shift_direct   (reg_ptl_sign_high  ),
        .Carry          (Carry_high         ),
        .Sum            (Sum_high           )
    );
    
    reg         [30:0]          reg_carry_low;
    reg         [30:0]          reg_carry_high;
    reg         [31:0]          reg_sum_low;
    reg         [31:0]          reg_sum_high;
    
    always @(posedge clk or negedge rstn) begin             //pipeline 
        if (! rstn) begin
           reg_carry_low        <=  0;
           reg_carry_high       <=  0;
           reg_sum_low          <=  0; 
           reg_sum_high         <=  0;
        end
        else begin
           reg_carry_low        <=  Carry_low[30:0];
           reg_carry_high       <=  Carry_high[30:0];
           reg_sum_low          <=  Sum_low;
           reg_sum_high         <=  Sum_high;
        end
   end     
    
    wire        [31:0]          Carry1,Carry2;
    wire        [31:0]          Sum1,Sum2; 
    wire        [32:0]          S_1,S_2;    
    
    assign       Carry1        =   {reg_carry_low,1'b0};          //32 bits C1
    assign       Carry2        =   {reg_carry_high,1'b0};         //32 bits C1
    assign       Sum1          =   reg_sum_low;                   //32 bits S1
    assign       Sum2          =   reg_sum_high;                  //32 bits S2
        
    assign       S_1           =   Sum1 + Carry1;                 // 16 bits + 16 bits for S_1
    assign       S_2           =   Sum2 + Carry2;                 // 16 bits + 16 bits for S_2
    
    assign       Sum_1         =   S_1[31:0];                     // output 16 bits + 16 bits for S_2[31:0]
    assign       Sum_2         =   S_2[31:0];                     // output 16 bits + 16 bits for S_2[31:0]
     
endmodule
