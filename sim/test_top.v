`timescale 1ns/100ps

module test_top;

localparam CH_NUM = 3;  // chennel num
localparam ACT_PER_ADDR = 9;  
localparam BW_PER_ACT = 10;   // # of bits of a data
localparam BW_PER_SRAM_GROUP_ADDR = CH_NUM*ACT_PER_ADDR*BW_PER_ACT;

localparam IMG_H = 576-2;
localparam IMG_W = 720-2;

localparam MEM_H = (IMG_H % 3 == 0)? IMG_H : IMG_H + (3 - IMG_H % 3);
localparam MEM_W = (IMG_W % 3 == 0)? IMG_W : IMG_W + (3 - IMG_W % 3);

localparam BW_PER_WEIGHT = 10;
localparam BW_PER_BIAS = 10; 

localparam WEIGHT_PER_ADDR = 9;
localparam BIAS_PER_ADDR = 1;

localparam END_CYCLES = 100000;
real CYCLE = 10;




reg [BW_PER_SRAM_GROUP_ADDR-1:0] input_img [0:(MEM_H*MEM_W)/ACT_PER_ADDR - 1];  
reg [BW_PER_SRAM_GROUP_ADDR-1:0] feat1_golden [0:(MEM_H*MEM_W)/ACT_PER_ADDR - 1];  
reg [BW_PER_ACT-1 : 0] feat1_ans [0 : MEM_H*MEM_W*CH_NUM-1];


reg [BW_PER_WEIGHT * WEIGHT_PER_ADDR - 1 : 0] weights [0:109-1];
reg [BW_PER_BIAS * BIAS_PER_ADDR - 1 : 0] biases [0:24-1];

wire [6:0] sram_raddr_weight;
wire [4:0] sram_raddr_bias;

wire [13:0] sram_raddr_img_0;
wire [13:0] sram_raddr_img_1;
wire [13:0] sram_raddr_img_2;
wire [13:0] sram_raddr_img_3;

wire [13:0] sram_raddr_feat1_0;
wire [13:0] sram_raddr_feat1_1;
wire [13:0] sram_raddr_feat1_2;
wire [13:0] sram_raddr_feat1_3;

wire [13:0] sram_raddr_feat2_0;
wire [13:0] sram_raddr_feat2_1;
wire [13:0] sram_raddr_feat2_2;
wire [13:0] sram_raddr_feat2_3;

wire [13:0] sram_raddr_feat3_0;
wire [13:0] sram_raddr_feat3_1;
wire [13:0] sram_raddr_feat3_2;
wire [13:0] sram_raddr_feat3_3;

wire [13:0] sram_raddr_feat4_0;
wire [13:0] sram_raddr_feat4_1;
wire [13:0] sram_raddr_feat4_2;
wire [13:0] sram_raddr_feat4_3;

wire [13:0] sram_raddr_feat5_0;
wire [13:0] sram_raddr_feat5_1;
wire [13:0] sram_raddr_feat5_2;
wire [13:0] sram_raddr_feat5_3;

wire [13:0] sram_raddr_temp_0;
wire [13:0] sram_raddr_temp_1;
wire [13:0] sram_raddr_temp_2;
wire [13:0] sram_raddr_temp_3;


wire [BW_PER_WEIGHT * WEIGHT_PER_ADDR - 1 : 0] sram_rdata_weight; 
wire [BW_PER_BIAS * BIAS_PER_ADDR - 1 : 0] sram_rdata_bias;

wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_img_0;
wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_img_1;
wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_img_2;
wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_img_3;

wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_feat1_0;
wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_feat1_1;
wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_feat1_2;
wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_feat1_3;

wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_feat2_0;
wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_feat2_1;
wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_feat2_2;
wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_feat2_3;

wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_feat3_0;
wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_feat3_1;
wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_feat3_2;
wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_feat3_3;

wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_feat4_0;
wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_feat4_1;
wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_feat4_2;
wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_feat4_3;

wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_feat5_0;
wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_feat5_1;
wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_feat5_2;
wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_feat5_3;

wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_temp_0;
wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_temp_1;
wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_temp_2;
wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_rdata_temp_3;



wire sram_wen_feat1_0;
wire sram_wen_feat1_1;
wire sram_wen_feat1_2;
wire sram_wen_feat1_3;

wire sram_wen_feat2_0;
wire sram_wen_feat2_1;
wire sram_wen_feat2_2;
wire sram_wen_feat2_3;

wire sram_wen_feat3_0;
wire sram_wen_feat3_1;
wire sram_wen_feat3_2;
wire sram_wen_feat3_3;

wire sram_wen_feat4_0;
wire sram_wen_feat4_1;
wire sram_wen_feat4_2;
wire sram_wen_feat4_3;

wire sram_wen_feat5_0;
wire sram_wen_feat5_1;
wire sram_wen_feat5_2;
wire sram_wen_feat5_3;

wire sram_wen_temp_0;
wire sram_wen_temp_1;
wire sram_wen_temp_2;
wire sram_wen_temp_3;


wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_wdata_feat1;
wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_wdata_feat2;
wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_wdata_feat3;
wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_wdata_feat4;
wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_wdata_feat5;
wire [BW_PER_SRAM_GROUP_ADDR - 1 : 0] sram_wdata_temp;



wire [13:0] sram_waddr_feat1;
wire [13:0] sram_waddr_feat2;
wire [13:0] sram_waddr_feat3;
wire [13:0] sram_waddr_feat4;
wire [13:0] sram_waddr_feat5;
wire [13:0] sram_waddr_temp;


wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_feat1;
wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_feat2;
wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_feat3;
wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_feat4;
wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_feat5;
wire [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_temp;




integer i, j, k;
integer c, m, n;

reg clk;
reg rst_n;
wire valid;


// ===== system reset ===== //
initial begin
    clk = 0;
    rst_n = 1;
end

always #(CYCLE/2) clk = ~clk;

initial begin
    #(CYCLE*END_CYCLES);
    $finish;
end


// ===== waveform dumpping ===== //
/*
initial begin
    $fsdbDumpfile("top.fsdb");
    $fsdbDumpvars("+mda");
end
*/



// ======= Top design =========// 


Conv_top #(
.CH_NUM(CH_NUM),
.ACT_PER_ADDR(ACT_PER_ADDR),
.BW_PER_ACT(BW_PER_ACT),
.WEIGHT_PER_ADDR(WEIGHT_PER_ADDR),
.BIAS_PER_ADDR(BIAS_PER_ADDR),
.BW_PER_WEIGHT(BW_PER_WEIGHT),
.BW_PER_BIAS(BW_PER_BIAS)
)
Conv_top(
.clk(clk),
.rst_n(rst_n),
.valid(valid), // output
.sram_rdata_img_0(sram_rdata_img_0),
.sram_rdata_img_1(sram_rdata_img_1),
.sram_rdata_img_2(sram_rdata_img_2),
.sram_rdata_img_3(sram_rdata_img_3),

.sram_rdata_feat1_0(sram_rdata_feat1_0),
.sram_rdata_feat1_1(sram_rdata_feat1_1),
.sram_rdata_feat1_2(sram_rdata_feat1_2),
.sram_rdata_feat1_3(sram_rdata_feat1_3),

.sram_rdata_feat2_0(sram_rdata_feat2_0),
.sram_rdata_feat2_1(sram_rdata_feat2_1),
.sram_rdata_feat2_2(sram_rdata_feat2_2),
.sram_rdata_feat2_3(sram_rdata_feat2_3),

.sram_rdata_feat3_0(sram_rdata_feat3_0),
.sram_rdata_feat3_1(sram_rdata_feat3_1),
.sram_rdata_feat3_2(sram_rdata_feat3_2),
.sram_rdata_feat3_3(sram_rdata_feat3_3),

.sram_rdata_feat4_0(sram_rdata_feat4_0),
.sram_rdata_feat4_1(sram_rdata_feat4_1),
.sram_rdata_feat4_2(sram_rdata_feat4_2),
.sram_rdata_feat4_3(sram_rdata_feat4_3),

.sram_rdata_feat5_0(sram_rdata_feat5_0),
.sram_rdata_feat5_1(sram_rdata_feat5_1),
.sram_rdata_feat5_2(sram_rdata_feat5_2),
.sram_rdata_feat5_3(sram_rdata_feat5_3),

.sram_rdata_temp_0(sram_rdata_temp_0),
.sram_rdata_temp_1(sram_rdata_temp_1),
.sram_rdata_temp_2(sram_rdata_temp_2),
.sram_rdata_temp_3(sram_rdata_temp_3),

.sram_rdata_weight(sram_rdata_weight),
.sram_rdata_bias(sram_rdata_bias),

.sram_raddr_img_0(sram_raddr_img_0),
.sram_raddr_img_1(sram_raddr_img_1),
.sram_raddr_img_2(sram_raddr_img_2),
.sram_raddr_img_3(sram_raddr_img_3),

.sram_raddr_feat1_0(sram_raddr_feat1_0),
.sram_raddr_feat1_1(sram_raddr_feat1_1),
.sram_raddr_feat1_2(sram_raddr_feat1_2),
.sram_raddr_feat1_3(sram_raddr_feat1_3),

.sram_raddr_feat2_0(sram_raddr_feat2_0),
.sram_raddr_feat2_1(sram_raddr_feat2_1),
.sram_raddr_feat2_2(sram_raddr_feat2_2),
.sram_raddr_feat2_3(sram_raddr_feat2_3),

.sram_raddr_feat3_0(sram_raddr_feat3_0),
.sram_raddr_feat3_1(sram_raddr_feat3_1),
.sram_raddr_feat3_2(sram_raddr_feat3_2),
.sram_raddr_feat3_3(sram_raddr_feat3_3),

.sram_raddr_feat4_0(sram_raddr_feat4_0),
.sram_raddr_feat4_1(sram_raddr_feat4_1),
.sram_raddr_feat4_2(sram_raddr_feat4_2),
.sram_raddr_feat4_3(sram_raddr_feat4_3),

.sram_raddr_feat5_0(sram_raddr_feat5_0),
.sram_raddr_feat5_1(sram_raddr_feat5_1),
.sram_raddr_feat5_2(sram_raddr_feat5_2),
.sram_raddr_feat5_3(sram_raddr_feat5_3),

.sram_raddr_temp_0(sram_raddr_temp_0),
.sram_raddr_temp_1(sram_raddr_temp_1),
.sram_raddr_temp_2(sram_raddr_temp_2),
.sram_raddr_temp_3(sram_raddr_temp_3),

.sram_raddr_weight(sram_raddr_weight),
.sram_raddr_bias(sram_raddr_bias),

.sram_wen_feat1_0(sram_wen_feat1_0),
.sram_wen_feat1_1(sram_wen_feat1_1),
.sram_wen_feat1_2(sram_wen_feat1_2),
.sram_wen_feat1_3(sram_wen_feat1_3),

.sram_wen_feat2_0(sram_wen_feat2_0),
.sram_wen_feat2_1(sram_wen_feat2_1),
.sram_wen_feat2_2(sram_wen_feat2_2),
.sram_wen_feat2_3(sram_wen_feat2_3),

.sram_wen_feat3_0(sram_wen_feat3_0),
.sram_wen_feat3_1(sram_wen_feat3_1),
.sram_wen_feat3_2(sram_wen_feat3_2),
.sram_wen_feat3_3(sram_wen_feat3_3),

.sram_wen_feat4_0(sram_wen_feat4_0),
.sram_wen_feat4_1(sram_wen_feat4_1),
.sram_wen_feat4_2(sram_wen_feat4_2),
.sram_wen_feat4_3(sram_wen_feat4_3),

.sram_wen_feat5_0(sram_wen_feat5_0),
.sram_wen_feat5_1(sram_wen_feat5_1),
.sram_wen_feat5_2(sram_wen_feat5_2),
.sram_wen_feat5_3(sram_wen_feat5_3),

.sram_wen_temp_0(sram_wen_temp_0),
.sram_wen_temp_1(sram_wen_temp_1),
.sram_wen_temp_2(sram_wen_temp_2),
.sram_wen_temp_3(sram_wen_temp_3),

.sram_wordmask_feat1(sram_wordmask_feat1),
.sram_wordmask_feat2(sram_wordmask_feat2),
.sram_wordmask_feat3(sram_wordmask_feat3),
.sram_wordmask_feat4(sram_wordmask_feat4),
.sram_wordmask_feat5(sram_wordmask_feat5),
.sram_wordmask_temp(sram_wordmask_temp),

.sram_waddr_feat1(sram_waddr_feat1),
.sram_waddr_feat2(sram_waddr_feat2),
.sram_waddr_feat3(sram_waddr_feat3),
.sram_waddr_feat4(sram_waddr_feat4),
.sram_waddr_feat5(sram_waddr_feat5),
.sram_waddr_temp(sram_waddr_temp),

.sram_wdata_feat1(sram_wdata_feat1),
.sram_wdata_feat2(sram_wdata_feat2),
.sram_wdata_feat3(sram_wdata_feat3),
.sram_wdata_feat4(sram_wdata_feat4),
.sram_wdata_feat5(sram_wdata_feat5),
.sram_wdata_temp(sram_wdata_temp)

);



initial begin
    $readmemb("./images/img.dat", input_img);
    $readmemb("./golden/feat1.dat", feat1_golden);
end

// ============ input image ===========//
sram_11520x270b sram_11520x270b_img_0(
.clk(clk),
.wordmask(27'd0),  //27 bits
.csb(1'b0),  //chip enable
.wsb(1'b1),  //write enable
.wdata(270'd0), //write data 270 bits
.waddr(14'd0), //write address
.raddr(sram_raddr_img_0), //read address
.rdata(sram_rdata_img_0) //read data 270 bits
);

sram_11520x270b sram_11520x270b_img_1(
.clk(clk),
.wordmask(27'd0),  //27 bits
.csb(1'b0),  //chip enable
.wsb(1'b1),  //write enable
.wdata(270'd0), //write data 270 bits
.waddr(14'd0), //write address
.raddr(sram_raddr_img_1), //read address
.rdata(sram_rdata_img_1) //read data 270 bits
);

sram_11520x270b sram_11520x270b_img_2(
.clk(clk),
.wordmask(27'd0),  //27 bits
.csb(1'b0),  //chip enable
.wsb(1'b1),  //write enable
.wdata(270'd0), //write data 270 bits
.waddr(14'd0), //write address
.raddr(sram_raddr_img_2), //read address
.rdata(sram_rdata_img_2) //read data 270 bits
);

sram_11520x270b sram_11520x270b_img_3(
.clk(clk),
.wordmask(27'd0),  //27 bits
.csb(1'b0),  //chip enable
.wsb(1'b1),  //write enable
.wdata(270'd0), //write data 270 bits
.waddr(14'd0), //write address
.raddr(sram_raddr_img_3), //read address
.rdata(sram_rdata_img_3) //read data 270 bits
);

// load input image
initial begin
    for(j = 0 ; j < 192; j = j + 1)begin
        for(k = 0 ; k < 240; k = k + 1)begin
            if(j % 2 == 0 && k % 2 == 0)begin
                sram_11520x270b_img_0.load_input_img((j/2)*120 + k/2, input_img[(j/2)*120 + k/2]);
            end
            else if (j % 2 == 0)begin
                sram_11520x270b_img_1.load_input_img((j/2)*120 + k/2, input_img[(j/2)*120 + k/2]);
            end
            else if (k % 2 == 0)begin
                sram_11520x270b_img_2.load_input_img((j/2)*120 + k/2, input_img[(j/2)*120 + k/2]);
            end
            else begin
                sram_11520x270b_img_3.load_input_img((j/2)*120 + k/2, input_img[(j/2)*120 + k/2]);
            end
        end
    end
// test 
/*    
    for(j = 0 ; j < 192; j = j + 1)begin
        for(k = 0 ; k < 240; k = k + 1)begin
            if(j % 2 == 0 && k % 2 == 0)begin
                sram_11520x270b_feat1_0.load_input_img((j/2)*120 + k/2, feat1_golden[j*240 + k]);
            end
            else if (j % 2 == 0)begin
                sram_11520x270b_feat1_1.load_input_img((j/2)*120 + k/2, feat1_golden[j*240 + k]);
            end
            else if (k % 2 == 0)begin
                sram_11520x270b_feat1_2.load_input_img((j/2)*120 + k/2, feat1_golden[j*240 + k]);
            end
            else begin 
                sram_11520x270b_feat1_3.load_input_img((j/2)*120 + k/2, feat1_golden[j*240 + k]);
            end
        end
    end
*/
end

// ===================================== //

// =========== sram store calculated feature 1 =================//

sram_11520x270b sram_11520x270b_feat1_0(
.clk(clk),
.wordmask(sram_wordmask_feat1),
.csb(1'b0), 
.wsb(sram_wen_feat1_0),  
.wdata(sram_wdata_feat1), 
.waddr(sram_waddr_feat1), 
.raddr(sram_raddr_feat1_0), 
.rdata(sram_rdata_feat1_0) 
);

sram_11520x270b sram_11520x270b_feat1_1(
.clk(clk),
.wordmask(sram_wordmask_feat1),
.csb(1'b0), 
.wsb(sram_wen_feat1_1),  
.wdata(sram_wdata_feat1), 
.waddr(sram_waddr_feat1), 
.raddr(sram_raddr_feat1_1), 
.rdata(sram_rdata_feat1_1) 
);

sram_11520x270b sram_11520x270b_feat1_2(
.clk(clk),
.wordmask(sram_wordmask_feat1),
.csb(1'b0), 
.wsb(sram_wen_feat1_2),  
.wdata(sram_wdata_feat1), 
.waddr(sram_waddr_feat1), 
.raddr(sram_raddr_feat1_2), 
.rdata(sram_rdata_feat1_2) 
);

sram_11520x270b sram_11520x270b_feat1_3(
.clk(clk),
.wordmask(sram_wordmask_feat1),
.csb(1'b0), 
.wsb(sram_wen_feat1_3),  
.wdata(sram_wdata_feat1), 
.waddr(sram_waddr_feat1), 
.raddr(sram_raddr_feat1_3), 
.rdata(sram_rdata_feat1_3) 
);

// ============================================================//

// =========== sram store calculated feature 2 =================//

sram_11520x270b sram_11520x270b_feat2_0(
.clk(clk),
.wordmask(sram_wordmask_feat2),
.csb(1'b0), 
.wsb(sram_wen_feat2_0),  
.wdata(sram_wdata_feat2), 
.waddr(sram_waddr_feat2), 
.raddr(sram_raddr_feat2_0), 
.rdata(sram_rdata_feat2_0) 
);

sram_11520x270b sram_11520x270b_feat2_1(
.clk(clk),
.wordmask(sram_wordmask_feat2),
.csb(1'b0), 
.wsb(sram_wen_feat2_1),  
.wdata(sram_wdata_feat2), 
.waddr(sram_waddr_feat2), 
.raddr(sram_raddr_feat2_1), 
.rdata(sram_rdata_feat2_1) 
);

sram_11520x270b sram_11520x270b_feat2_2(
.clk(clk),
.wordmask(sram_wordmask_feat2),
.csb(1'b0), 
.wsb(sram_wen_feat2_2),  
.wdata(sram_wdata_feat2), 
.waddr(sram_waddr_feat2), 
.raddr(sram_raddr_feat2_2), 
.rdata(sram_rdata_feat2_2) 
);

sram_11520x270b sram_11520x270b_feat2_3(
.clk(clk),
.wordmask(sram_wordmask_feat2),
.csb(1'b0), 
.wsb(sram_wen_feat2_3),  
.wdata(sram_wdata_feat2), 
.waddr(sram_waddr_feat2), 
.raddr(sram_raddr_feat2_3), 
.rdata(sram_rdata_feat2_3) 
);

// ============================================================//

// =========== sram store calculated feature 3 =================//

sram_11520x270b sram_11520x270b_feat3_0(
.clk(clk),
.wordmask(sram_wordmask_feat3),
.csb(1'b0), 
.wsb(sram_wen_feat3_0),  
.wdata(sram_wdata_feat3), 
.waddr(sram_waddr_feat3), 
.raddr(sram_raddr_feat3_0), 
.rdata(sram_rdata_feat3_0) 
);

sram_11520x270b sram_11520x270b_feat3_1(
.clk(clk),
.wordmask(sram_wordmask_feat3),
.csb(1'b0), 
.wsb(sram_wen_feat3_1),  
.wdata(sram_wdata_feat3), 
.waddr(sram_waddr_feat3), 
.raddr(sram_raddr_feat3_1), 
.rdata(sram_rdata_feat3_1) 
);

sram_11520x270b sram_11520x270b_feat3_2(
.clk(clk),
.wordmask(sram_wordmask_feat3),
.csb(1'b0), 
.wsb(sram_wen_feat3_2),  
.wdata(sram_wdata_feat3), 
.waddr(sram_waddr_feat3), 
.raddr(sram_raddr_feat3_2), 
.rdata(sram_rdata_feat3_2) 
);

sram_11520x270b sram_11520x270b_feat3_3(
.clk(clk),
.wordmask(sram_wordmask_feat3),
.csb(1'b0), 
.wsb(sram_wen_feat3_3),  
.wdata(sram_wdata_feat3), 
.waddr(sram_waddr_feat3), 
.raddr(sram_raddr_feat3_3), 
.rdata(sram_rdata_feat3_3) 
);

// ============================================================//

// =========== sram store calculated feature 4 =================//

sram_11520x270b sram_11520x270b_feat4_0(
.clk(clk),
.wordmask(sram_wordmask_feat4),
.csb(1'b0), 
.wsb(sram_wen_feat4_0),  
.wdata(sram_wdata_feat4), 
.waddr(sram_waddr_feat4), 
.raddr(sram_raddr_feat4_0), 
.rdata(sram_rdata_feat4_0) 
);

sram_11520x270b sram_11520x270b_feat4_1(
.clk(clk),
.wordmask(sram_wordmask_feat4),
.csb(1'b0), 
.wsb(sram_wen_feat4_1),  
.wdata(sram_wdata_feat4), 
.waddr(sram_waddr_feat4), 
.raddr(sram_raddr_feat4_1), 
.rdata(sram_rdata_feat4_1) 
);

sram_11520x270b sram_11520x270b_feat4_2(
.clk(clk),
.wordmask(sram_wordmask_feat4),
.csb(1'b0), 
.wsb(sram_wen_feat4_2),  
.wdata(sram_wdata_feat4), 
.waddr(sram_waddr_feat4), 
.raddr(sram_raddr_feat4_2), 
.rdata(sram_rdata_feat4_2) 
);

sram_11520x270b sram_11520x270b_feat4_3(
.clk(clk),
.wordmask(sram_wordmask_feat4),
.csb(1'b0), 
.wsb(sram_wen_feat4_3),  
.wdata(sram_wdata_feat4), 
.waddr(sram_waddr_feat4), 
.raddr(sram_raddr_feat4_3), 
.rdata(sram_rdata_feat4_3) 
);

// ============================================================//


// =========== sram store calculated feature 5 =================//

sram_11520x270b sram_11520x270b_feat5_0(
.clk(clk),
.wordmask(sram_wordmask_feat5),
.csb(1'b0), 
.wsb(sram_wen_feat5_0),  
.wdata(sram_wdata_feat5), 
.waddr(sram_waddr_feat5), 
.raddr(sram_raddr_feat5_0), 
.rdata(sram_rdata_feat5_0) 
);

sram_11520x270b sram_11520x270b_feat5_1(
.clk(clk),
.wordmask(sram_wordmask_feat5),
.csb(1'b0), 
.wsb(sram_wen_feat5_1),  
.wdata(sram_wdata_feat5), 
.waddr(sram_waddr_feat5), 
.raddr(sram_raddr_feat5_1), 
.rdata(sram_rdata_feat5_1) 
);

sram_11520x270b sram_11520x270b_feat5_2(
.clk(clk),
.wordmask(sram_wordmask_feat5),
.csb(1'b0), 
.wsb(sram_wen_feat5_2),  
.wdata(sram_wdata_feat5), 
.waddr(sram_waddr_feat5), 
.raddr(sram_raddr_feat5_2), 
.rdata(sram_rdata_feat5_2) 
);

sram_11520x270b sram_11520x270b_feat5_3(
.clk(clk),
.wordmask(sram_wordmask_feat5),
.csb(1'b0), 
.wsb(sram_wen_feat5_3),  
.wdata(sram_wdata_feat5), 
.waddr(sram_waddr_feat5), 
.raddr(sram_raddr_feat5_3), 
.rdata(sram_rdata_feat5_3) 
);

// ============================================================//

// =========== sram store calculated feature 5 =================//

sram_11520x270b sram_11520x270b_temp_0(
.clk(clk),
.wordmask(sram_wordmask_temp),
.csb(1'b0), 
.wsb(sram_wen_temp_0),  
.wdata(sram_wdata_temp), 
.waddr(sram_waddr_temp), 
.raddr(sram_raddr_temp_0), 
.rdata(sram_rdata_temp_0) 
);

sram_11520x270b sram_11520x270b_temp_1(
.clk(clk),
.wordmask(sram_wordmask_temp),
.csb(1'b0), 
.wsb(sram_wen_temp_1),  
.wdata(sram_wdata_temp), 
.waddr(sram_waddr_temp), 
.raddr(sram_raddr_temp_1), 
.rdata(sram_rdata_temp_1) 
);

sram_11520x270b sram_11520x270b_temp_2(
.clk(clk),
.wordmask(sram_wordmask_temp),
.csb(1'b0), 
.wsb(sram_wen_temp_2),  
.wdata(sram_wdata_temp), 
.waddr(sram_waddr_temp), 
.raddr(sram_raddr_temp_2), 
.rdata(sram_rdata_temp_2) 
);

sram_11520x270b sram_11520x270b_temp_3(
.clk(clk),
.wordmask(sram_wordmask_temp),
.csb(1'b0), 
.wsb(sram_wen_temp_3),  
.wdata(sram_wdata_temp), 
.waddr(sram_waddr_temp), 
.raddr(sram_raddr_temp_3), 
.rdata(sram_rdata_temp_3) 
);

// ============================================================//

// ===== weight and bias =========== //

initial begin 
    $readmemb("./param/weight.dat", weights);
    $readmemb("./param/bias.dat", biases);
end

sram_109x90b sram_109x90b_weight(
.clk(clk),
.csb(1'b0),  //chip enable
.wsb(1'b1),  //write enable
.wdata(90'd0), //write data
.waddr(7'd0), //write address
.raddr(sram_raddr_weight), //read address

//output
.rdata(sram_rdata_weight)
);

sram_24x10b sram_24x10b_bias(
.clk(clk),
.csb(1'b0),  //chip enable
.wsb(1'b1),  //write enable
.wdata(10'd0), //write data
.waddr(5'd0), //write address
.raddr(sram_raddr_bias), //read address

//output
.rdata(sram_rdata_bias)
);

// load weight and bias
initial begin
    for (i = 0 ; i < 108 ; i = i + 1)begin
        sram_109x90b_weight.load_param(i, weights[i]);
    end

    for (i = 0 ; i < 24 ; i = i + 1)begin
        sram_24x10b_bias.load_param(i, biases[i]);
    end
end

// ========= compare result ===========//


initial begin
    $readmemb("./golden/feat1_ans.dat", feat1_ans);
end

integer mm,nn;
integer mmm, nnn;
integer addr;
integer pos;
reg[BW_PER_ACT-1:0] ans; 


assign valid =1;
initial begin

    wait(valid);

    @(negedge clk);


    $display("%b", sram_11520x270b_feat1_0.mem[0]);



    for(c = 0 ; c < 3 ; c = c + 1)begin
        for(m = 0 ; m < 576 ; m = m +1)begin
            for(n = 0 ; n < 720 ; n = n + 1)begin
                mm = m / 3;
                nn = n / 3;
                mmm = m % 3;
                nnn = n % 3;
                addr = (mm/2) * 120 + (nn/2); 
                ans = feat1_ans[c*576*720 + m*720 + n];
                pos = (2-c)*90 + (2-mmm) * 30 + (2-nnn) * 10;
                
                //$display("m = %3d, n = %3d, ch = %1d, Ans = %10b", m, n, c,ans);    
                //$display("m = %3d, n = %3d, ch = %1d, addr = %d", m, n, c,addr);    
                if(mm % 2 == 0 && nn % 2 == 0)begin
                    if(sram_11520x270b_feat1_0.mem[addr][pos+:10] === ans)begin
                    
                    end
                    else begin
                        $display("Wrong occur at m = %3d, n = %3d, ch = %1d, Your result = %10b, Ans = %10b", m, n, c, sram_11520x270b_feat1_0.mem[addr][pos+:10],ans);    
                    end
                end
                else if (mm % 2 == 0) begin
                    if(sram_11520x270b_feat1_1.mem[addr][pos+:10] === ans)begin
                    
                    end
                    else begin
                        $display("Wrong occur at m = %3d, n = %3d, ch = %1d, Your result = %10b, Ans = %10b", m, n, c, sram_11520x270b_feat1_1.mem[addr][pos+:10],ans);    
                    end
                end
                else if (nn % 2 == 0) begin
                    if(sram_11520x270b_feat1_2.mem[addr][pos+:10] === ans)begin
                    
                    end
                    else begin
                        $display("Wrong occur at m = %3d, n = %3d, ch = %1d, Your result = %10b, Ans = %10b", m, n, c, sram_11520x270b_feat1_2.mem[addr][pos+:10],ans);    
                    end
                end
                else begin
                    if(sram_11520x270b_feat1_3.mem[addr][pos+:10] === ans)begin
                    
                    end
                    else begin
                        $display("Wrong occur at m = %3d, n = %3d, ch = %1d, Your result = %10b, Ans = %10b", m, n, c, sram_11520x270b_feat1_3.mem[addr][pos+:10],ans);    
                    end

                end
            end
        end
    end
end

// ====================================//





reg [21:0] test;
reg signed [21:0] test2;

reg signed [5:0] test3;

reg signed [2:0] a,b,cc,d,e;

reg signed [9:0] in[0:2];
reg signed [9:0] w[0:2];
reg signed [9:0] bias;
reg signed [17:0] bias2;

reg signed [21:0] out;
reg signed [21:0] out2;

initial begin

    in[0] = input_img[0][260 +: 10];
    in[1] = input_img[0][170 +: 10];
    in[2] = input_img[0][ 80 +: 10];

    w[0] = weights[0][80+:10];
    w[1] = weights[0][70+:10];
    w[2] = weights[0][60+:10];

    bias = biases[0];
    
    bias2 = {bias,8'd0};
    
    /*
    out = in[0] * w[0] + 
          in[1] * w[1] +
          in[2] * w[2] + bias << 8;
    */
    out2 = in[0] * w[0] + 
           in[1] * w[1] +
           in[2] * w[2] + bias2 + 8'b1000_0000;
    
    $display("%b", $signed(out2[8 +: 10]));

    //a = input_img[0][260 +: 10];
    //b = weights[0][80 +: 10];
    
    //c = a*b 
    
    //test = {{10{input_img[0][260+:10]}}, input_img[0][260+:10]} * {{10{weights[0][80+:10]}},weights[0][80+:10]} +
         //  {{10{input_img[0][170+:10]}}, input_img[0][170+:10]} * {{10{weights[0][70+:10]}},weights[0][70+:10]} +
         //  {{10{input_img[0][170+:10]}}, input_img[0][170+:10]} * {{10{weights[0][70+:10]}},weights[0][70+:10]} +
           
    //test =  {{10{input_img[0][260+:10]}}, input_img[0][260+:10]} * {{10{weights[0][80+:10]}},weights[0][80+:10]};
    //test2 = input_img[0][260+:10] * weights[0][80+:10];
    
    //test3 = 3'b111 * 3'b101;
    //test3 = 6'b111111 * 6'b000101;
    
    a = 3'b111; //-1
    b = 3'b101; //-3

    cc = 3'b111; //-1
    d = 3'b010; // 2

    e = 3'b101; //-3
    test3 = a*b + cc * d + e;
    
    $display("%d", $signed(out));
    $display("%d", $signed(out2[8 +: 10]));
    $display("%d", $signed(test3));
    $display("%d", 3/2);
end









/*
reg [16*8-1:0] jpg_filename;

reg [7:0] char_in;

integer file_in;
integer i;

initial begin
    jpg_filename = "./images/img.jpg";
    file_in = $fopen(jpg_filename, "rb");

    for(i = 0 ; i < 20 ; i = i + 1)begin
        char_in = $fgetc(file_in);
        
        $display("%d", char_in);
    end
end
*/

endmodule


