`timescale 1ns / 1ps

//===================================================================
// File Name	:  compressor modules.v
// Project Name	:   compressors 2:2, 3:2, 6:2
// Create Date	:  2020/05/05
// Author		:  wangwei
// Description	:   compressor 2:2,
//                  compressor 3:2,
//                  compressor 6:2,two pipelines compressor 6:2 cell
//===================================================================
 

module compressor2_2(a, b,  cout, sum);         //half_adder  compressor 2:2
    input a, b;
    output cout, sum;
    
    wire cout, sum;
    
    assign sum  = a ^ b;
    assign cout = a & b;
    
endmodule


module compressor3_2(a, b, cin, cout, sum);     //full_adder  compressor 3:2  1bir
    input a, b, cin;
    output cout, sum;
    
    wire cout, sum;

    assign sum  = a ^ b ^ cin;
    assign cout = (a ^ b) & cin | a & b;        //assign {cout, sum} = a + b + cin;
    
endmodule


module CSA3_2 #(parameter DATA_WIDTH = 8)      //compressor3_2         8bits
(
    a,b,c,sum,cout
);
    input       [DATA_WIDTH-1:0]        a, b, c;
    output      [DATA_WIDTH-1:0]        sum, cout;

    genvar i;
    generate
        for(i=0;i<DATA_WIDTH;i=i+1) begin
            compressor3_2 u_compressor3_2(
                .a      (a[i]   ),
                .b      (b[i]   ),
                .cin    (c[i]   ),
                .cout   (cout[i]),
                .sum    (sum[i] )
            );
        end
    endgenerate

endmodule



module compressor6_2_wrapper #(parameter DATA_WIDTH = 32)        //compressor6:2  32 bits
(
    a,b,c,d,e,f,cin1,cin2,cin3,sum,cout,C1,C2,C3
);

    input       [DATA_WIDTH-1:0]        a, b, c, d, e, f;
    input                               cin1,cin2,cin3;
    
    output      [DATA_WIDTH-1:0]        sum;
    output      [DATA_WIDTH-1:0]        cout;
    output                              C1,C2,C3;
    
    wire        [DATA_WIDTH-1:0]          S_port, C_port;
    
    genvar i;
    generate
        for(i=0;i<DATA_WIDTH;i=i+1) 
        begin
            if(i == 0) begin
                compressor6_2_cell u_compressor6_2(
                    .a      (a[i]       ),
                    .b      (b[i]       ),
                    .c      (c[i]       ),
                    .d      (d[i]       ),
                    .e      (e[i]       ),
                    .f      (f[i]       ),
                    .cin1   (cin1       ),
                    .cin2   (cin2       ),
                    .cout   (cout[i]    ),
                    .sum    (sum[i]     ),
                    .Co1    (C_port[0]  ),
                    .Co2    (S_port[0]  )
                );
                
            end
            else if (i == 1) begin
                compressor6_2_cell u_compressor6_2(
                .a          (a[i]       ),
                .b          (b[i]       ),
                .c          (c[i]       ),
                .d          (d[i]       ),
                .e          (e[i]       ),
                .f          (f[i]       ),
                .cin1       (S_port[0]  ),
                .cin2       (cin3       ),
                .cout       (cout[i]    ),
                .sum        (sum[i]     ),
                .Co1        (C_port[1]  ),
                .Co2        (S_port[1]  )
            );            
           end
           else if (i == DATA_WIDTH-2 ) begin
                compressor6_2_cell u_compressor6_2(
                   .a       (a[i]                ),
                   .b       (b[i]                ),
                   .c       (c[i]                ),
                   .d       (d[i]                ),
                   .e       (e[i]                ),
                   .f       (f[i]                ),
                   .cin1    (S_port[DATA_WIDTH-3]),
                   .cin2    (C_port[DATA_WIDTH-4]),
                   .cout    (cout[i]             ),
                   .sum     (sum[i]              ),
                   .Co1     (C_port[DATA_WIDTH-2]),
                   .Co2     (S_port[DATA_WIDTH-2])
               );            
           end   
           else if (i == DATA_WIDTH-1 ) begin
              compressor6_2_cell u_compressor6_2(
                 .a      (a[i]                  ),
                 .b      (b[i]                  ),
                 .c      (c[i]                  ),
                 .d      (d[i]                  ),
                 .e      (e[i]                  ),
                 .f      (f[i]                  ),
                 .cin1   (S_port[DATA_WIDTH-2]  ),
                 .cin2   (C_port[DATA_WIDTH-3]  ),
                 .cout   (cout[i]               ),
                 .sum    (sum[i]                ),
                 .Co1    (C_port[DATA_WIDTH-1]  ),
                 .Co2    (S_port[DATA_WIDTH-1]  )
             );            
            end 
            else begin
            compressor6_2_cell u_compressor6_2(
               .a      (a[i]        ),
               .b      (b[i]        ),
               .c      (c[i]        ),
               .d      (d[i]        ),
               .e      (e[i]        ),
               .f      (f[i]        ),
               .cin1   (S_port[i-1] ),
               .cin2   (C_port[i-2] ),
               .cout   (cout[i]     ),
               .sum    (sum[i]      ),
               .Co1    (C_port[i]   ),
               .Co2    (S_port[i]   )
           );             
            end  
        end
    endgenerate
    
    assign   C1 = S_port[DATA_WIDTH-1];
    assign   C2 = C_port[DATA_WIDTH-2];
    
    assign   C3 = C_port[DATA_WIDTH-1];
    
endmodule


module compressor6_2_cell                               //compressor6_2_cell ,2 pipelines
(
   a,b,c,d,e,f,cin1,cin2,sum,cout,Co1,Co2
);

    input              a, b, c, d, e, f;
    input              cin1,cin2;
    
    output             sum;
    output             cout;
    output             Co1,Co2;
    
    wire              c1,c2,s1,s2,c3,s3,c4,s4,c5,s5;
    
    //state1
    compressor3_2   u_com1 (
        .a      (a  ), 
        .b      (b  ), 
        .cin    (c  ), 
        .cout   (c1 ), 
        .sum    (s1 )
    );
    
    compressor3_2   u_com2 (
        .a      (d  ), 
        .b      (e  ), 
        .cin    (f  ), 
        .cout   (c2 ), 
        .sum    (s2 )
    );
    
    compressor2_2  u_half_adder  (
        .a      (s1 ), 
        .b      (s2 ),  
        .cout   (c3 ), 
        .sum    (s3 )
    );         
             
    //state2
    compressor3_2   u_com3 (
        .a      (c1 ), 
        .b      (c2 ), 
        .cin    (c3 ), 
        .cout   (c4 ), 
        .sum    (s4 )
    );
    
    compressor3_2   u_com4 (
        .a      (s3     ), 
        .b      (cin1   ), 
        .cin    (cin2   ), 
        .cout   (c5     ), 
        .sum    (s5     )
    );
    
    assign         sum  = s5;
    assign         cout = c5;
    assign         Co1  = c4;
    assign         Co2  = s4;
    
endmodule       
