module Conv_top #(
parameter CH_NUM = 4,
parameter ACT_PER_ADDR = 9,
parameter BW_PER_ACT = 10,
parameter WEIGHT_PER_ADDR = 9,
parameter BIAS_PER_ADDR = 1,
parameter BW_PER_WEIGHT = 8,
parameter BW_PER_BIAS = 8
)
(
input clk,
input rst_n,
output reg valid,

input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_img_0,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_img_1,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_img_2,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_img_3,

input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_feat1_0,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_feat1_1,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_feat1_2,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_feat1_3,

input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_feat2_0,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_feat2_1,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_feat2_2,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_feat2_3,

input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_feat3_0,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_feat3_1,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_feat3_2,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_feat3_3,

input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_feat4_0,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_feat4_1,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_feat4_2,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_feat4_3,

input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_feat5_0,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_feat5_1,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_feat5_2,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_feat5_3,

input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_temp_0,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_temp_1,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_temp_2,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_temp_3,

input [WEIGHT_PER_ADDR * BW_PER_WEIGHT-1:0] sram_rdata_weight,
input [BIAS_PER_ADDR * BW_PER_BIAS-1 : 0] sram_rdata_bias,

output reg [13:0] sram_raddr_img_0,
output reg [13:0] sram_raddr_img_1,
output reg [13:0] sram_raddr_img_2,
output reg [13:0] sram_raddr_img_3,

output reg [13:0] sram_raddr_feat1_0,
output reg [13:0] sram_raddr_feat1_1,
output reg [13:0] sram_raddr_feat1_2,
output reg [13:0] sram_raddr_feat1_3,

output reg [13:0] sram_raddr_feat2_0,
output reg [13:0] sram_raddr_feat2_1,
output reg [13:0] sram_raddr_feat2_2,
output reg [13:0] sram_raddr_feat2_3,

output reg [13:0] sram_raddr_feat3_0,
output reg [13:0] sram_raddr_feat3_1,
output reg [13:0] sram_raddr_feat3_2,
output reg [13:0] sram_raddr_feat3_3,

output reg [13:0] sram_raddr_feat4_0,
output reg [13:0] sram_raddr_feat4_1,
output reg [13:0] sram_raddr_feat4_2,
output reg [13:0] sram_raddr_feat4_3,

output reg [13:0] sram_raddr_feat5_0,
output reg [13:0] sram_raddr_feat5_1,
output reg [13:0] sram_raddr_feat5_2,
output reg [13:0] sram_raddr_feat5_3,

output reg [13:0] sram_raddr_temp_0,
output reg [13:0] sram_raddr_temp_1,
output reg [13:0] sram_raddr_temp_2,
output reg [13:0] sram_raddr_temp_3,

output reg [6:0] sram_raddr_weight,
output reg [4:0] sram_raddr_bias,

output reg sram_wen_feat1_0,
output reg sram_wen_feat1_1,
output reg sram_wen_feat1_2,
output reg sram_wen_feat1_3,
output reg sram_wen_feat2_0,
output reg sram_wen_feat2_1,
output reg sram_wen_feat2_2,
output reg sram_wen_feat2_3,
output reg sram_wen_feat3_0,
output reg sram_wen_feat3_1,
output reg sram_wen_feat3_2,
output reg sram_wen_feat3_3,
output reg sram_wen_feat4_0,
output reg sram_wen_feat4_1,
output reg sram_wen_feat4_2,
output reg sram_wen_feat4_3,
output reg sram_wen_feat5_0,
output reg sram_wen_feat5_1,
output reg sram_wen_feat5_2,
output reg sram_wen_feat5_3,
output reg sram_wen_temp_0,
output reg sram_wen_temp_1,
output reg sram_wen_temp_2,
output reg sram_wen_temp_3,

output reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_feat1,
output reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_feat2,
output reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_feat3,
output reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_feat4,
output reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_feat5,
output reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_temp,

output reg [13:0] sram_waddr_feat1,
output reg [13:0] sram_waddr_feat2,
output reg [13:0] sram_waddr_feat3,
output reg [13:0] sram_waddr_feat4,
output reg [13:0] sram_waddr_feat5,
output reg [13:0] sram_waddr_temp,

output reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_feat1,
output reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_feat2,
output reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_feat3,
output reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_feat4,
output reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_feat5,
output reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_temp
);




endmodule

