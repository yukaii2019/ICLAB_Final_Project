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


localparam CONV1 = 0;
localparam CONV2 = 1;
localparam CONV3_1 = 2;
localparam CONV3 = 3;
localparam CONV4_1 = 4;
localparam CONV4_2 = 5;
localparam CONV4 = 6;
localparam CONV5 = 7;


reg [BW_PER_SRAM_GROUP_ADDR-1:0] input_img [0:(MEM_H*MEM_W)/ACT_PER_ADDR - 1];  
//reg [BW_PER_SRAM_GROUP_ADDR-1:0] feat1_mem_placed [0:(MEM_H*MEM_W)/ACT_PER_ADDR - 1];  
//reg [BW_PER_SRAM_GROUP_ADDR-1:0] feat2_mem_placed [0:(MEM_H*MEM_W)/ACT_PER_ADDR - 1];  
//reg [BW_PER_SRAM_GROUP_ADDR-1:0] feat3_1_mem_placed [0:(MEM_H*MEM_W)/ACT_PER_ADDR - 1];  
//reg [BW_PER_SRAM_GROUP_ADDR-1:0] feat3_mem_placed [0:(MEM_H*MEM_W)/ACT_PER_ADDR - 1];  
//reg [BW_PER_SRAM_GROUP_ADDR-1:0] feat4_1_mem_placed [0:(MEM_H*MEM_W)/ACT_PER_ADDR - 1];  
//reg [BW_PER_SRAM_GROUP_ADDR-1:0] feat4_2_mem_placed [0:(MEM_H*MEM_W)/ACT_PER_ADDR - 1];  
//reg [BW_PER_SRAM_GROUP_ADDR-1:0] feat4_mem_placed [0:(MEM_H*MEM_W)/ACT_PER_ADDR - 1];  
//reg [BW_PER_SRAM_GROUP_ADDR-1:0] feat5_mem_placed [0:(MEM_H*MEM_W)/ACT_PER_ADDR - 1];  

reg [BW_PER_ACT-1 : 0] feat1_ans [0 : MEM_H*MEM_W*CH_NUM-1];
reg [BW_PER_ACT-1 : 0] feat2_ans [0 : MEM_H*MEM_W*CH_NUM-1];
reg [BW_PER_ACT-1 : 0] feat3_1_ans [0 : MEM_H*MEM_W*CH_NUM-1];
reg [BW_PER_ACT-1 : 0] feat3_ans [0 : MEM_H*MEM_W*CH_NUM-1];
reg [BW_PER_ACT-1 : 0] feat4_1_ans [0 : MEM_H*MEM_W*CH_NUM-1];
reg [BW_PER_ACT-1 : 0] feat4_2_ans [0 : MEM_H*MEM_W*CH_NUM-1];
reg [BW_PER_ACT-1 : 0] feat4_ans [0 : MEM_H*MEM_W*CH_NUM-1];
reg [BW_PER_ACT-1 : 0] feat5_ans [0 : MEM_H*MEM_W*CH_NUM-1];


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

integer mm,nn;
integer mmm, nnn;
integer addr;
integer pos;
integer error_count;
reg[BW_PER_ACT-1:0] ans; 
reg[BW_PER_ACT-1:0] your_ans; 

integer test_layer;

// ===== choose layer to test ==== //
initial begin
    `ifdef TEST_CONV1
        test_layer = CONV1;
    `elsif TEST_CONV2
        test_layer = CONV2;
    `elsif TEST_CONV3_1
        test_layer = CONV3_1;
    `elsif TEST_CONV3
        test_layer = CONV3;
    `elsif TEST_CONV4_1
        test_layer = CONV4_1;
    `elsif TEST_CONV4_2
        test_layer = CONV4_2;
    `elsif TEST_CONV4
        test_layer = CONV4;
    `elsif TEST_CONV5 
        test_layer = CONV5;
    `else 
        test_layer = CONV1;
    `endif
end
// =============================== //

// ===== system reset ===== //
initial begin
    clk = 0;
    rst_n = 1;
    @(negedge clk);
        rst_n = 1'b0;
    @(negedge clk);
        rst_n = 1'b1;
end

always #(CYCLE/2) clk = ~clk;

initial begin
    #(CYCLE*END_CYCLES);
    $finish;
end
// ========================//


// ===== waveform dumpping ===== //

initial begin
    $fsdbDumpfile("top.fsdb");
    $fsdbDumpvars(n, Conv_top,"+mda"); // only dump top module
end

// =============================//



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
    //$readmemb("./mem_placed_ans/feat1_mem_placement.dat", feat1_mem_placed);
    //$readmemb("./mem_placed_ans/feat2_mem_placement.dat", feat2_mem_placed);
    //$readmemb("./mem_placed_ans/feat3_1_mem_placement.dat", feat3_1_mem_placed);
    //$readmemb("./mem_placed_ans/feat3_mem_placement.dat", feat3_mem_placed);
    //$readmemb("./mem_placed_ans/feat4_1_mem_placement.dat", feat4_1_mem_placed);
    //$readmemb("./mem_placed_ans/feat4_2_mem_placement.dat", feat4_2_mem_placed);
    //$readmemb("./mem_placed_ans/feat4_mem_placement.dat", feat4_mem_placed);
    //$readmemb("./mem_placed_ans/feat5_mem_placement.dat", feat5_mem_placed);
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
                sram_11520x270b_img_0.load_input_img((j/2)*120 + k/2, input_img[j*240 + k]);
            end
            else if (j % 2 == 0)begin
                sram_11520x270b_img_1.load_input_img((j/2)*120 + k/2, input_img[j*240 + k]);
            end
            else if (k % 2 == 0)begin
                sram_11520x270b_img_2.load_input_img((j/2)*120 + k/2, input_img[j*240 + k]);
            end
            else begin
                sram_11520x270b_img_3.load_input_img((j/2)*120 + k/2, input_img[j*240 + k]);
            end
        end
    end
// test 
/*
    for(j = 0 ; j < 192; j = j + 1)begin
        for(k = 0 ; k < 240; k = k + 1)begin
            if(j % 2 == 0 && k % 2 == 0)begin
                sram_11520x270b_feat1_0.load_input_img((j/2)*120 + k/2, feat1_mem_placed[j*240 + k]);
            end
            else if (j % 2 == 0)begin
                sram_11520x270b_feat1_1.load_input_img((j/2)*120 + k/2, feat1_mem_placed[j*240 + k]);
            end
            else if (k % 2 == 0)begin
                sram_11520x270b_feat1_2.load_input_img((j/2)*120 + k/2, feat1_mem_placed[j*240 + k]);
            end
            else begin 
                sram_11520x270b_feat1_3.load_input_img((j/2)*120 + k/2, feat1_mem_placed[j*240 + k]);
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
    $readmemb("./golden/feat2_ans.dat", feat2_ans);
    $readmemb("./golden/feat3_1_ans.dat", feat3_1_ans);
    $readmemb("./golden/feat3_ans.dat", feat3_ans);
    $readmemb("./golden/feat4_1_ans.dat", feat4_1_ans);
    $readmemb("./golden/feat4_2_ans.dat", feat4_2_ans);
    $readmemb("./golden/feat4_ans.dat", feat4_ans);
    $readmemb("./golden/feat5_ans.dat", feat5_ans);
end


initial begin
    error_count = 0;
    wait(valid);

    @(negedge clk);

    for(c = 0 ; c < 3 ; c = c + 1)begin
        for(m = 0 ; m < 576 ; m = m +1)begin
            for(n = 0 ; n < 720 ; n = n + 1)begin
                mm = m / 3;
                nn = n / 3;
                mmm = m % 3;
                nnn = n % 3;
                addr = (mm/2) * 120 + (nn/2); 
                pos = (2-c)*90 + (2-mmm) * 30 + (2-nnn) * 10;


                case(test_layer)
                    CONV1:   ans = feat1_ans[c*576*720 + m*720 + n];
                    CONV2:   ans = feat2_ans[c*576*720 + m*720 + n];
                    CONV3_1: ans = feat3_1_ans[c*576*720 + m*720 + n];
                    CONV3:   ans = feat3_ans[c*576*720 + m*720 + n];
                    CONV4_1: ans = feat4_1_ans[c*576*720 + m*720 + n];
                    CONV4_2: ans = feat4_2_ans[c*576*720 + m*720 + n];
                    CONV4:   ans = feat4_ans[c*576*720 + m*720 + n];
                    CONV5:   ans = feat5_ans[c*576*720 + m*720 + n];
                    default: ans = feat1_ans[c*576*720 + m*720 + n];
                endcase
            
                if(mm % 2 == 0 && nn % 2 == 0)begin
                    case(test_layer)
                        CONV1:   your_ans = sram_11520x270b_feat1_0.mem[addr][pos+:10];
                        CONV2:   your_ans = sram_11520x270b_feat2_0.mem[addr][pos+:10];
                        CONV3_1: your_ans = sram_11520x270b_temp_0.mem[addr][pos+:10];
                        CONV3:   your_ans = sram_11520x270b_feat3_0.mem[addr][pos+:10];
                        CONV4_1: your_ans = sram_11520x270b_feat4_0.mem[addr][pos+:10];
                        CONV4_2: your_ans = sram_11520x270b_temp_0.mem[addr][pos+:10];
                        CONV4:   your_ans = sram_11520x270b_feat4_0.mem[addr][pos+:10];
                        CONV5:   your_ans = sram_11520x270b_feat5_0.mem[addr][pos+:10];
                        default: your_ans = sram_11520x270b_feat1_0.mem[addr][pos+:10];
                    endcase
                end
                else if (mm % 2 == 0) begin
                    case(test_layer)
                        CONV1:   your_ans = sram_11520x270b_feat1_1.mem[addr][pos+:10];
                        CONV2:   your_ans = sram_11520x270b_feat2_1.mem[addr][pos+:10];
                        CONV3_1: your_ans = sram_11520x270b_temp_1.mem[addr][pos+:10];
                        CONV3:   your_ans = sram_11520x270b_feat3_1.mem[addr][pos+:10];
                        CONV4_1: your_ans = sram_11520x270b_feat4_1.mem[addr][pos+:10];
                        CONV4_2: your_ans = sram_11520x270b_temp_1.mem[addr][pos+:10];
                        CONV4:   your_ans = sram_11520x270b_feat4_1.mem[addr][pos+:10];
                        CONV5:   your_ans = sram_11520x270b_feat5_1.mem[addr][pos+:10];
                        default: your_ans = sram_11520x270b_feat1_1.mem[addr][pos+:10];
                    endcase
                end
                else if (nn % 2 == 0) begin
                    case(test_layer)
                        CONV1:   your_ans = sram_11520x270b_feat1_2.mem[addr][pos+:10];
                        CONV2:   your_ans = sram_11520x270b_feat2_2.mem[addr][pos+:10];
                        CONV3_1: your_ans = sram_11520x270b_temp_2.mem[addr][pos+:10];
                        CONV3:   your_ans = sram_11520x270b_feat3_2.mem[addr][pos+:10];
                        CONV4_1: your_ans = sram_11520x270b_feat4_2.mem[addr][pos+:10];
                        CONV4_2: your_ans = sram_11520x270b_temp_2.mem[addr][pos+:10];
                        CONV4:   your_ans = sram_11520x270b_feat4_2.mem[addr][pos+:10];
                        CONV5:   your_ans = sram_11520x270b_feat5_2.mem[addr][pos+:10];
                        default: your_ans = sram_11520x270b_feat1_2.mem[addr][pos+:10];
                    endcase
                end
                else begin
                    case(test_layer)
                        CONV1:   your_ans = sram_11520x270b_feat1_3.mem[addr][pos+:10];
                        CONV2:   your_ans = sram_11520x270b_feat2_3.mem[addr][pos+:10];
                        CONV3_1: your_ans = sram_11520x270b_temp_3.mem[addr][pos+:10];
                        CONV3:   your_ans = sram_11520x270b_feat3_3.mem[addr][pos+:10];
                        CONV4_1: your_ans = sram_11520x270b_feat4_3.mem[addr][pos+:10];
                        CONV4_2: your_ans = sram_11520x270b_temp_3.mem[addr][pos+:10];
                        CONV4:   your_ans = sram_11520x270b_feat4_3.mem[addr][pos+:10];
                        CONV5:   your_ans = sram_11520x270b_feat5_3.mem[addr][pos+:10];
                        default: your_ans = sram_11520x270b_feat1_3.mem[addr][pos+:10];
                    endcase
                end
                
                if(your_ans !== ans)begin
                    $display("Wrong occur at m = %3d, n = %3d, ch = %1d, Your result = %10b, Ans = %10b", m, n, c, your_ans, ans);    
                    error_count = error_count+1;
                end
                //else begin
                //    $display("Correct!! m = %3d, n = %3d, ch = %1d, Your result = %10b, Ans = %10b", m, n, c, sram_11520x270b_feat1_0.mem[addr][pos+:10],ans);         
                //end        
            end
        end
    end

    if(error_count == 0)begin
        case(test_layer)
            CONV1  :$display("Congratulations!, The CONV1 is correct");
            CONV2  :$display("Congratulations!, The CONV2 is correct");
            CONV3_1:$display("Congratulations!, The CONV3_1 is correct");
            CONV3  :$display("Congratulations!, The CONV3 is correct");
            CONV4_1:$display("Congratulations!, The CONV4_1 is correct");
            CONV4_2:$display("Congratulations!, The CONV4_2 is correct");
            CONV4  :$display("Congratulations!, The CONV4 is correct");
            CONV5  :$display("Congratulations!, The CONV5 is correct");
            default:$display("Congratulations!, The CONV1 is correct");
        endcase
    end
    else begin
        $display("There are still some errors");
    end

end

// ====================================//

integer a, b;

reg signed [9:0] w1 [0:2];
reg signed [9:0] w2 [0:2];
reg signed [9:0] w3 [0:2];

reg signed [9:0] bias [0:2];
reg signed [17:0] bias2[0:2];
reg signed [9:0] f [0:2];
reg signed [21:0] out[0:2];
reg [21:0] out2[0:2];
reg [21:0] out3[0:2];
//assign w1[0] = sram_109x90b_weight.mem[0][80+:10];
//assign w1[1] = sram_109x90b_weight.mem[0][70+:10];
//assign w1[2] = sram_109x90b_weight.mem[0][60+:10];
//assign w2[0] = sram_109x90b_weight.mem[0][50+:10];
//assign w2[1] = sram_109x90b_weight.mem[0][40+:10];
//assign w2[2] = sram_109x90b_weight.mem[0][30+:10];
//assign w3[0] = sram_109x90b_weight.mem[0][20+:10];
//assign w3[1] = sram_109x90b_weight.mem[0][10+:10];
//assign w3[2] = sram_109x90b_weight.mem[0][ 0+:10];

//assign bias[0] = sram_24x10b_bias.mem[0];
//assign bias[1] = sram_24x10b_bias.mem[1];
//assign bias[2] = sram_24x10b_bias.mem[2];
//
//assign bias2[0] = {bias[0],8'd0};
//assign bias2[1] = {bias[1],8'd0};
//assign bias2[2] = {bias[2],8'd0};

initial begin
    for(a = 0 ; a < 576 ; a = a+1)begin
        for(b = 0 ; b < 720 ; b = b + 1)begin 
            if(a == 0 || a == 576-1 || b == 0 || b == 720-1)begin
                writesram(a,b,0,10'd0);
                writesram(a,b,1,10'd0);
                writesram(a,b,2,10'd0);
            end
            else begin
                readsram(a-1,b-1,0,f[0]);
                readsram(a-1,b-1,1,f[1]);
                readsram(a-1,b-1,2,f[2]);

                w1[0] = sram_109x90b_weight.mem[0][80+:10];
                w1[1] = sram_109x90b_weight.mem[0][70+:10];
                w1[2] = sram_109x90b_weight.mem[0][60+:10];

                w2[0] = sram_109x90b_weight.mem[0][50+:10];
                w2[1] = sram_109x90b_weight.mem[0][40+:10];
                w2[2] = sram_109x90b_weight.mem[0][30+:10];
                
                w3[0] = sram_109x90b_weight.mem[0][20+:10];
                w3[1] = sram_109x90b_weight.mem[0][10+:10];
                w3[2] = sram_109x90b_weight.mem[0][ 0+:10];

                bias[0] = sram_24x10b_bias.mem[0];
                bias[1] = sram_24x10b_bias.mem[1];
                bias[2] = sram_24x10b_bias.mem[2];
                
                
                bias2[0] = {bias[0],8'd0};
                bias2[1] = {bias[1],8'd0};
                bias2[2] = {bias[2],8'd0};


                out[0] = f[0] * w1[0] + 
                         f[1] * w1[1] +
                         f[2] * w1[2] + bias2[0];

                out[1] = f[0] * w2[0] + 
                         f[1] * w2[1] +
                         f[2] * w2[2] + bias2[1];
                
                out[2] = f[0] * w3[0] + 
                         f[1] * w3[1] +
                         f[2] * w3[2] + bias2[2];
                
                out2[0] = out[0] + 8'b1000_0000;
                out2[1] = out[1] + 8'b1000_0000;
                out2[2] = out[2] + 8'b1000_0000;
                  
                if(out2[0][21] == 1)begin
                end
                else begin
                    if(out2[0][21:17] != 5'b11111)begin
                        //overflow
                        out2 = 
                    end
                end
                writesram(a,b,0,out2[0][8+:10]);
                writesram(a,b,1,out2[1][8+:10]);
                writesram(a,b,2,out2[2][8+:10]);

            end
        end
    end
end


task writesram(
    input integer x,
    input integer y,
    input integer c,
    input [9:0] data_in
);
    if((x/3)%2 == 0 && (y/3)%2 == 0)begin
        sram_11520x270b_feat1_0.load_a_position((x/6)*120 + y/6, (2-c)*9 + (2-x%3)*3 + (2-y%3), data_in);
    end
    else if ((x/3)%2 == 0)begin
        sram_11520x270b_feat1_1.load_a_position((x/6)*120 + y/6, (2-c)*9 + (2-x%3)*3 + (2-y%3), data_in);
    end
    else if ((y/3)%2 == 0)begin
        sram_11520x270b_feat1_2.load_a_position((x/6)*120 + y/6, (2-c)*9 + (2-x%3)*3 + (2-y%3), data_in);
    end
    else begin
        sram_11520x270b_feat1_3.load_a_position((x/6)*120 + y/6, (2-c)*9 + (2-x%3)*3 + (2-y%3), data_in);
    end
endtask

task readsram(
    input integer x,
    input integer y,
    input integer c,
    output reg  [9:0] data_out
);
    begin
        if((x/3)%2 == 0 && (y/3)%2 == 0)begin
            data_out = sram_11520x270b_img_0.mem[(x/6)*120 + y/6][((2-c)*9 + (2-x%3)*3 + (2-y%3)) * 10 +: 10];
        end
        else if ((x/3)%2 == 0)begin
            data_out = sram_11520x270b_img_1.mem[(x/6)*120 + y/6][((2-c)*9 + (2-x%3)*3 + (2-y%3)) * 10 +: 10];
        end
        else if ((y/3)%2 == 0)begin
            data_out = sram_11520x270b_img_2.mem[(x/6)*120 + y/6][((2-c)*9 + (2-x%3)*3 + (2-y%3)) * 10 +: 10];
        end
        else begin
            data_out = sram_11520x270b_img_3.mem[(x/6)*120 + y/6][((2-c)*9 + (2-x%3)*3 + (2-y%3)) * 10 +: 10];
        end
    end
endtask

/*
 for(j = 0 ; j < 192; j = j + 1)begin
        for(k = 0 ; k < 240; k = k + 1)begin
            if(j % 2 == 0 && k % 2 == 0)begin
                sram_11520x270b_feat1_0.load_input_img((j/2)*120 + k/2, feat1_mem_placed[j*240 + k]);
            end
            else if (j % 2 == 0)begin
                sram_11520x270b_feat1_1.load_input_img((j/2)*120 + k/2, feat1_mem_placed[j*240 + k]);
            end
            else if (k % 2 == 0)begin
                sram_11520x270b_feat1_2.load_input_img((j/2)*120 + k/2, feat1_mem_placed[j*240 + k]);
            end
            else begin 
                sram_11520x270b_feat1_3.load_input_img((j/2)*120 + k/2, feat1_mem_placed[j*240 + k]);
            end
        end
    end

*/


endmodule


