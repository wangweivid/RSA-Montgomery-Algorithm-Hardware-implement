`timescale 1ns / 1ps

//===================================================================
// File Name	:   multi16_16.v
// Project Name	:  16x16 bit Booth Recoded Multiplier 
// Create Date	:  2020/05/05
// Author		:  wangwei
// Description	:  16x16 bit Booth Recoded Multiplier
//                 S = multiplier[15:0] * multiplicand [31:0]; 
//===================================================================


module multi16_16(
    clk,
    rstn,
    multiplier,             //input [15:0]  multiplier
    multiplicand,           //input [15:0]  multiplicand
    S                       //ouput [15:0]  S = multiplier[15:0] * multiplicand [31:0]; 
    );

    input                                clk;
    input                                rstn;
    input       [15:0]                   multiplier;         //16bits  input multiplier
    input       [15:0]                   multiplicand;       //16bits  input multiplicand
    
    output      [15:0]                   S;                  //16bits  output low 16 bits S = multiplier[15:0] * multiplicand [15:0];
   
    wire        [31:0]                   Carry_low;
    wire        [31:0]                   Sum_low;   
    
    wire        [18:0]                   multi_ext;                                                     //19bits
    //reg         [161:0]                  reg_partial;

    reg         [6:0]                    reg_shift;

    //booth_encoder
    //wire        [6 :0]                   partial_sign_low;

    reg         [15:0]                   reg_multiplicand;
    reg         [15:0]                   reg_multiplier;
    reg         [15:0]                   multiplicand_comp_low;
     
    always @(posedge clk or negedge rstn) begin
        if (! rstn) begin
           reg_multiplicand                 <=  0;
           reg_multiplier                   <=  0; 
           multiplicand_comp_low            <=  0;
        end
        else begin
           reg_multiplicand                 <=  multiplicand;
           reg_multiplier                   <=  multiplier;
           multiplicand_comp_low            <=  ~multiplicand + 1'b1;
        end
    end  
    
    wire        [16:0]          multiplicand_comp_low_ext;
    wire        [16:0]          multiplicand_ext_low;
    reg         [17:0]          P0_low,P1_low,P2_low,P3_low,P4_low,P5_low,P6_low,P7_low,P8_low;
    
    assign  multiplicand_comp_low_ext  = {1'b1, multiplicand_comp_low};
    assign  multiplicand_ext_low       = {1'b0, reg_multiplicand[15:0]};   

    assign  multi_ext                  = {2'b0,reg_multiplier,1'b0};      //multiplier extension 18 bits

    //*********************************************************************************************
    ////booth_wrapper encode for multiplicand   
    always@(posedge clk or negedge rstn )begin                                      
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
        end
        else begin
            //1st
            case(multi_ext[2:0] )
                3'b000:             P0_low   <=  0;                                 // zero
                3'b010:             P0_low   <=  {1'b0,multiplicand_ext_low};
                3'b100:             P0_low   <=  {multiplicand_comp_low_ext,1'b0};   // sub multi & shift left  1 bit
                3'b110:             P0_low   <=  {1'b1,multiplicand_comp_low_ext};
                default:            P0_low   <=  0;                                 // zero                           
            endcase
      
            //2nd
            case(multi_ext[4:2] )
                3'b000,3'b111:      P1_low   <=  0;                                 // zero    
                3'b001,3'b010:      P1_low   <=  {1'b0,multiplicand_ext_low};    
                3'b011:             P1_low   <=  {multiplicand_ext_low,1'b0};        // add multi & shift left  1 bit    
                3'b100:             P1_low   <=  {multiplicand_comp_low_ext,1'b0};   // sub multi & shift left  1 bit    
                3'b101,3'b110:      P1_low   <=  {1'b1,multiplicand_comp_low_ext};           
            endcase
            
             //3rd
            case(multi_ext[6:4] )
                3'b000,3'b111:      P2_low   <=  0;                                 // zero    
                3'b001,3'b010:      P2_low   <=  {1'b0,multiplicand_ext_low};   
                3'b011:             P2_low   <=  {multiplicand_ext_low,1'b0};        // add multi & shift left  1 bit    
                3'b100:             P2_low   <=  {multiplicand_comp_low_ext,1'b0};   // sub multi & shift left  1 bit     
                3'b101,3'b110:      P2_low   <=  {1'b1,multiplicand_comp_low_ext};           
            endcase
            
            //4th
            case(multi_ext[8:6] )
                3'b000,3'b111:      P3_low   <=  0;                                 // zero     
                3'b001,3'b010:      P3_low   <=  {1'b0,multiplicand_ext_low};   
                3'b011:             P3_low   <=  {multiplicand_ext_low,1'b0};        // add multi & shift left  1 bit    
                3'b100:             P3_low   <=  {multiplicand_comp_low_ext,1'b0};   // sub multi & shift left  1 bit
                3'b101,3'b110:      P3_low   <=  {1'b1,multiplicand_comp_low_ext};          
            endcase
            
            //5th
            case(multi_ext[10:8] )
                3'b000,3'b111:      P4_low   <=  0;                                 // zero    
                3'b001,3'b010:      P4_low   <=  {1'b0,multiplicand_ext_low};    
                3'b011:             P4_low   <=  {multiplicand_ext_low,1'b0};        // add multi & shift left  1 bit     
                3'b100:             P4_low   <=  {multiplicand_comp_low_ext,1'b0};   // sub multi & shift left  1 bit    
                3'b101,3'b110:      P4_low   <=  {1'b1,multiplicand_comp_low_ext};         
            endcase
            
            
            //6th
            case(multi_ext[12:10] )
                3'b000,3'b111:      P5_low   <=  0;                                 // zero    
                3'b001,3'b010:      P5_low   <=  {1'b0,multiplicand_ext_low};    
                3'b011:             P5_low   <=  {multiplicand_ext_low,1'b0};        // add multi & shift left  1 bit    
                3'b100:             P5_low   <=  {multiplicand_comp_low_ext,1'b0};   // sub multi & shift left  1 bit    
                3'b101,3'b110:      P5_low   <=  {1'b1,multiplicand_comp_low_ext};            
            endcase
            
            //7th
            case(multi_ext[14:12] )
                3'b000,3'b111:      P6_low   <=  0;                                 // zero    
                3'b001,3'b010:      P6_low   <=  {1'b0,multiplicand_ext_low};                        
                3'b011:             P6_low   <=  {multiplicand_ext_low,1'b0};        // add multi & shift left  1 bit    
                3'b100:             P6_low   <=  {multiplicand_comp_low_ext,1'b0};   // sub multi & shift left  1 bit     
                3'b101,3'b110:      P6_low   <=  {1'b1,multiplicand_comp_low_ext};          
            endcase
            
            //8th
            case(multi_ext[16:14] )
                3'b000,3'b111:      P7_low   <=  0;                                 // zero     
                3'b001,3'b010:      P7_low   <=  {1'b0,multiplicand_ext_low};     
                3'b011:             P7_low   <=  {multiplicand_ext_low,1'b0};        // add multi & shift left  1 bit     
                3'b100:             P7_low   <=  {multiplicand_comp_low_ext,1'b0};   // sub multi & shift left  1 bit     
                3'b101,3'b110:      P7_low   <=  {1'b1,multiplicand_comp_low_ext};           
            endcase
            
            //9th
            case(multi_ext[18:16] )
                3'b000:             P8_low   <=  0;                                 // zero  
                3'b001:             P8_low   <=  {1'b0,multiplicand_ext_low};     
                default:            P8_low   <=  0;                                 // zero                                 
            endcase
            
            end
        end
        
        //wire         [(18*9)-1:0]                 result_low;
        //wire         [(18*9)-1:0]                 result_high;
        wire         [6:0]                        ptl_sign;         //partial_sign
        wire                                      zero_flag;
        
        assign      ptl_sign[0] = multi_ext[2]  & (~(multi_ext[1]  & multi_ext[0] ));
        assign      ptl_sign[1] = multi_ext[4]  & (~(multi_ext[3]  & multi_ext[2] ));
        assign      ptl_sign[2] = multi_ext[6]  & (~(multi_ext[5]  & multi_ext[4] ));
        assign      ptl_sign[3] = multi_ext[8]  & (~(multi_ext[7]  & multi_ext[6] ));
        assign      ptl_sign[4] = multi_ext[10] & (~(multi_ext[9]  & multi_ext[8] ));
        assign      ptl_sign[5] = multi_ext[12] & (~(multi_ext[11] & multi_ext[10]));
        assign      ptl_sign[6] = multi_ext[14] & (~(multi_ext[13] & multi_ext[12]));
        
        //zero_flag for    multiplicand = 0 , not  Booth  encode
        assign      zero_flag   = (multiplicand[15: 0] == 16'b0) ? 1'b0 : 1'b1;
        
        reg     flag1_r;
        always @(posedge clk or negedge rstn) begin         
             if (! rstn) 
                flag1_r <= 0;
             else 
                flag1_r <= zero_flag;
        end 
              
     always @(posedge clk or negedge rstn) begin
         if (! rstn)
            reg_shift           <=  0; 
         else if (zero_flag == 1'b0) 
            reg_shift           <=  0;  
         else       
            reg_shift           <=  ptl_sign;
    end
    
    //CSA9:2
    CSA9_2 #(.DATA_WIDTH (16) ) u_CSA9_2_low (
        .clk            (clk         ),  
        .rstn           (rstn        ), 
        .data_0         (P0_low      ),   
        .data_1         (P1_low      ),   
        .data_2         (P2_low      ),   
        .data_3         (P3_low      ),   
        .data_4         (P4_low      ),   
        .data_5         (P5_low      ),   
        .data_6         (P6_low      ),   
        .data_7         (P7_low      ),   
        .data_8         (P8_low      ),   
        .flag_zero      (flag1_r     ),
        .shift_direct   (reg_shift   ),
        .Carry          (Carry_low   ),
        .Sum            (Sum_low     )
    );
    
    
    reg         [14:0]          reg_carry_low;
    reg         [15:0]          reg_sum_low;
    
    wire        [15:0]          S1;
    
    always @(posedge clk or negedge rstn) begin
        if (! rstn) begin
           reg_carry_low             <=  0;
           reg_sum_low               <=  0; 
        end
        else begin
           reg_carry_low             <=  Carry_low[14:0];
           reg_sum_low               <=  Sum_low[15:0];
        end
    end     
    
    assign S1 = reg_sum_low + {reg_carry_low,1'b0} ;
    assign S  = S1;                                         //output S for 16 * 16 bit
         
endmodule
