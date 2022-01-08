module Conv_top #(
parameter CH_NUM = 3,
parameter ACT_PER_ADDR = 9,
parameter BW_PER_ACT = 10,
parameter WEIGHT_PER_ADDR = 9,
parameter BIAS_PER_ADDR = 1,
parameter BW_PER_WEIGHT = 10,
parameter BW_PER_BIAS = 10
)
(
input clk,
input rst_n,
input enable,

output reg valid,

input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_0,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_1,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_2,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_3,

input [WEIGHT_PER_ADDR * BW_PER_WEIGHT-1:0] sram_rdata_weight,
input [BIAS_PER_ADDR * BW_PER_BIAS-1 : 0] sram_rdata_bias,

output reg [8:0] sram_raddr_0,
output reg [8:0] sram_raddr_1,
output reg [8:0] sram_raddr_2,
output reg [8:0] sram_raddr_3,

output reg [6:0] sram_raddr_weight,
output reg [4:0] sram_raddr_bias,

output reg sram_wen_0,
output reg sram_wen_1,
output reg sram_wen_2,
output reg sram_wen_3,

output reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask,

output reg [6:0] sram_waddr,

output reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata,

output reg valid_conv1,

input shift_finish
);

localparam [4:0] IDLE = 0;
localparam [4:0] BLANK = 1;
localparam [4:0] CONV1 = 2;
localparam [4:0] WAIT_SHIFT_MEM = 3;
localparam [4:0] BLANK2 = 4;
localparam [4:0] CONV2 = 5;
localparam [4:0] WAIT_SHIFT_MEM2 = 6;
localparam [4:0] BLANK3_1 = 7;
localparam [4:0] CONV3_1 = 8;
localparam [4:0] WAIT_SHIFT_MEM3_1 = 9;
localparam [4:0] BLANK3 = 10;
localparam [4:0] CONV3 = 11;
localparam [4:0] WAIT_SHIFT_MEM3 = 12;
localparam [4:0] BLANK4_1 = 13;
localparam [4:0] CONV4_1 = 14;
localparam [4:0] WAIT_SHIFT_MEM4_1 = 15;
localparam [4:0] BLANK4_2 = 16;
localparam [4:0] CONV4_2 = 17;
localparam [4:0] WAIT_SHIFT_MEM4_2 = 18;
localparam [4:0] BLANK4 = 19;
localparam [4:0] CONV4 = 20;
localparam [4:0] WAIT_SHIFT_MEM4 = 21;
localparam [4:0] BLANK5 = 22;
localparam [4:0] CONV5 = 23;
localparam [4:0] WAIT_SHIFT_MEM5 = 24;
localparam [4:0] FINISH = 25;


reg [8:0] sram_raddr_0_n;
reg [8:0] sram_raddr_1_n;
reg [8:0] sram_raddr_2_n;
reg [8:0] sram_raddr_3_n;
reg [6:0] sram_raddr_weight_n;
reg [4:0] sram_raddr_bias_n;

reg sram_wen_0_n;
reg sram_wen_1_n;
reg sram_wen_2_n;
reg sram_wen_3_n;

reg [27-1:0] sram_wordmask_n;
reg [6:0] sram_waddr_n;
reg [270-1:0] sram_wdata_n;
reg valid_n;
reg valid_conv1_n;


reg [4:0] state, state_n;
reg [3:0] in_cnt, in_cnt_n;


reg [9:0] w_n [0:9-1];
reg signed [9:0] w [0:9-1];

reg [9:0] f_n [0:27-1];
reg signed [9:0] f [0:27-1];

reg signed [17:0] b [0:2];

reg [270-1:0] in;

reg signed [20-1:0] mul_result_n[0:81-1];
reg signed [20-1:0] mul_result[0:81-1];

reg signed [25:0] sum_n [0:9-1];
reg signed [25:0] sum [0:9-1];

reg [25:0] unsigned_sum[0:9-1];
reg [25:0] out [0:9-1];


reg [4:0] in_x, in_y;
reg [4:0] in_x_n, in_y_n;
reg [4:0] x,y;
reg [4:0] x_n,y_n;
reg [4:0] x_delay[0:2];
reg [4:0] y_delay[0:2];




reg [1:0] weight_cnt, weight_cnt_n;
reg [1:0] weight_cnt_delay [0:16];



reg [3:0] layer_cnt;

reg [1:0] word_mask_det;



integer i,j,k,l,m,n,o,p,q,r,s,t;


//wire [6:0] x_d2 = x_delay[2];
//wire [6:0] y_d2 = y_delay[2];
//wire [1:0] test_delay = {x_delay[2][0],y_delay[2][0]};
//wire [1:0] test = {y[0],x[0]};

/* ============ output register ============= */

always@(posedge clk)begin
    sram_raddr_0 <= sram_raddr_0_n;
    sram_raddr_1 <= sram_raddr_1_n;
    sram_raddr_2 <= sram_raddr_2_n;
    sram_raddr_3 <= sram_raddr_3_n;
    sram_raddr_weight <= sram_raddr_weight_n;
    sram_raddr_bias <= sram_raddr_bias_n;

    sram_wen_0 <= sram_wen_0_n;
    sram_wen_1 <= sram_wen_1_n;
    sram_wen_2 <= sram_wen_2_n;
    sram_wen_3 <= sram_wen_3_n;

    sram_wordmask <= sram_wordmask_n;
    sram_waddr <= sram_waddr_n;
    sram_wdata <= sram_wdata_n;
    
    valid <= valid_n;
end

/* ========================================== */



always@(*)begin
    if(state == CONV3_1 || state == CONV4_1)begin
        layer_cnt = (in_cnt >=3) ? in_cnt - 3 : in_cnt;
    end
    else if (state == CONV5)begin
        layer_cnt = (in_cnt < 3)? in_cnt : (in_cnt < 6)? in_cnt -3 : (in_cnt < 9)? in_cnt-6 : in_cnt-9;
    end
    else begin
        layer_cnt = in_cnt;
    end
end

always@(*)begin
    if(state == CONV1)begin
        case({y[0],x[0]})
            2'b00:begin
                in = sram_rdata_0;
            end
            2'b01:begin
                in = sram_rdata_1;
            end
            2'b10:begin
                in = sram_rdata_2;
            end
            2'b11:begin
                in = sram_rdata_3;
            end
            default:begin
                in = 0;
            end
        endcase
    end
    else begin
        case({y[0],x[0]})
            2'b00:begin
                in[ 0*10 +: 10] = sram_rdata_0[(9*(2-layer_cnt) + 8)*10 +: 10];
                in[ 1*10 +: 10] = sram_rdata_0[(9*(2-layer_cnt) + 7)*10 +: 10];
                in[ 2*10 +: 10] = sram_rdata_0[(9*(2-layer_cnt) + 6)*10 +: 10];
                in[ 3*10 +: 10] = sram_rdata_1[(9*(2-layer_cnt) + 8)*10 +: 10];
                in[ 4*10 +: 10] = sram_rdata_1[(9*(2-layer_cnt) + 7)*10 +: 10];
                in[ 5*10 +: 10] = sram_rdata_0[(9*(2-layer_cnt) + 5)*10 +: 10];
                in[ 6*10 +: 10] = sram_rdata_0[(9*(2-layer_cnt) + 4)*10 +: 10];
                in[ 7*10 +: 10] = sram_rdata_0[(9*(2-layer_cnt) + 3)*10 +: 10];
                in[ 8*10 +: 10] = sram_rdata_1[(9*(2-layer_cnt) + 5)*10 +: 10];
                in[ 9*10 +: 10] = sram_rdata_1[(9*(2-layer_cnt) + 4)*10 +: 10];
                in[10*10 +: 10] = sram_rdata_0[(9*(2-layer_cnt) + 2)*10 +: 10];
                in[11*10 +: 10] = sram_rdata_0[(9*(2-layer_cnt) + 1)*10 +: 10];
                in[12*10 +: 10] = sram_rdata_0[(9*(2-layer_cnt) + 0)*10 +: 10];
                in[13*10 +: 10] = sram_rdata_1[(9*(2-layer_cnt) + 2)*10 +: 10];
                in[14*10 +: 10] = sram_rdata_1[(9*(2-layer_cnt) + 1)*10 +: 10];
                in[15*10 +: 10] = sram_rdata_2[(9*(2-layer_cnt) + 8)*10 +: 10];
                in[16*10 +: 10] = sram_rdata_2[(9*(2-layer_cnt) + 7)*10 +: 10];
                in[17*10 +: 10] = sram_rdata_2[(9*(2-layer_cnt) + 6)*10 +: 10];
                in[18*10 +: 10] = sram_rdata_3[(9*(2-layer_cnt) + 8)*10 +: 10];
                in[19*10 +: 10] = sram_rdata_3[(9*(2-layer_cnt) + 7)*10 +: 10];
                in[20*10 +: 10] = sram_rdata_2[(9*(2-layer_cnt) + 5)*10 +: 10];
                in[21*10 +: 10] = sram_rdata_2[(9*(2-layer_cnt) + 4)*10 +: 10];
                in[22*10 +: 10] = sram_rdata_2[(9*(2-layer_cnt) + 3)*10 +: 10];
                in[23*10 +: 10] = sram_rdata_3[(9*(2-layer_cnt) + 5)*10 +: 10];
                in[24*10 +: 10] = sram_rdata_3[(9*(2-layer_cnt) + 4)*10 +: 10];
            end                                      
            2'b01:begin                             
                in[ 0*10 +: 10] = sram_rdata_1[(9*(2-layer_cnt) + 8)*10 +: 10];
                in[ 1*10 +: 10] = sram_rdata_1[(9*(2-layer_cnt) + 7)*10 +: 10];
                in[ 2*10 +: 10] = sram_rdata_1[(9*(2-layer_cnt) + 6)*10 +: 10];
                in[ 3*10 +: 10] = sram_rdata_0[(9*(2-layer_cnt) + 8)*10 +: 10];
                in[ 4*10 +: 10] = sram_rdata_0[(9*(2-layer_cnt) + 7)*10 +: 10];
                in[ 5*10 +: 10] = sram_rdata_1[(9*(2-layer_cnt) + 5)*10 +: 10];
                in[ 6*10 +: 10] = sram_rdata_1[(9*(2-layer_cnt) + 4)*10 +: 10];
                in[ 7*10 +: 10] = sram_rdata_1[(9*(2-layer_cnt) + 3)*10 +: 10];
                in[ 8*10 +: 10] = sram_rdata_0[(9*(2-layer_cnt) + 5)*10 +: 10];
                in[ 9*10 +: 10] = sram_rdata_0[(9*(2-layer_cnt) + 4)*10 +: 10]; 
                in[10*10 +: 10] = sram_rdata_1[(9*(2-layer_cnt) + 2)*10 +: 10];
                in[11*10 +: 10] = sram_rdata_1[(9*(2-layer_cnt) + 1)*10 +: 10];
                in[12*10 +: 10] = sram_rdata_1[(9*(2-layer_cnt) + 0)*10 +: 10];
                in[13*10 +: 10] = sram_rdata_0[(9*(2-layer_cnt) + 2)*10 +: 10];
                in[14*10 +: 10] = sram_rdata_0[(9*(2-layer_cnt) + 1)*10 +: 10];
                in[15*10 +: 10] = sram_rdata_3[(9*(2-layer_cnt) + 8)*10 +: 10];
                in[16*10 +: 10] = sram_rdata_3[(9*(2-layer_cnt) + 7)*10 +: 10];
                in[17*10 +: 10] = sram_rdata_3[(9*(2-layer_cnt) + 6)*10 +: 10];
                in[18*10 +: 10] = sram_rdata_2[(9*(2-layer_cnt) + 8)*10 +: 10];
                in[19*10 +: 10] = sram_rdata_2[(9*(2-layer_cnt) + 7)*10 +: 10];
                in[20*10 +: 10] = sram_rdata_3[(9*(2-layer_cnt) + 5)*10 +: 10];
                in[21*10 +: 10] = sram_rdata_3[(9*(2-layer_cnt) + 4)*10 +: 10];
                in[22*10 +: 10] = sram_rdata_3[(9*(2-layer_cnt) + 3)*10 +: 10];
                in[23*10 +: 10] = sram_rdata_2[(9*(2-layer_cnt) + 5)*10 +: 10];
                in[24*10 +: 10] = sram_rdata_2[(9*(2-layer_cnt) + 4)*10 +: 10];

            end
            2'b10:begin
                in[ 0*10 +: 10] = sram_rdata_2[(9*(2-layer_cnt) + 8)*10 +: 10];
                in[ 1*10 +: 10] = sram_rdata_2[(9*(2-layer_cnt) + 7)*10 +: 10];
                in[ 2*10 +: 10] = sram_rdata_2[(9*(2-layer_cnt) + 6)*10 +: 10];
                in[ 3*10 +: 10] = sram_rdata_3[(9*(2-layer_cnt) + 8)*10 +: 10];
                in[ 4*10 +: 10] = sram_rdata_3[(9*(2-layer_cnt) + 7)*10 +: 10];
                in[ 5*10 +: 10] = sram_rdata_2[(9*(2-layer_cnt) + 5)*10 +: 10];
                in[ 6*10 +: 10] = sram_rdata_2[(9*(2-layer_cnt) + 4)*10 +: 10];
                in[ 7*10 +: 10] = sram_rdata_2[(9*(2-layer_cnt) + 3)*10 +: 10];
                in[ 8*10 +: 10] = sram_rdata_3[(9*(2-layer_cnt) + 5)*10 +: 10];
                in[ 9*10 +: 10] = sram_rdata_3[(9*(2-layer_cnt) + 4)*10 +: 10];     
                in[10*10 +: 10] = sram_rdata_2[(9*(2-layer_cnt) + 2)*10 +: 10];
                in[11*10 +: 10] = sram_rdata_2[(9*(2-layer_cnt) + 1)*10 +: 10];
                in[12*10 +: 10] = sram_rdata_2[(9*(2-layer_cnt) + 0)*10 +: 10];
                in[13*10 +: 10] = sram_rdata_3[(9*(2-layer_cnt) + 2)*10 +: 10];
                in[14*10 +: 10] = sram_rdata_3[(9*(2-layer_cnt) + 1)*10 +: 10];
                in[15*10 +: 10] = sram_rdata_0[(9*(2-layer_cnt) + 8)*10 +: 10];
                in[16*10 +: 10] = sram_rdata_0[(9*(2-layer_cnt) + 7)*10 +: 10];
                in[17*10 +: 10] = sram_rdata_0[(9*(2-layer_cnt) + 6)*10 +: 10];
                in[18*10 +: 10] = sram_rdata_1[(9*(2-layer_cnt) + 8)*10 +: 10];
                in[19*10 +: 10] = sram_rdata_1[(9*(2-layer_cnt) + 7)*10 +: 10];
                in[20*10 +: 10] = sram_rdata_0[(9*(2-layer_cnt) + 5)*10 +: 10];
                in[21*10 +: 10] = sram_rdata_0[(9*(2-layer_cnt) + 4)*10 +: 10];
                in[22*10 +: 10] = sram_rdata_0[(9*(2-layer_cnt) + 3)*10 +: 10];
                in[23*10 +: 10] = sram_rdata_1[(9*(2-layer_cnt) + 5)*10 +: 10];
                in[24*10 +: 10] = sram_rdata_1[(9*(2-layer_cnt) + 4)*10 +: 10];

            end
            default:begin
                in[ 0*10 +: 10] = sram_rdata_3[(9*(2-layer_cnt) + 8)*10 +: 10];
                in[ 1*10 +: 10] = sram_rdata_3[(9*(2-layer_cnt) + 7)*10 +: 10];
                in[ 2*10 +: 10] = sram_rdata_3[(9*(2-layer_cnt) + 6)*10 +: 10];
                in[ 3*10 +: 10] = sram_rdata_2[(9*(2-layer_cnt) + 8)*10 +: 10];
                in[ 4*10 +: 10] = sram_rdata_2[(9*(2-layer_cnt) + 7)*10 +: 10];
                in[ 5*10 +: 10] = sram_rdata_3[(9*(2-layer_cnt) + 5)*10 +: 10];
                in[ 6*10 +: 10] = sram_rdata_3[(9*(2-layer_cnt) + 4)*10 +: 10];
                in[ 7*10 +: 10] = sram_rdata_3[(9*(2-layer_cnt) + 3)*10 +: 10];
                in[ 8*10 +: 10] = sram_rdata_2[(9*(2-layer_cnt) + 5)*10 +: 10];
                in[ 9*10 +: 10] = sram_rdata_2[(9*(2-layer_cnt) + 4)*10 +: 10];
                in[10*10 +: 10] = sram_rdata_3[(9*(2-layer_cnt) + 2)*10 +: 10];
                in[11*10 +: 10] = sram_rdata_3[(9*(2-layer_cnt) + 1)*10 +: 10];
                in[12*10 +: 10] = sram_rdata_3[(9*(2-layer_cnt) + 0)*10 +: 10];
                in[13*10 +: 10] = sram_rdata_2[(9*(2-layer_cnt) + 2)*10 +: 10];
                in[14*10 +: 10] = sram_rdata_2[(9*(2-layer_cnt) + 1)*10 +: 10];
                in[15*10 +: 10] = sram_rdata_1[(9*(2-layer_cnt) + 8)*10 +: 10];
                in[16*10 +: 10] = sram_rdata_1[(9*(2-layer_cnt) + 7)*10 +: 10];
                in[17*10 +: 10] = sram_rdata_1[(9*(2-layer_cnt) + 6)*10 +: 10];
                in[18*10 +: 10] = sram_rdata_0[(9*(2-layer_cnt) + 8)*10 +: 10];
                in[19*10 +: 10] = sram_rdata_0[(9*(2-layer_cnt) + 7)*10 +: 10];
                in[20*10 +: 10] = sram_rdata_1[(9*(2-layer_cnt) + 5)*10 +: 10];
                in[21*10 +: 10] = sram_rdata_1[(9*(2-layer_cnt) + 4)*10 +: 10];
                in[22*10 +: 10] = sram_rdata_1[(9*(2-layer_cnt) + 3)*10 +: 10];
                in[23*10 +: 10] = sram_rdata_0[(9*(2-layer_cnt) + 5)*10 +: 10];
                in[24*10 +: 10] = sram_rdata_0[(9*(2-layer_cnt) + 4)*10 +: 10];
            end
        endcase
        in[25*10 +: 10] = 10'd0;
        in[26*10 +: 10] = 10'd0; 
    end
end

always@(*)begin
    if(state == CONV1)begin
        for(i = 0 ; i < 27 ; i = i + 1)begin
            f_n[i] = in[10*i +: 10];
        end
    end
    else begin
        for(i = 0 ; i < 5 ; i = i + 1)begin
            for(t = 0 ; t < 5 ; t = t + 1)begin
                f_n[i*5+t] = in[(i*5+t)*10 +: 10];
            end
        end
        f_n[25] = 0;
        f_n[26] = 0;
    end
end

always@(posedge clk)begin
    for(j = 0 ; j < 27 ; j = j + 1)begin
        f[j] <= f_n[j];
    end
end

always@(*)begin
    if(state == CONV1)begin
        for(k = 0 ; k<9 ; k = k + 1)begin
            w_n[k] = sram_rdata_weight[k*10 +: 10];
        end
    end
    else begin
        for(k = 0 ; k < 9 ; k = k + 1)begin
            w_n[k] = sram_rdata_weight[k*10 +: 10];
        end
    end
end

always@(posedge clk)begin
    for(l = 0 ; l < 9 ; l = l + 1)begin
        w[l] <= w_n[l];
    end
end

always@(posedge clk)begin
    b[0] <= {sram_rdata_bias,8'd0};
end









always@(*)begin
    if(state == CONV1)begin
        if (weight_cnt_delay[2] == 0)begin
            for(m = 0 ; m < 9 ; m = m + 1)begin
                for(n = 0 ; n < 3 ; n = n + 1)begin
                    mul_result_n[m*3 + n] = f[9*(n+1)-m-1] * w[n+6];
                end
            end
        end
        else if (weight_cnt_delay[2] == 1)begin
            for(m = 0 ; m < 9 ; m = m + 1)begin
                for(n = 0 ; n < 3 ; n = n + 1)begin
                    mul_result_n[m*3 + n] = f[9*(n+1)-m-1] * w[n+3];
                end
            end
        end
        else begin
            for(m = 0 ; m < 9 ; m = m + 1)begin
                for(n = 0 ; n < 3 ; n = n + 1)begin
                    mul_result_n[m*3 + n] = f[9*(n+1)-m-1] * w[n];
                end
            end
        end

        for (m = 27; m < 81 ; m = m + 1)begin
            mul_result_n[m] = 0;
        end
    end
    else begin
        for(m = 0 ; m < 3 ; m = m + 1)begin
            for(n = 0 ; n < 3 ; n = n + 1)begin
                mul_result_n[m*3+n + 0] = f[m*5+n] * w[8-(m*3+n)];
            end
        end
        for(m = 0 ; m < 3 ; m = m + 1)begin
            for(n = 0 ; n < 3 ; n = n + 1)begin
                mul_result_n[m*3+n + 9] = f[m*5+n+1] * w[8-(m*3+n)];
            end
        end
        for(m = 0 ; m < 3 ; m = m + 1)begin
            for(n = 0 ; n < 3 ; n = n + 1)begin
                mul_result_n[m*3+n + 18] = f[m*5+n+2] * w[8-(m*3+n)];
            end
        end
        for(m = 0 ; m < 3 ; m = m + 1)begin
            for(n = 0 ; n < 3 ; n = n + 1)begin
                mul_result_n[m*3+n + 27] = f[(m+1)*5+n] * w[8-(m*3+n)];
            end
        end
        for(m = 0 ; m < 3 ; m = m + 1)begin
            for(n = 0 ; n < 3 ; n = n + 1)begin
                mul_result_n[m*3+n + 36] = f[(m+1)*5+n+1] * w[8-(m*3+n)];
            end
        end
        for(m = 0 ; m < 3 ; m = m + 1)begin
            for(n = 0 ; n < 3 ; n = n + 1)begin
                mul_result_n[m*3+n + 45] = f[(m+1)*5+n+2] * w[8-(m*3+n)];
            end
        end
        for(m = 0 ; m < 3 ; m = m + 1)begin
            for(n = 0 ; n < 3 ; n = n + 1)begin
                mul_result_n[m*3+n + 54] = f[(m+2)*5+n] * w[8-(m*3+n)];
            end
        end
        for(m = 0 ; m < 3 ; m = m + 1)begin
            for(n = 0 ; n < 3 ; n = n + 1)begin
                mul_result_n[m*3+n + 63] = f[(m+2)*5+n+1] * w[8-(m*3+n)];
            end
        end
        for(m = 0 ; m < 3 ; m = m + 1)begin
            for(n = 0 ; n < 3 ; n = n + 1)begin
                mul_result_n[m*3+n + 72] = f[(m+2)*5+n+2] * w[8-(m*3+n)];
            end
        end
    end
end

















always@(posedge clk)begin
    for(o = 0; o < 81 ; o = o + 1)begin
        mul_result[o] <= mul_result_n[o];
    end
end

always@(*)begin
    if(state == CONV1)begin
        for(p = 0 ; p < 9; p = p + 1)begin
            sum_n[p] = mul_result[p*3 + 0] + mul_result[p*3 + 1] + mul_result[p*3 + 2] + b[0]; 
        end
    end
    else begin
        for(s = 0 ; s < 9 ; s = s + 1)begin
            sum_n[s] = mul_result[s*9 + 0] + mul_result[s*9 + 1] + mul_result[s*9 + 2] + 
                       mul_result[s*9 + 3] + mul_result[s*9 + 4] + mul_result[s*9 + 5] + 
                       mul_result[s*9 + 6] + mul_result[s*9 + 7] + mul_result[s*9 + 8];
        end
    end
end

always@(posedge clk)begin
    if(state == CONV1)begin
        for(q = 0 ; q < 9 ; q = q + 1)begin
            sum[q] <= sum_n[q];
        end
    end
    else begin
        for(q = 0 ; q < 9 ; q = q + 1)begin
            sum[q] <= (in_cnt == 2)? b[0] + sum_n[q] : sum[q] + sum_n[q];
        end
    end
end

always@(*)begin
    for(r = 0 ; r < 9 ; r = r + 1)begin
        unsigned_sum[r] = sum[r];
    end
    
    for(r = 0 ; r < 9 ; r = r + 1)begin
        out[r] = unsigned_sum[r] + 8'b1000_0000;
    end

    for(r = 0 ; r < 9 ;r = r + 1)begin
        sram_wdata_n[((8-r)+18)*10 +: 10] = out[r][8+:10];
    end
    for(r = 0 ; r < 9 ;r = r + 1)begin
        sram_wdata_n[((8-r)+9)*10 +: 10] = out[r][8+:10];
    end
    for(r = 0 ; r < 9 ;r = r + 1)begin
        sram_wdata_n[((8-r))*10 +: 10] = out[r][8+:10];
    end
end

always@(*)begin
    if(state == CONV1)begin
        sram_wen_0_n = ~(x_delay[2][0]==0 & y_delay[2][0]==0);
        sram_wen_1_n = ~(x_delay[2][0]==1 & y_delay[2][0]==0);
        sram_wen_2_n = ~(x_delay[2][0]==0 & y_delay[2][0]==1);
        sram_wen_3_n = ~(x_delay[2][0]==1 & y_delay[2][0]==1);        
    end
    else begin
        sram_wen_0_n = (in_cnt == 2) ? ~(x_delay[2][0]==0 & y_delay[2][0]==0) : 1;
        sram_wen_1_n = (in_cnt == 2) ? ~(x_delay[2][0]==1 & y_delay[2][0]==0) : 1;
        sram_wen_2_n = (in_cnt == 2) ? ~(x_delay[2][0]==0 & y_delay[2][0]==1) : 1;
        sram_wen_3_n = (in_cnt == 2) ? ~(x_delay[2][0]==1 & y_delay[2][0]==1) : 1;        
    end
end


always@(*)begin
    case(state)
        CONV1:begin
            word_mask_det = weight_cnt_delay[4];
        end
        CONV2:begin
            word_mask_det = weight_cnt_delay[4];
        end
        CONV3_1:begin
            word_mask_det = weight_cnt_delay[7]; 
        end
        CONV3:begin
            word_mask_det = weight_cnt_delay[4];
        end
        CONV4_1:begin
            word_mask_det = weight_cnt_delay[7];
        end
        CONV4_2:begin
            word_mask_det = weight_cnt_delay[4];
        end
        CONV4:begin
            word_mask_det = weight_cnt_delay[4];
        end
        default:begin
            word_mask_det = weight_cnt_delay[13];
        end
    endcase

end


always@(*)begin
    sram_wordmask_n[ 0] = ~(word_mask_det==2); 
    sram_wordmask_n[ 1] = ~(word_mask_det==2); 
    sram_wordmask_n[ 2] = ~(word_mask_det==2); 
    sram_wordmask_n[ 3] = ~(word_mask_det==2); 
    sram_wordmask_n[ 4] = ~(word_mask_det==2); 
    sram_wordmask_n[ 5] = ~(word_mask_det==2); 
    sram_wordmask_n[ 6] = ~(word_mask_det==2); 
    sram_wordmask_n[ 7] = ~(word_mask_det==2); 
    sram_wordmask_n[ 8] = ~(word_mask_det==2);      
    sram_wordmask_n[ 9] = ~(word_mask_det==1); 
    sram_wordmask_n[10] = ~(word_mask_det==1); 
    sram_wordmask_n[11] = ~(word_mask_det==1); 
    sram_wordmask_n[12] = ~(word_mask_det==1); 
    sram_wordmask_n[13] = ~(word_mask_det==1); 
    sram_wordmask_n[14] = ~(word_mask_det==1); 
    sram_wordmask_n[15] = ~(word_mask_det==1); 
    sram_wordmask_n[16] = ~(word_mask_det==1); 
    sram_wordmask_n[17] = ~(word_mask_det==1);       
    sram_wordmask_n[18] = ~(word_mask_det==0); 
    sram_wordmask_n[19] = ~(word_mask_det==0); 
    sram_wordmask_n[20] = ~(word_mask_det==0); 
    sram_wordmask_n[21] = ~(word_mask_det==0); 
    sram_wordmask_n[22] = ~(word_mask_det==0); 
    sram_wordmask_n[23] = ~(word_mask_det==0); 
    sram_wordmask_n[24] = ~(word_mask_det==0); 
    sram_wordmask_n[25] = ~(word_mask_det==0); 
    sram_wordmask_n[26] = ~(word_mask_det==0); 
end


always@(*)begin
    if(state == IDLE)begin
        weight_cnt_n = 0;
    end
    else if(state == CONV1 || state == CONV2 || state == CONV3_1 || state == CONV3 || state == CONV4_1 || state == CONV4_2 || state == CONV4 || state == CONV5)begin
        weight_cnt_n = (in_x == 19 && in_y == 15 && in_cnt == 0)? (weight_cnt == 2) ? 0 : weight_cnt + 1 : weight_cnt;
    end
    else begin
        weight_cnt_n = weight_cnt;
    end
end



always@(*)begin
    sram_waddr_n = x_delay[2][4:1] + y_delay[2][4:1]*10;
end


always@(*)begin
    if(state == IDLE || state == BLANK || state == CONV1)begin
        sram_raddr_0_n = in_x[4:1] + in_y[4:1]*10;
        sram_raddr_1_n = in_x[4:1] + in_y[4:1]*10;
        sram_raddr_2_n = in_x[4:1] + in_y[4:1]*10;
        sram_raddr_3_n = in_x[4:1] + in_y[4:1]*10;
    end
    else if (state == BLANK2 || state == CONV2) begin
        sram_raddr_0_n = in_x[4:1] + in_x[0] + (in_y[4:1] + in_y[0]) * 10 + 80;
        sram_raddr_1_n = in_x[4:1]           + (in_y[4:1] + in_y[0]) * 10 + 80;
        sram_raddr_2_n = in_x[4:1] + in_x[0] + (in_y[4:1]          ) * 10 + 80;
        sram_raddr_3_n = in_x[4:1]           + (in_y[4:1]          ) * 10 + 80;
    end
    else if (state == BLANK3_1 || state == CONV3_1) begin

        if(in_cnt == 1 || in_cnt == 2 || in_cnt == 3)begin
            sram_raddr_0_n = in_x[4:1] + in_x[0] + (in_y[4:1] + in_y[0]) * 10 + 160;
            sram_raddr_1_n = in_x[4:1]           + (in_y[4:1] + in_y[0]) * 10 + 160;
            sram_raddr_2_n = in_x[4:1] + in_x[0] + (in_y[4:1]          ) * 10 + 160;
            sram_raddr_3_n = in_x[4:1]           + (in_y[4:1]          ) * 10 + 160;
        end
        else begin
            sram_raddr_0_n = in_x[4:1] + in_x[0] + (in_y[4:1] + in_y[0]) * 10 + 80;
            sram_raddr_1_n = in_x[4:1]           + (in_y[4:1] + in_y[0]) * 10 + 80;
            sram_raddr_2_n = in_x[4:1] + in_x[0] + (in_y[4:1]          ) * 10 + 80;
            sram_raddr_3_n = in_x[4:1]           + (in_y[4:1]          ) * 10 + 80;
        end
    end
    else if (state == BLANK3 || state == CONV3) begin
        sram_raddr_0_n = in_x[4:1] + in_x[0] + (in_y[4:1] + in_y[0]) * 10 + 400;
        sram_raddr_1_n = in_x[4:1]           + (in_y[4:1] + in_y[0]) * 10 + 400;
        sram_raddr_2_n = in_x[4:1] + in_x[0] + (in_y[4:1]          ) * 10 + 400;
        sram_raddr_3_n = in_x[4:1]           + (in_y[4:1]          ) * 10 + 400;
    end
    
    else if (state == BLANK4_1 || state == CONV4_1)begin

        if(in_cnt == 1 || in_cnt == 2 || in_cnt == 3)begin
            sram_raddr_0_n = in_x[4:1] + in_x[0] + (in_y[4:1] + in_y[0]) * 10 + 240;
            sram_raddr_1_n = in_x[4:1]           + (in_y[4:1] + in_y[0]) * 10 + 240;
            sram_raddr_2_n = in_x[4:1] + in_x[0] + (in_y[4:1]          ) * 10 + 240;
            sram_raddr_3_n = in_x[4:1]           + (in_y[4:1]          ) * 10 + 240;
        end
        else begin
            sram_raddr_0_n = in_x[4:1] + in_x[0] + (in_y[4:1] + in_y[0]) * 10 + 160;
            sram_raddr_1_n = in_x[4:1]           + (in_y[4:1] + in_y[0]) * 10 + 160;
            sram_raddr_2_n = in_x[4:1] + in_x[0] + (in_y[4:1]          ) * 10 + 160;
            sram_raddr_3_n = in_x[4:1]           + (in_y[4:1]          ) * 10 + 160;
        end
    end
    else if (state == BLANK4_2 || state == CONV4_2)begin 
        sram_raddr_0_n = in_x[4:1] + in_x[0] + (in_y[4:1] + in_y[0]) * 10 + 320;
        sram_raddr_1_n = in_x[4:1]           + (in_y[4:1] + in_y[0]) * 10 + 320;
        sram_raddr_2_n = in_x[4:1] + in_x[0] + (in_y[4:1]          ) * 10 + 320;
        sram_raddr_3_n = in_x[4:1]           + (in_y[4:1]          ) * 10 + 320;
    end
    else if (state == BLANK4 || state == CONV4) begin
        sram_raddr_0_n = in_x[4:1] + in_x[0] + (in_y[4:1] + in_y[0]) * 10 + 400;
        sram_raddr_1_n = in_x[4:1]           + (in_y[4:1] + in_y[0]) * 10 + 400;
        sram_raddr_2_n = in_x[4:1] + in_x[0] + (in_y[4:1]          ) * 10 + 400;
        sram_raddr_3_n = in_x[4:1]           + (in_y[4:1]          ) * 10 + 400;
    end
    else begin
        if(in_cnt == 7 || in_cnt == 8 || in_cnt == 9)begin
            sram_raddr_0_n = in_x[4:1] + in_x[0] + (in_y[4:1] + in_y[0]) * 10 + 320;
            sram_raddr_1_n = in_x[4:1]           + (in_y[4:1] + in_y[0]) * 10 + 320;
            sram_raddr_2_n = in_x[4:1] + in_x[0] + (in_y[4:1]          ) * 10 + 320;
            sram_raddr_3_n = in_x[4:1]           + (in_y[4:1]          ) * 10 + 320;
        end
        else if (in_cnt == 4 || in_cnt == 5 || in_cnt == 6)begin
            sram_raddr_0_n = in_x[4:1] + in_x[0] + (in_y[4:1] + in_y[0]) * 10 + 240;
            sram_raddr_1_n = in_x[4:1]           + (in_y[4:1] + in_y[0]) * 10 + 240;
            sram_raddr_2_n = in_x[4:1] + in_x[0] + (in_y[4:1]          ) * 10 + 240;
            sram_raddr_3_n = in_x[4:1]           + (in_y[4:1]          ) * 10 + 240;
        end
        else if(in_cnt == 1 || in_cnt == 2 || in_cnt == 3)begin
            sram_raddr_0_n = in_x[4:1] + in_x[0] + (in_y[4:1] + in_y[0]) * 10 + 160;
            sram_raddr_1_n = in_x[4:1]           + (in_y[4:1] + in_y[0]) * 10 + 160;
            sram_raddr_2_n = in_x[4:1] + in_x[0] + (in_y[4:1]          ) * 10 + 160;
            sram_raddr_3_n = in_x[4:1]           + (in_y[4:1]          ) * 10 + 160;
        end
        else begin
            sram_raddr_0_n = in_x[4:1] + in_x[0] + (in_y[4:1] + in_y[0]) * 10 + 80;
            sram_raddr_1_n = in_x[4:1]           + (in_y[4:1] + in_y[0]) * 10 + 80;
            sram_raddr_2_n = in_x[4:1] + in_x[0] + (in_y[4:1]          ) * 10 + 80;
            sram_raddr_3_n = in_x[4:1]           + (in_y[4:1]          ) * 10 + 80;
        end

        
    end
end


always@(*)begin
    if(state == IDLE || state == BLANK ||state == CONV1)begin
        sram_raddr_weight_n = 0;
    end
    else if(state == BLANK2 || state == CONV2)begin
        if(in_cnt == 1)begin
            sram_raddr_weight_n = 0 + (weight_cnt)*3 + 1;
        end
        else if(in_cnt == 2)begin
            sram_raddr_weight_n = 1 + (weight_cnt)*3 + 1;
        end
        else begin
            sram_raddr_weight_n = 2 + (weight_cnt)*3 + 1;
        end
    end
    else if(state == BLANK3_1 || state == CONV3_1)begin
        if(in_cnt == 4)begin
            sram_raddr_weight_n = 0 + (weight_cnt_delay[2])*6 + 10;
        end
        else if (in_cnt == 5)begin
            sram_raddr_weight_n = 1 + (weight_cnt_delay[2])*6 + 10;
        end
        else if (in_cnt == 0)begin
            sram_raddr_weight_n = 2 + (weight_cnt_delay[2])*6 + 10;
        end
        else if (in_cnt == 1)begin
            sram_raddr_weight_n = 3 + (weight_cnt_delay[2])*6 + 10;
        end
        else if (in_cnt == 2)begin
            sram_raddr_weight_n = 4 + (weight_cnt_delay[2])*6 + 10;
        end
        else begin
            sram_raddr_weight_n = 5 + (weight_cnt_delay[2])*6 + 10;
        end
    end
    else if(state == BLANK3 || state == CONV3)begin
        if(in_cnt == 1)begin
            sram_raddr_weight_n = 0 + (weight_cnt)*3 + 28;
        end
        else if(in_cnt == 2)begin
            sram_raddr_weight_n = 1 + (weight_cnt)*3 + 28;
        end
        else begin
            sram_raddr_weight_n = 2 + (weight_cnt)*3 + 28;
        end
    end
    else if(state == BLANK4_1 || state == CONV4_1)begin
        if(in_cnt == 4)begin
            sram_raddr_weight_n = 0 + (weight_cnt_delay[2])*6 + 37;
        end
        else if (in_cnt == 5)begin
            sram_raddr_weight_n = 1 + (weight_cnt_delay[2])*6 + 37;
        end
        else if (in_cnt == 0)begin
            sram_raddr_weight_n = 2 + (weight_cnt_delay[2])*6 + 37;
        end
        else if (in_cnt == 1)begin
            sram_raddr_weight_n = 3 + (weight_cnt_delay[2])*6 + 37;
        end
        else if (in_cnt == 2)begin
            sram_raddr_weight_n = 4 + (weight_cnt_delay[2])*6 + 37;
        end
        else begin
            sram_raddr_weight_n = 5 + (weight_cnt_delay[2])*6 + 37;
        end
    end
    
    else if(state == BLANK4_2 || state == CONV4_2)begin
        if(in_cnt == 1)begin
            sram_raddr_weight_n = 0 + (weight_cnt)*3 + 55;
        end
        else if(in_cnt == 2)begin
            sram_raddr_weight_n = 1 + (weight_cnt)*3 + 55;
        end
        else begin
            sram_raddr_weight_n = 2 + (weight_cnt)*3 + 55;
        end
    end
    
    else if(state == BLANK4 || state == CONV4)begin
        if(in_cnt == 1)begin
            sram_raddr_weight_n = 0 + (weight_cnt)*3 + 64;
        end
        else if(in_cnt == 2)begin
            sram_raddr_weight_n = 1 + (weight_cnt)*3 + 64;
        end
        else begin
            sram_raddr_weight_n = 2 + (weight_cnt)*3 + 64;
        end
    end
    //conv5
    else begin
        case(in_cnt)
            10:begin
                sram_raddr_weight_n = 0 + (weight_cnt_delay[8])*12 + 73;
            end
            11:begin
                sram_raddr_weight_n = 1 + (weight_cnt_delay[8])*12 + 73;
            end
            default:begin
                sram_raddr_weight_n = in_cnt + 2 + (weight_cnt_delay[8])*12 + 73;
            end
        endcase
        
    end
end



always@(*)begin
    if(state == IDLE)begin
        sram_raddr_bias_n = 0;
    end
    else if(state == CONV1)begin
        sram_raddr_bias_n = (in_x == 1 && in_y == 0) ? sram_raddr_bias + 1 : sram_raddr_bias;
    end
    else if(state == CONV2 ||  state == CONV3 || state == CONV4_2 || state == CONV4)begin
        sram_raddr_bias_n = (in_x == 0 && in_y == 0 && in_cnt == 2) ? sram_raddr_bias + 1 : sram_raddr_bias;
    end
    else if(state == CONV3_1 || state == CONV4_1)begin
        sram_raddr_bias_n = (in_x == 0 && in_y == 0 && in_cnt == 5) ? sram_raddr_bias + 1 : sram_raddr_bias;
    end
    else if(state == CONV5)begin
        sram_raddr_bias_n = (in_x == 0 && in_y == 0 && in_cnt == 11) ? sram_raddr_bias + 1 : sram_raddr_bias;
    end
    else begin
        sram_raddr_bias_n = sram_raddr_bias;
    end
end


always@(posedge clk)begin
    in_cnt <= in_cnt_n;

    in_x <= in_x_n;
    in_y <= in_y_n;

    x <= x_n;
    y <= y_n;

    x_delay[0] <= x;
    y_delay[0] <= y;
    x_delay[1] <= x_delay[0];
    y_delay[1] <= y_delay[0];
    x_delay[2] <= x_delay[1];
    y_delay[2] <= y_delay[1];

    weight_cnt_delay[0] <= weight_cnt;
    weight_cnt_delay[1] <= weight_cnt_delay[0];
    weight_cnt_delay[2] <= weight_cnt_delay[1];
    weight_cnt_delay[3] <= weight_cnt_delay[2];
    weight_cnt_delay[4] <= weight_cnt_delay[3];
    weight_cnt_delay[5] <= weight_cnt_delay[4];
    weight_cnt_delay[6] <= weight_cnt_delay[5];
    weight_cnt_delay[7] <= weight_cnt_delay[6];
    weight_cnt_delay[8] <= weight_cnt_delay[7];
    weight_cnt_delay[9] <= weight_cnt_delay[8];
    weight_cnt_delay[10] <= weight_cnt_delay[9];
    weight_cnt_delay[11] <= weight_cnt_delay[10];
    weight_cnt_delay[12] <= weight_cnt_delay[11];
    weight_cnt_delay[13] <= weight_cnt_delay[12];
    weight_cnt_delay[14] <= weight_cnt_delay[13];
    weight_cnt_delay[15] <= weight_cnt_delay[14];
    weight_cnt_delay[16] <= weight_cnt_delay[15];

    weight_cnt <= weight_cnt_n;

    valid_conv1 <= valid_conv1_n;

end

always@(*)begin
    valid_n = (state == FINISH)? 1:0; 
    valid_conv1_n = (state == WAIT_SHIFT_MEM  || state == WAIT_SHIFT_MEM2 || state == WAIT_SHIFT_MEM3_1 || state == WAIT_SHIFT_MEM3 || 
                     state == WAIT_SHIFT_MEM4_1 || state == WAIT_SHIFT_MEM4_2 || state == WAIT_SHIFT_MEM4 || state == WAIT_SHIFT_MEM5)? 1: 0;
end


always@(posedge clk)begin
    if(~rst_n)begin
        state <= IDLE;
    end
    else begin
        state <= state_n;
    end
end

always@(*)begin
    case(state)
        IDLE:begin
            state_n = (enable)? BLANK:IDLE;
            in_cnt_n = 0;
            in_x_n = 1;
            in_y_n = 0;
            x_n = 0;
            y_n = 0;
        end
        BLANK:begin
            state_n = CONV1;
            in_cnt_n = 0;
            
            in_x_n = 2;
            in_y_n = 0;
            
            x_n = 0;
            y_n = 0;            
        end
        CONV1:begin
            state_n = (x_delay[2] == 19 && y_delay[2] == 15 && weight_cnt_delay[4] == 2) ? WAIT_SHIFT_MEM : CONV1;

            in_cnt_n = 0;

            in_x_n = (in_x == 19) ? 0 : in_x + 1;
            in_y_n = (in_x == 19) ? (in_y == 15) ? 0 : in_y + 1 : in_y;

            x_n = (x == 19) ? 0 : x + 1;
            y_n = (x == 19) ? (y==15) ? 0 : y + 1 : y;
        end
        WAIT_SHIFT_MEM:begin
            state_n = (shift_finish) ? BLANK2 : WAIT_SHIFT_MEM ;
            in_cnt_n = 0;

            in_x_n = 0;
            in_y_n = 0;

            x_n = 0;
            y_n = 0;
        end
        BLANK2:begin
            state_n = (in_cnt == 2)? CONV2 : BLANK2;
            in_cnt_n = (in_cnt == 2)? 0 : in_cnt + 1;

            in_x_n = 0;
            in_y_n = 0;

            x_n = 0;
            y_n = 0;
        end
        CONV2:begin
            state_n =  (x_delay[2] == 19 && y_delay[2] == 15 && in_cnt == 2 && weight_cnt_delay[4] == 2) ? WAIT_SHIFT_MEM2 : CONV2;
            in_cnt_n = (in_cnt == 2) ? 0 : in_cnt + 1;

            in_x_n = (in_cnt == 0) ? (in_x == 19) ? 0 : in_x + 1 : in_x;
            in_y_n = (in_cnt == 0) ? (in_x == 19) ? (in_y == 15)? 0 : in_y + 1 : in_y : in_y;

            x_n = (in_cnt == 2) ? (x == 19) ? 0 : x + 1 : x;
            y_n = (in_cnt == 2) ? (x == 19) ? (y==15) ? 0 :  y + 1 : y : y;
        end
        
        WAIT_SHIFT_MEM2:begin
            state_n = (shift_finish) ? BLANK3_1 : WAIT_SHIFT_MEM2;
            in_cnt_n = 0;

            in_x_n = 0;
            in_y_n = 0;

            x_n = 0;
            y_n = 0;
        end
        BLANK3_1:begin
            state_n = (in_cnt == 5)? CONV3_1 : BLANK3_1;
            in_cnt_n = (in_cnt == 5)? 0 : in_cnt + 1;

            in_x_n = 0;
            in_y_n = 0;

            x_n = 0;
            y_n = 0;
        end
        CONV3_1:begin
            state_n = (x_delay[2] == 19 && y_delay[2] == 15 && in_cnt == 2 && weight_cnt_delay[8] == 2)? WAIT_SHIFT_MEM3_1 : CONV3_1;

            in_cnt_n = (in_cnt == 5) ? 0 : in_cnt + 1;

            in_x_n = (in_cnt == 3) ? (in_x == 19) ? 0 : in_x + 1 : in_x;
            in_y_n = (in_cnt == 3) ? (in_x == 19) ? (in_y == 15)? 0 : in_y + 1 : in_y : in_y;

            x_n = (in_cnt == 5) ? (x == 19) ? 0 : x + 1 : x;
            y_n = (in_cnt == 5) ? (x == 19) ? (y==15) ? 0 :  y + 1 : y : y;
        end

        WAIT_SHIFT_MEM3_1:begin
            state_n = (shift_finish) ? BLANK3 : WAIT_SHIFT_MEM3_1;
            in_cnt_n = 0;

            in_x_n = 0;
            in_y_n = 0;

            x_n = 0;
            y_n = 0;
        end
        BLANK3:begin
            state_n = (in_cnt == 2)? CONV3 : BLANK3;
            in_cnt_n = (in_cnt == 2)? 0 : in_cnt + 1;

            in_x_n = 0;
            in_y_n = 0;

            x_n = 0;
            y_n = 0;
        end
        CONV3:begin
            state_n =  (x_delay[2] == 19 && y_delay[2] == 15 && in_cnt == 2 && weight_cnt_delay[4] == 2) ? WAIT_SHIFT_MEM3 : CONV3;
            in_cnt_n = (in_cnt == 2) ? 0 : in_cnt + 1;

            in_x_n = (in_cnt == 0) ? (in_x == 19) ? 0 : in_x + 1 : in_x;
            in_y_n = (in_cnt == 0) ? (in_x == 19) ? (in_y == 15)? 0 : in_y + 1 : in_y : in_y;

            
            x_n = (in_cnt == 2) ? (x == 19) ? 0 : x + 1 : x;
            y_n = (in_cnt == 2) ? (x == 19) ? (y==15) ? 0 :  y + 1 : y : y;

        end
        WAIT_SHIFT_MEM3:begin
            state_n = (shift_finish) ? BLANK4_1 : WAIT_SHIFT_MEM3;
            in_cnt_n = 0;

            in_x_n = 0;
            in_y_n = 0;

            x_n = 0;
            y_n = 0;
        end
        
        BLANK4_1:begin
            state_n = (in_cnt == 5)? CONV4_1 : BLANK4_1;
            in_cnt_n = (in_cnt == 5)? 0 : in_cnt + 1;

            in_x_n = 0;
            in_y_n = 0;

            x_n = 0;
            y_n = 0;
        end
        CONV4_1:begin
            state_n = (x_delay[2] == 19 && y_delay[2] == 15 && in_cnt == 2 && weight_cnt_delay[8] == 2)? WAIT_SHIFT_MEM4_1 : CONV4_1;

            in_cnt_n = (in_cnt == 5) ? 0 : in_cnt + 1;

            in_x_n = (in_cnt == 3) ? (in_x == 19) ? 0 : in_x + 1 : in_x;
            in_y_n = (in_cnt == 3) ? (in_x == 19) ? (in_y == 15)? 0 : in_y + 1 : in_y : in_y;

            x_n = (in_cnt == 5) ? (x == 19) ? 0 : x + 1 : x;
            y_n = (in_cnt == 5) ? (x == 19) ? (y==15) ? 0 :  y + 1 : y : y;
        end

        WAIT_SHIFT_MEM4_1:begin
            state_n = (shift_finish) ? BLANK4_2 : WAIT_SHIFT_MEM4_1;
            in_cnt_n = 0;

            in_x_n = 0;
            in_y_n = 0;

            x_n = 0;
            y_n = 0;
        end
        
        BLANK4_2:begin
            state_n = (in_cnt == 2)? CONV4_2 : BLANK4_2;
            in_cnt_n = (in_cnt == 2)? 0 : in_cnt + 1;

            in_x_n = 0;
            in_y_n = 0;

            x_n = 0;
            y_n = 0;
        end
        CONV4_2:begin
            state_n =  (x_delay[2] == 19 && y_delay[2] == 15 && in_cnt == 2 && weight_cnt_delay[4] == 2) ? WAIT_SHIFT_MEM4_2 : CONV4_2;
            in_cnt_n = (in_cnt == 2) ? 0 : in_cnt + 1;

            in_x_n = (in_cnt == 0) ? (in_x == 19) ? 0 : in_x + 1 : in_x;
            in_y_n = (in_cnt == 0) ? (in_x == 19) ? (in_y == 15)? 0 : in_y + 1 : in_y : in_y;

            
            x_n = (in_cnt == 2) ? (x == 19) ? 0 : x + 1 : x;
            y_n = (in_cnt == 2) ? (x == 19) ? (y==15) ? 0 :  y + 1 : y : y;

        end
        WAIT_SHIFT_MEM4_2:begin
            state_n = (shift_finish) ? BLANK4 : WAIT_SHIFT_MEM4_2;
            in_cnt_n = 0;

            in_x_n = 0;
            in_y_n = 0;

            x_n = 0;
            y_n = 0;
        end
        
        BLANK4:begin
            state_n = (in_cnt == 2)? CONV4 : BLANK4;
            in_cnt_n = (in_cnt == 2)? 0 : in_cnt + 1;

            in_x_n = 0;
            in_y_n = 0;

            x_n = 0;
            y_n = 0;
        end
        CONV4:begin
            state_n =  (x_delay[2] == 19 && y_delay[2] == 15 && in_cnt == 2 && weight_cnt_delay[14] == 2) ? WAIT_SHIFT_MEM4 : CONV4;
            in_cnt_n = (in_cnt == 2) ? 0 : in_cnt + 1;

            in_x_n = (in_cnt == 0) ? (in_x == 19) ? 0 : in_x + 1 : in_x;
            in_y_n = (in_cnt == 0) ? (in_x == 19) ? (in_y == 15)? 0 : in_y + 1 : in_y : in_y;

            
            x_n = (in_cnt == 2) ? (x == 19) ? 0 : x + 1 : x;
            y_n = (in_cnt == 2) ? (x == 19) ? (y==15) ? 0 :  y + 1 : y : y;

        end
        WAIT_SHIFT_MEM4:begin
            state_n = (shift_finish) ? BLANK5 : WAIT_SHIFT_MEM4;
            in_cnt_n = 0;

            in_x_n = 0;
            in_y_n = 0;

            x_n = 0;
            y_n = 0;
        end

        BLANK5:begin
            state_n = (in_cnt == 11)? CONV5 : BLANK5;
            in_cnt_n = (in_cnt == 11)? 0 : in_cnt + 1;

            in_x_n = 0;
            in_y_n = 0;

            x_n = 0;
            y_n = 0;
        end
        CONV5:begin
            state_n =  (x_delay[2] == 19 && y_delay[2] == 15 && in_cnt == 2 && weight_cnt_delay[16] == 2) ? WAIT_SHIFT_MEM5 : CONV5;
            in_cnt_n = (in_cnt == 11) ? 0 : in_cnt + 1;

            in_x_n = (in_cnt == 9) ? (in_x == 19) ? 0 : in_x + 1 : in_x;
            in_y_n = (in_cnt == 9) ? (in_x == 19) ? (in_y == 15)? 0 : in_y + 1 : in_y : in_y;

            
            x_n = (in_cnt == 11) ? (x == 19) ? 0 : x + 1 : x;
            y_n = (in_cnt == 11) ? (x == 19) ? (y==15) ? 0 :  y + 1 : y : y;

        end
        WAIT_SHIFT_MEM5:begin
            state_n = (shift_finish) ? FINISH : WAIT_SHIFT_MEM5;
            in_cnt_n = 0;

            in_x_n = 0;
            in_y_n = 0;

            x_n = 0;
            y_n = 0;
        end


        FINISH:begin
            state_n = FINISH;
            in_cnt_n = 0;
            in_x_n = 0;
            in_y_n = 0;
            x_n = 0;
            y_n = 0;
        end
        default:begin
            state_n = IDLE;
            in_cnt_n = 0;
            in_x_n = 0;
            in_y_n = 0;
            x_n = 0;
            y_n = 0;
        end
    endcase
end



endmodule

module winograd_2d#(
parameter bit_f = 10,
parameter bit_w = 10
)
(
input signed [bit_f-1 : 0] f0, 
input signed [bit_f-1 : 0] f1, 
input signed [bit_f-1 : 0] f2, 
input signed [bit_f-1 : 0] f3, 
input signed [bit_f-1 : 0] f4, 
input signed [bit_f-1 : 0] f5, 
input signed [bit_f-1 : 0] f6, 
input signed [bit_f-1 : 0] f7, 
input signed [bit_f-1 : 0] f8, 
input signed [bit_f-1 : 0] f9, 
input signed [bit_f-1 : 0] f10, 
input signed [bit_f-1 : 0] f11, 
input signed [bit_f-1 : 0] f12, 
input signed [bit_f-1 : 0] f13, 
input signed [bit_f-1 : 0] f14, 
input signed [bit_f-1 : 0] f15, 
input signed [bit_f-1 : 0] f16, 
input signed [bit_f-1 : 0] f17, 
input signed [bit_f-1 : 0] f18, 
input signed [bit_f-1 : 0] f19, 
input signed [bit_f-1 : 0] f20, 
input signed [bit_f-1 : 0] f21, 
input signed [bit_f-1 : 0] f22, 
input signed [bit_f-1 : 0] f23, 
input signed [bit_f-1 : 0] f24, 

input signed [bit_w-1 : 0] w0,
input signed [bit_w-1 : 0] w1,
input signed [bit_w-1 : 0] w2,
input signed [bit_w-1 : 0] w3,
input signed [bit_w-1 : 0] w4,
input signed [bit_w-1 : 0] w5,
input signed [bit_w-1 : 0] w6,
input signed [bit_w-1 : 0] w7,
input signed [bit_w-1 : 0] w8,

input  [(bit_f + 1 + 1 + bit_w + 2 + 2)*49 -1 :0] mm,
output [(bit_f + 1 + 1) * 49 -1 : 0] aa,
output [(bit_w + 2 + 2) * 49 -1 : 0] bb,


output signed [(bit_f + bit_w + 4) - 1 : 0] out0,
output signed [(bit_f + bit_w + 4) - 1 : 0] out1,
output signed [(bit_f + bit_w + 4) - 1 : 0] out2,
output signed [(bit_f + bit_w + 4) - 1 : 0] out3,
output signed [(bit_f + bit_w + 4) - 1 : 0] out4,
output signed [(bit_f + bit_w + 4) - 1 : 0] out5,
output signed [(bit_f + bit_w + 4) - 1 : 0] out6,
output signed [(bit_f + bit_w + 4) - 1 : 0] out7,
output signed [(bit_f + bit_w + 4) - 1 : 0] out8

);

parameter bit_d = bit_f + 1;
parameter bit_g = bit_w + 2;


wire signed [(bit_f + 1 + bit_w + 2 + 2)-1:0] m0 [0:2];
wire signed [(bit_f + 1 + bit_w + 2 + 2)-1:0] m1 [0:2];
wire signed [(bit_f + 1 + bit_w + 2 + 2)-1:0] m2 [0:2];
wire signed [(bit_f + 1 + bit_w + 2 + 2)-1:0] m3 [0:2];
wire signed [(bit_f + 1 + bit_w + 2 + 2)-1:0] m4 [0:2];
wire signed [(bit_f + 1 + bit_w + 2 + 2)-1:0] m5 [0:2];
wire signed [(bit_f + 1 + bit_w + 2 + 2)-1:0] m6 [0:2];

wire signed [(bit_f + 1) -1 : 0] a0 [0:4];
wire signed [(bit_f + 1) -1 : 0] a1 [0:4];
wire signed [(bit_f + 1) -1 : 0] a2 [0:4];
wire signed [(bit_f + 1) -1 : 0] a3 [0:4];
wire signed [(bit_f + 1) -1 : 0] a4 [0:4];
wire signed [(bit_f + 1) -1 : 0] a5 [0:4];
wire signed [(bit_f + 1) -1 : 0] a6 [0:4];

wire signed [(bit_w + 2) -1 : 0] b0 [0:2];
wire signed [(bit_w + 2) -1 : 0] b1 [0:2];
wire signed [(bit_w + 2) -1 : 0] b2 [0:2];
wire signed [(bit_w + 2) -1 : 0] b3 [0:2];
wire signed [(bit_w + 2) -1 : 0] b4 [0:2];
wire signed [(bit_w + 2) -1 : 0] b5 [0:2];
wire signed [(bit_w + 2) -1 : 0] b6 [0:2];

assign a0[0] = f0-f10;
assign a0[1] = f1-f11;
assign a0[2] = f2-f12;
assign a0[3] = f3-f13;
assign a0[4] = f4-f14;

assign a1[0] = f5+f10;
assign a1[1] = f6+f11;
assign a1[2] = f7+f12;
assign a1[3] = f8+f13;
assign a1[4] = f9+f14;

assign a2[0] = f10-f5;
assign a2[1] = f11-f6;
assign a2[2] = f12-f7;
assign a2[3] = f13-f8;
assign a2[4] = f14-f9;

assign a3[0] = f5-f15;
assign a3[1] = f6-f16;
assign a3[2] = f7-f17;
assign a3[3] = f8-f18;
assign a3[4] = f9-f19;

assign a4[0] = f10;
assign a4[1] = f11;
assign a4[2] = f12;
assign a4[3] = f13;
assign a4[4] = f14;

assign a5[0] = f15;
assign a5[1] = f16;
assign a5[2] = f17;
assign a5[3] = f18;
assign a5[4] = f19;

assign a6[0] = f20;
assign a6[1] = f21;
assign a6[2] = f22;
assign a6[3] = f23;
assign a6[4] = f24;


assign b0[0] = w0;
assign b0[1] = w1;
assign b0[2] = w2;

assign b1[0] = w0 + w3 + w6;
assign b1[1] = w1 + w4 + w7;
assign b1[2] = w2 + w5 + w8;

assign b2[0] = w0 - w3 + w6;
assign b2[1] = w1 - w4 + w7;
assign b2[2] = w2 - w5 + w8;

assign b3[0] = w6;
assign b3[1] = w7;
assign b3[2] = w8;

assign b4[0] = w0;
assign b4[1] = w1;
assign b4[2] = w2;

assign b5[0] = w3;
assign b5[1] = w4;
assign b5[2] = w5;

assign b6[0] = w6;
assign b6[1] = w7;
assign b6[2] = w8;

wire [(bit_d + 1)*7 -1 : 0] aaa [0:6];
wire [(bit_g + 2)*7 -1 : 0] bbb [0:6];
wire [(bit_d + 1 + bit_g + 2)*7 -1 :0] mmm[0:6];

winograd_1d #( 
.bit_d(bit_d),
.bit_g(bit_g)
)
winograd_1d_0
(
.d0(a0[0]),
.d1(a0[1]),
.d2(a0[2]),
.d3(a0[3]),
.d4(a0[4]),

.g0(b0[0]),
.g1(b0[1]),
.g2(b0[2]),

.m(mmm[0]),
.a(aaa[0]),
.b(bbb[0]),

.out0(m0[0]),
.out1(m0[1]),
.out2(m0[2])
);

winograd_1d #(
.bit_d(bit_d),
.bit_g(bit_g)
)
winograd_1d_1
(
.d0(a1[0]),
.d1(a1[1]),
.d2(a1[2]),
.d3(a1[3]),
.d4(a1[4]),

.g0(b1[0]),
.g1(b1[1]),
.g2(b1[2]),

.m(mmm[1]),
.a(aaa[1]),
.b(bbb[1]),

.out0(m1[0]),
.out1(m1[1]),
.out2(m1[2])
);

winograd_1d #(
.bit_d(bit_d),
.bit_g(bit_g)
)
winograd_1d_2
(
.d0(a2[0]),
.d1(a2[1]),
.d2(a2[2]),
.d3(a2[3]),
.d4(a2[4]),

.g0(b2[0]),
.g1(b2[1]),
.g2(b2[2]),

.m(mmm[2]),
.a(aaa[2]),
.b(bbb[2]),

.out0(m2[0]),
.out1(m2[1]),
.out2(m2[2])
);

winograd_1d #(
.bit_d(bit_d),
.bit_g(bit_g)
)
winograd_1d_3
(
.d0(a3[0]),
.d1(a3[1]),
.d2(a3[2]),
.d3(a3[3]),
.d4(a3[4]),

.g0(b3[0]),
.g1(b3[1]),
.g2(b3[2]),

.m(mmm[3]),
.a(aaa[3]),
.b(bbb[3]),

.out0(m3[0]),
.out1(m3[1]),
.out2(m3[2])
);



winograd_1d #(
.bit_d(bit_d),
.bit_g(bit_g)
)
winograd_1d_4
(
.d0(a4[0]),
.d1(a4[1]),
.d2(a4[2]),
.d3(a4[3]),
.d4(a4[4]),

.g0(b4[0]),
.g1(b4[1]),
.g2(b4[2]),

.m(mmm[4]),
.a(aaa[4]),
.b(bbb[4]),

.out0(m4[0]),
.out1(m4[1]),
.out2(m4[2])
);


winograd_1d #(
.bit_d(bit_d),
.bit_g(bit_g)
)
winograd_1d_5
(
.d0(a5[0]),
.d1(a5[1]),
.d2(a5[2]),
.d3(a5[3]),
.d4(a5[4]),

.g0(b5[0]),
.g1(b5[1]),
.g2(b5[2]),

.m(mmm[5]),
.a(aaa[5]),
.b(bbb[5]),

.out0(m5[0]),
.out1(m5[1]),
.out2(m5[2])
);


winograd_1d #(
.bit_d(bit_d),
.bit_g(bit_g)
)
winograd_1d_6
(
.d0(a6[0]),
.d1(a6[1]),
.d2(a6[2]),
.d3(a6[3]),
.d4(a6[4]),

.g0(b6[0]),
.g1(b6[1]),
.g2(b6[2]),

.m(mmm[6]),
.a(aaa[6]),
.b(bbb[6]),

.out0(m6[0]),
.out1(m6[1]),
.out2(m6[2])
);

assign aa = {aaa[6], aaa[5], aaa[4], aaa[3], aaa[2], aaa[1], aaa[0]};
assign bb = {bbb[6], bbb[5], bbb[4], bbb[3], bbb[2], bbb[1], bbb[0]};
assign mmm[0] = mm[(bit_d + 1 + bit_g + 2)*7 * 0 +: (bit_d + 1 + bit_g + 2)*7];
assign mmm[1] = mm[(bit_d + 1 + bit_g + 2)*7 * 1 +: (bit_d + 1 + bit_g + 2)*7];
assign mmm[2] = mm[(bit_d + 1 + bit_g + 2)*7 * 2 +: (bit_d + 1 + bit_g + 2)*7];
assign mmm[3] = mm[(bit_d + 1 + bit_g + 2)*7 * 3 +: (bit_d + 1 + bit_g + 2)*7];
assign mmm[4] = mm[(bit_d + 1 + bit_g + 2)*7 * 4 +: (bit_d + 1 + bit_g + 2)*7];
assign mmm[5] = mm[(bit_d + 1 + bit_g + 2)*7 * 5 +: (bit_d + 1 + bit_g + 2)*7];
assign mmm[6] = mm[(bit_d + 1 + bit_g + 2)*7 * 6 +: (bit_d + 1 + bit_g + 2)*7];


wire signed [(bit_f + 1 + bit_w + 2 + 2) - 1 + 1 : 0] m0_ [0:2];
wire signed [(bit_f + 1 + bit_w + 2 + 2) - 1 + 1 : 0] m3_ [0:2];

assign m0_[0] = {m0[0],1'b0};
assign m0_[1] = {m0[1],1'b0};
assign m0_[2] = {m0[2],1'b0};
assign m3_[0] = {m3[0],1'b0};
assign m3_[1] = {m3[1],1'b0};
assign m3_[2] = {m3[2],1'b0};

wire signed [(bit_f + 1 + bit_w + 2 + 2) -1 + 1 + 2 : 0] out0_tmp;
wire signed [(bit_f + 1 + bit_w + 2 + 2) -1 + 1 + 2 : 0] out1_tmp;
wire signed [(bit_f + 1 + bit_w + 2 + 2) -1 + 1 + 2 : 0] out2_tmp;
wire signed [(bit_f + 1 + bit_w + 2 + 2) -1 + 1 + 2 : 0] out3_tmp;
wire signed [(bit_f + 1 + bit_w + 2 + 2) -1 + 1 + 2 : 0] out4_tmp;
wire signed [(bit_f + 1 + bit_w + 2 + 2) -1 + 1 + 2 : 0] out5_tmp;

assign out0_tmp = m0_[0] + m1[0] + m2[0];
assign out1_tmp = m0_[1] + m1[1] + m2[1];
assign out2_tmp = m0_[2] + m1[2] + m2[2];
assign out3_tmp = m1[0] - m2[0] - m3_[0];
assign out4_tmp = m1[1] - m2[1] - m3_[1];
assign out5_tmp = m1[2] - m2[2] - m3_[2];

assign out0 = out0_tmp[(bit_f + 1 + bit_w + 2 + 2) -1 + 1 + 2 : 1];
assign out1 = out1_tmp[(bit_f + 1 + bit_w + 2 + 2) -1 + 1 + 2 : 1];
assign out2 = out2_tmp[(bit_f + 1 + bit_w + 2 + 2) -1 + 1 + 2 : 1];
assign out3 = out3_tmp[(bit_f + 1 + bit_w + 2 + 2) -1 + 1 + 2 : 1];
assign out4 = out4_tmp[(bit_f + 1 + bit_w + 2 + 2) -1 + 1 + 2 : 1];
assign out5 = out5_tmp[(bit_f + 1 + bit_w + 2 + 2) -1 + 1 + 2 : 1];
assign out6 = m4[0] + m5[0] + m6[0]; 
assign out7 = m4[1] + m5[1] + m6[1]; 
assign out8 = m4[2] + m5[2] + m6[2]; 




endmodule






module winograd_1d #(
parameter bit_d = 10,
parameter bit_g = 10
)
(
input signed [bit_d-1:0] d0,
input signed [bit_d-1:0] d1,
input signed [bit_d-1:0] d2,
input signed [bit_d-1:0] d3,
input signed [bit_d-1:0] d4,

input signed [bit_g-1:0] g0,
input signed [bit_g-1:0] g1,
input signed [bit_g-1:0] g2,


input  [(bit_d + 1 + bit_g + 2)*7 -1 :0]m,
output [(bit_d + 1)*7 -1 : 0] a,
output [(bit_g + 2)*7 -1 : 0] b,


output signed [(bit_d + bit_g + 2)-1:0]out0,
output signed [(bit_d + bit_g + 2)-1:0]out1,
output signed [(bit_d + bit_g + 2)-1:0]out2
);

wire signed [(bit_d + 1) - 1 : 0] a0;
wire signed [(bit_d + 1) - 1 : 0] a1;
wire signed [(bit_d + 1) - 1 : 0] a2;
wire signed [(bit_d + 1) - 1 : 0] a3;
wire signed [(bit_d + 1) - 1 : 0] a4;
wire signed [(bit_d + 1) - 1 : 0] a5;
wire signed [(bit_d + 1) - 1 : 0] a6;

wire signed [(bit_g + 2) - 1 : 0] b0;
wire signed [(bit_g + 2) - 1 : 0] b1;
wire signed [(bit_g + 2) - 1 : 0] b2;
wire signed [(bit_g + 2) - 1 : 0] b3;
wire signed [(bit_g + 2) - 1 : 0] b4;
wire signed [(bit_g + 2) - 1 : 0] b5;
wire signed [(bit_g + 2) - 1 : 0] b6;


assign a0 = d0-d2;
assign a1 = d1+d2;
assign a2 = d2-d1;
assign a3 = d1-d3;
assign a4 = d2;
assign a5 = d3;
assign a6 = d4;

assign b0 = g0;
assign b1 = g0 + g1 + g2;
assign b2 = g0 - g1 + g2;
assign b3 = g2;
assign b4 = g0;
assign b5 = g1;
assign b6 = g2;


wire signed [(bit_d + 1 + bit_g + 2) -1 : 0] m0;
wire signed [(bit_d + 1 + bit_g + 2) -1 : 0] m1;
wire signed [(bit_d + 1 + bit_g + 2) -1 : 0] m2;
wire signed [(bit_d + 1 + bit_g + 2) -1 : 0] m3;
wire signed [(bit_d + 1 + bit_g + 2) -1 : 0] m4;
wire signed [(bit_d + 1 + bit_g + 2) -1 : 0] m5;
wire signed [(bit_d + 1 + bit_g + 2) -1 : 0] m6;

assign a = {a6, a5, a4, a3, a2, a1, a0};
assign b = {b6, b5, b4, b3, b2, b1, b0};
assign m0 = m[(bit_d + 1 + bit_g + 2) * 0 +: (bit_d + 1 + bit_g + 2)]; 
assign m1 = m[(bit_d + 1 + bit_g + 2) * 1 +: (bit_d + 1 + bit_g + 2)]; 
assign m2 = m[(bit_d + 1 + bit_g + 2) * 2 +: (bit_d + 1 + bit_g + 2)]; 
assign m3 = m[(bit_d + 1 + bit_g + 2) * 3 +: (bit_d + 1 + bit_g + 2)]; 
assign m4 = m[(bit_d + 1 + bit_g + 2) * 4 +: (bit_d + 1 + bit_g + 2)]; 
assign m5 = m[(bit_d + 1 + bit_g + 2) * 5 +: (bit_d + 1 + bit_g + 2)]; 
assign m6 = m[(bit_d + 1 + bit_g + 2) * 6 +: (bit_d + 1 + bit_g + 2)]; 

wire signed [(bit_d + 1 + bit_g + 2) - 1 + 1 : 0] m0_;
wire signed [(bit_d + 1 + bit_g + 2) - 1 + 1 : 0] m3_;

assign m0_ = {m0,1'b0};
assign m3_ = {m3,1'b0};

wire signed [(bit_d + 1 + bit_g + 2) -1 + 1 + 2 : 0] tmp_out0;
wire signed [(bit_d + 1 + bit_g + 2) -1 + 1 + 2 : 0] tmp_out1;

assign tmp_out0 = m0_ + m1 + m2;
assign tmp_out1 = m1  - m2 - m3_;

assign out0 = tmp_out0[(bit_d + 1 + bit_g + 2) -1 + 1 + 2 : 1];
assign out1 = tmp_out1[(bit_d + 1 + bit_g + 2) -1 + 1 + 2 : 1];
assign out2 = m4 + m5 + m6;

endmodule

module mul49 #(
parameter bit_a = 10,
parameter bit_b = 10
)
(
input [bit_a*49-1:0] a,
input [bit_b*49-1:0] b,
output [(bit_a+bit_b)*49-1:0]m
);

integer i;

reg signed [bit_a - 1 : 0] aa ;
reg signed [bit_b - 1 : 0] bb ;
reg signed [bit_a + bit_b - 1 : 0] mm [0:48];

always@(*)begin
    for(i = 0 ; i < 49 ; i = i + 1)begin
        aa = a[bit_a * i +: bit_a];
        bb = b[bit_b * i +: bit_b];
        mm[i] = aa * bb;
    end
end

assign m = {mm[48], mm[47], mm[46], mm[45], mm[44], mm[43], mm[42], mm[41], mm[40],
            mm[39], mm[38], mm[37], mm[36], mm[35], mm[34], mm[33], mm[32], mm[31], mm[30],
            mm[29], mm[28], mm[27], mm[26], mm[25], mm[24], mm[23], mm[22], mm[21], mm[20],
            mm[19], mm[18], mm[17], mm[16], mm[15], mm[14], mm[13], mm[12], mm[11], mm[10],
            mm[ 9], mm[ 8], mm[ 7], mm[ 6], mm[ 5], mm[ 4], mm[ 3], mm[ 2], mm[ 1], mm[ 0]
            };

endmodule

