
//FSM state
`define      IDLE          3'b000       
`define      ENTER1        3'b001      
`define      ENTER2        3'b010       
`define      SS_MM         3'b011      
`define      CS_MM         3'b100       
`define      CS_PR         3'b101        
`define      EXIT          3'b110       
`define      DONE          3'b111        

`define      FLAG_4096     'h1000 //4096 
`define      FLAG_2048     'h800  //2048   
`define      FLAG_1024     'h400  //1024  
`define      FLAG_512      'h200  //512                          

`define      BYTE_4096     128      //Byte
`define      BYTE_2048     64   
`define      BYTE_1024     32  
`define      BYTE_512      16

`define      LEN_4096     256      //Half Byte
`define      LEN_2048     128   
`define      LEN_1024     64  
`define      LEN_512      32

`define      MODE_4096    129     //128 + 1 pipeline, >128
`define      MODE_2048    72      //12*6    pipeline, >64
`define      MODE_1024    48      //12*4    pipeline, >32
`define      MODE_512     24      //12*2    pipeline, >16

`define FUNC(x) \
    (x < 2    ) ? 1   :   \
    (x < 4    ) ? 2   :   \
    (x < 8    ) ? 3   :   \
    (x < 16   ) ? 4   :   \
    (x < 32   ) ? 5   :   \
    (x < 64   ) ? 6   :   \
    (x < 128  ) ? 7   :   \
    (x < 256  ) ? 8   :   \
    (x < 512  ) ? 9   :   \
    (x < 1024 ) ? 10  :   \
    (x < 2048 ) ? 11  :   \
    (x < 4096 ) ? 12  :   \
                -1   

// MULTIPIER PIPELINE
`define     NUM_MULTI_X_Y        3        //state 1
`define     NUM_MULTI_QM         5        //state 2
`define     NUM_MULTI_CSA        6        //state 3
`define     NUM_PIPELINE         12       //total Y0-->S,C
`define     MID_VALUE            NUM_PIPELINE/2       //

`define     NUM_Y                10

`define     NUM_STAGE_4096       10
`define     NUM_STAGE_2048       6
`define     NUM_STAGE_1024       4
`define     NUM_STAGE_512        2

`define     Y_LENGTH             64
