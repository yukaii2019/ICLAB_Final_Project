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
localparam [4:0] FINISH = 7;


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

//reg rst_n_d;
//reg [90-1:0] sram_rdata_weight_d;
//reg [10-1:0] sram_rdata_bias_d;
//reg enable_d;


reg [4:0] state, state_n;
reg [1:0] in_cnt, in_cnt_n;


reg [9:0] w_n [0:9-1];
reg signed [9:0] w [0:9-1];

reg [9:0] f_n [0:27-1];
reg signed [9:0] f [0:27-1];

reg signed [17:0] b [0:2];

reg [270-1:0] in;

reg signed [20-1:0] mul_result_n[0:81-1];
reg signed [20-1:0] mul_result[0:81-1];

reg signed [22:0] sum_n [0:27-1];
reg signed [22:0] sum [0:27-1];
reg [22:0] unsigned_sum[0:27-1];
reg [22:0] out [0:27];


reg [6:0] in_x, in_y;
reg [6:0] in_x_n, in_y_n;

reg [6:0] x,y;
reg [6:0] x_n,y_n;

reg [6:0] x_delay[0:2];
reg [6:0] y_delay[0:2];



reg [1:0] bias_cnt, bias_cnt_n;

reg [5:0] weight_cnt, weight_cnt_n;
reg [5:0] weight_cnt_delay [0:4];



wire [6:0] x_d2 = x_delay[2];
wire [6:0] y_d2 = y_delay[2];


integer i,j,k,l,m,n,o,p,q,r,s,t;


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

/* =========== input register =============== */
always@(posedge clk)begin
    //rst_n_d <= rst_n;
    //sram_rdata_weight_d <= sram_rdata_weight;
    //sram_rdata_bias_d <= sram_rdata_bias;
    //enable_d <= enable;
end
/* ========================================== */

wire [1:0] test = {y[0],x[0]};

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
                in[ 0*10 +: 10] = sram_rdata_0[(9*(2-in_cnt) + 8)*10 +: 10];
                in[ 1*10 +: 10] = sram_rdata_0[(9*(2-in_cnt) + 7)*10 +: 10];
                in[ 2*10 +: 10] = sram_rdata_0[(9*(2-in_cnt) + 6)*10 +: 10];
                in[ 3*10 +: 10] = sram_rdata_1[(9*(2-in_cnt) + 8)*10 +: 10];
                in[ 4*10 +: 10] = sram_rdata_1[(9*(2-in_cnt) + 7)*10 +: 10];
                in[ 5*10 +: 10] = sram_rdata_0[(9*(2-in_cnt) + 5)*10 +: 10];
                in[ 6*10 +: 10] = sram_rdata_0[(9*(2-in_cnt) + 4)*10 +: 10];
                in[ 7*10 +: 10] = sram_rdata_0[(9*(2-in_cnt) + 3)*10 +: 10];
                in[ 8*10 +: 10] = sram_rdata_1[(9*(2-in_cnt) + 5)*10 +: 10];
                in[ 9*10 +: 10] = sram_rdata_1[(9*(2-in_cnt) + 4)*10 +: 10];
                in[10*10 +: 10] = sram_rdata_0[(9*(2-in_cnt) + 2)*10 +: 10];
                in[11*10 +: 10] = sram_rdata_0[(9*(2-in_cnt) + 1)*10 +: 10];
                in[12*10 +: 10] = sram_rdata_0[(9*(2-in_cnt) + 0)*10 +: 10];
                in[13*10 +: 10] = sram_rdata_1[(9*(2-in_cnt) + 2)*10 +: 10];
                in[14*10 +: 10] = sram_rdata_1[(9*(2-in_cnt) + 1)*10 +: 10];
                in[15*10 +: 10] = sram_rdata_2[(9*(2-in_cnt) + 8)*10 +: 10];
                in[16*10 +: 10] = sram_rdata_2[(9*(2-in_cnt) + 7)*10 +: 10];
                in[17*10 +: 10] = sram_rdata_2[(9*(2-in_cnt) + 6)*10 +: 10];
                in[18*10 +: 10] = sram_rdata_3[(9*(2-in_cnt) + 8)*10 +: 10];
                in[19*10 +: 10] = sram_rdata_3[(9*(2-in_cnt) + 7)*10 +: 10];
                in[20*10 +: 10] = sram_rdata_2[(9*(2-in_cnt) + 5)*10 +: 10];
                in[21*10 +: 10] = sram_rdata_2[(9*(2-in_cnt) + 4)*10 +: 10];
                in[22*10 +: 10] = sram_rdata_2[(9*(2-in_cnt) + 3)*10 +: 10];
                in[23*10 +: 10] = sram_rdata_3[(9*(2-in_cnt) + 5)*10 +: 10];
                in[24*10 +: 10] = sram_rdata_3[(9*(2-in_cnt) + 4)*10 +: 10];
            end
            2'b01:begin
                in[ 0*10 +: 10] = sram_rdata_1[(9*(2-in_cnt) + 8)*10 +: 10];
                in[ 1*10 +: 10] = sram_rdata_1[(9*(2-in_cnt) + 7)*10 +: 10];
                in[ 2*10 +: 10] = sram_rdata_1[(9*(2-in_cnt) + 6)*10 +: 10];
                in[ 3*10 +: 10] = sram_rdata_0[(9*(2-in_cnt) + 8)*10 +: 10];
                in[ 4*10 +: 10] = sram_rdata_0[(9*(2-in_cnt) + 7)*10 +: 10];
                in[ 5*10 +: 10] = sram_rdata_1[(9*(2-in_cnt) + 5)*10 +: 10];
                in[ 6*10 +: 10] = sram_rdata_1[(9*(2-in_cnt) + 4)*10 +: 10];
                in[ 7*10 +: 10] = sram_rdata_1[(9*(2-in_cnt) + 3)*10 +: 10];
                in[ 8*10 +: 10] = sram_rdata_0[(9*(2-in_cnt) + 5)*10 +: 10];
                in[ 9*10 +: 10] = sram_rdata_0[(9*(2-in_cnt) + 4)*10 +: 10]; 
                in[10*10 +: 10] = sram_rdata_1[(9*(2-in_cnt) + 2)*10 +: 10];
                in[11*10 +: 10] = sram_rdata_1[(9*(2-in_cnt) + 1)*10 +: 10];
                in[12*10 +: 10] = sram_rdata_1[(9*(2-in_cnt) + 0)*10 +: 10];
                in[13*10 +: 10] = sram_rdata_0[(9*(2-in_cnt) + 2)*10 +: 10];
                in[14*10 +: 10] = sram_rdata_0[(9*(2-in_cnt) + 1)*10 +: 10];
                in[15*10 +: 10] = sram_rdata_3[(9*(2-in_cnt) + 8)*10 +: 10];
                in[16*10 +: 10] = sram_rdata_3[(9*(2-in_cnt) + 7)*10 +: 10];
                in[17*10 +: 10] = sram_rdata_3[(9*(2-in_cnt) + 6)*10 +: 10];
                in[18*10 +: 10] = sram_rdata_2[(9*(2-in_cnt) + 8)*10 +: 10];
                in[19*10 +: 10] = sram_rdata_2[(9*(2-in_cnt) + 7)*10 +: 10];
                in[20*10 +: 10] = sram_rdata_3[(9*(2-in_cnt) + 5)*10 +: 10];
                in[21*10 +: 10] = sram_rdata_3[(9*(2-in_cnt) + 4)*10 +: 10];
                in[22*10 +: 10] = sram_rdata_3[(9*(2-in_cnt) + 3)*10 +: 10];
                in[23*10 +: 10] = sram_rdata_2[(9*(2-in_cnt) + 5)*10 +: 10];
                in[24*10 +: 10] = sram_rdata_2[(9*(2-in_cnt) + 4)*10 +: 10];

            end
            2'b10:begin
                in[ 0*10 +: 10] = sram_rdata_2[(9*(2-in_cnt) + 8)*10 +: 10];
                in[ 1*10 +: 10] = sram_rdata_2[(9*(2-in_cnt) + 7)*10 +: 10];
                in[ 2*10 +: 10] = sram_rdata_2[(9*(2-in_cnt) + 6)*10 +: 10];
                in[ 3*10 +: 10] = sram_rdata_3[(9*(2-in_cnt) + 8)*10 +: 10];
                in[ 4*10 +: 10] = sram_rdata_3[(9*(2-in_cnt) + 7)*10 +: 10];
                in[ 5*10 +: 10] = sram_rdata_2[(9*(2-in_cnt) + 5)*10 +: 10];
                in[ 6*10 +: 10] = sram_rdata_2[(9*(2-in_cnt) + 4)*10 +: 10];
                in[ 7*10 +: 10] = sram_rdata_2[(9*(2-in_cnt) + 3)*10 +: 10];
                in[ 8*10 +: 10] = sram_rdata_3[(9*(2-in_cnt) + 5)*10 +: 10];
                in[ 9*10 +: 10] = sram_rdata_3[(9*(2-in_cnt) + 4)*10 +: 10];     
                in[10*10 +: 10] = sram_rdata_2[(9*(2-in_cnt) + 2)*10 +: 10];
                in[11*10 +: 10] = sram_rdata_2[(9*(2-in_cnt) + 1)*10 +: 10];
                in[12*10 +: 10] = sram_rdata_2[(9*(2-in_cnt) + 0)*10 +: 10];
                in[13*10 +: 10] = sram_rdata_3[(9*(2-in_cnt) + 2)*10 +: 10];
                in[14*10 +: 10] = sram_rdata_3[(9*(2-in_cnt) + 1)*10 +: 10];
                in[15*10 +: 10] = sram_rdata_0[(9*(2-in_cnt) + 8)*10 +: 10];
                in[16*10 +: 10] = sram_rdata_0[(9*(2-in_cnt) + 7)*10 +: 10];
                in[17*10 +: 10] = sram_rdata_0[(9*(2-in_cnt) + 6)*10 +: 10];
                in[18*10 +: 10] = sram_rdata_1[(9*(2-in_cnt) + 8)*10 +: 10];
                in[19*10 +: 10] = sram_rdata_1[(9*(2-in_cnt) + 7)*10 +: 10];
                in[20*10 +: 10] = sram_rdata_0[(9*(2-in_cnt) + 5)*10 +: 10];
                in[21*10 +: 10] = sram_rdata_0[(9*(2-in_cnt) + 4)*10 +: 10];
                in[22*10 +: 10] = sram_rdata_0[(9*(2-in_cnt) + 3)*10 +: 10];
                in[23*10 +: 10] = sram_rdata_1[(9*(2-in_cnt) + 5)*10 +: 10];
                in[24*10 +: 10] = sram_rdata_1[(9*(2-in_cnt) + 4)*10 +: 10];

            end
            default:begin
                in[ 0*10 +: 10] = sram_rdata_3[(9*(2-in_cnt) + 8)*10 +: 10];
                in[ 1*10 +: 10] = sram_rdata_3[(9*(2-in_cnt) + 7)*10 +: 10];
                in[ 2*10 +: 10] = sram_rdata_3[(9*(2-in_cnt) + 6)*10 +: 10];
                in[ 3*10 +: 10] = sram_rdata_2[(9*(2-in_cnt) + 8)*10 +: 10];
                in[ 4*10 +: 10] = sram_rdata_2[(9*(2-in_cnt) + 7)*10 +: 10];
                in[ 5*10 +: 10] = sram_rdata_3[(9*(2-in_cnt) + 5)*10 +: 10];
                in[ 6*10 +: 10] = sram_rdata_3[(9*(2-in_cnt) + 4)*10 +: 10];
                in[ 7*10 +: 10] = sram_rdata_3[(9*(2-in_cnt) + 3)*10 +: 10];
                in[ 8*10 +: 10] = sram_rdata_2[(9*(2-in_cnt) + 5)*10 +: 10];
                in[ 9*10 +: 10] = sram_rdata_2[(9*(2-in_cnt) + 4)*10 +: 10];
                in[10*10 +: 10] = sram_rdata_3[(9*(2-in_cnt) + 2)*10 +: 10];
                in[11*10 +: 10] = sram_rdata_3[(9*(2-in_cnt) + 1)*10 +: 10];
                in[12*10 +: 10] = sram_rdata_3[(9*(2-in_cnt) + 0)*10 +: 10];
                in[13*10 +: 10] = sram_rdata_2[(9*(2-in_cnt) + 2)*10 +: 10];
                in[14*10 +: 10] = sram_rdata_2[(9*(2-in_cnt) + 1)*10 +: 10];
                in[15*10 +: 10] = sram_rdata_1[(9*(2-in_cnt) + 8)*10 +: 10];
                in[16*10 +: 10] = sram_rdata_1[(9*(2-in_cnt) + 7)*10 +: 10];
                in[17*10 +: 10] = sram_rdata_1[(9*(2-in_cnt) + 6)*10 +: 10];
                in[18*10 +: 10] = sram_rdata_0[(9*(2-in_cnt) + 8)*10 +: 10];
                in[19*10 +: 10] = sram_rdata_0[(9*(2-in_cnt) + 7)*10 +: 10];
                in[20*10 +: 10] = sram_rdata_1[(9*(2-in_cnt) + 5)*10 +: 10];
                in[21*10 +: 10] = sram_rdata_1[(9*(2-in_cnt) + 4)*10 +: 10];
                in[22*10 +: 10] = sram_rdata_1[(9*(2-in_cnt) + 3)*10 +: 10];
                in[23*10 +: 10] = sram_rdata_0[(9*(2-in_cnt) + 5)*10 +: 10];
                in[24*10 +: 10] = sram_rdata_0[(9*(2-in_cnt) + 4)*10 +: 10];

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
    if(state == BLANK || state == CONV1)begin
        if(bias_cnt == 1)begin
            b[0] <= {sram_rdata_bias, 8'd0};
        end
        else if (bias_cnt == 2)begin
            b[1] <= {sram_rdata_bias, 8'd0};
        end
        else begin
            b[2] <= {sram_rdata_bias, 8'd0};
        end
    end
    else begin
        b[0] <= {sram_rdata_bias,8'd0};
    end
end

always@(*)begin
    if(state == CONV1)begin
        for(m = 0 ; m < 9 ; m = m + 1)begin
            for(n = 0 ; n < 3 ; n = n + 1)begin
                mul_result_n[m*3 + n + 0] = f[9*(n+1)-m-1] * w[n+6];
            end
        end
        for(m = 0 ; m < 9 ; m = m + 1)begin
            for(n = 0 ; n < 3 ; n = n + 1)begin
                mul_result_n[m*3 + n + 27] = f[9*(n+1)-m-1] * w[n+3];
            end
        end
        for(m = 0 ; m < 9 ; m = m + 1)begin
            for(n = 0 ; n < 3 ; n = n + 1)begin
                mul_result_n[m*3 + n + 54] = f[9*(n+1)-m-1] * w[n];
            end
        end
    end
    else if(state == CONV2)begin
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
    else begin
        for(m=0; m < 81; m = m + 1)begin
            mul_result_n[m] = 0;
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
        for(s = 0 ; s < 3 ; s = s + 1)begin
            for(p = 0 ; p < 9; p = p + 1)begin
                sum_n[p+s*9] = mul_result[p*3 + s*27 + 0] + mul_result[p*3 + s*27 + 1] + mul_result[p*3 + s*27 + 2] + b[s]; 
            end
        end
    end
    else if(state == CONV2)begin
        for(s = 0 ; s < 9 ; s = s + 1)begin
            sum_n[s] = mul_result[s*9 + 0] + mul_result[s*9 + 1] + mul_result[s*9 + 2] + 
                       mul_result[s*9 + 3] + mul_result[s*9 + 4] + mul_result[s*9 + 5] + 
                       mul_result[s*9 + 6] + mul_result[s*9 + 7] + mul_result[s*9 + 8];
        end
        for(s = 9 ; s < 27 ; s = s + 1)begin
            sum_n[s] = 0;
        end
    end
    else begin
        for(s = 0 ; s < 27 ; s = s + 1)begin
            sum_n[s] = 0;
        end
    end
end

always@(posedge clk)begin
    if(state == CONV1)begin
        for(q = 0 ; q < 27 ; q = q + 1)begin
            sum[q] <= sum_n[q];
        end
    end
    else if (state == CONV2)begin
        for(q = 0 ; q < 9 ; q = q + 1)begin
            sum[q] <= (in_cnt == 2)? b[0] + sum_n[q] : sum[q] + sum_n[q];
        end
        for(q = 9 ; q < 27 ; q = q + 1)begin
            sum[q] = 0;
        end
    end
end

always@(*)begin
    for(r = 0 ; r < 27 ; r = r + 1)begin
        unsigned_sum[r] = sum[r];
    end
    for(r = 0 ; r < 27 ; r = r + 1)begin
        out[r] = unsigned_sum[r] + 8'b1000_0000;
    end
    if(state == CONV1)begin
        for(r = 0 ; r < 27 ; r = r + 1)begin
            sram_wdata_n[(26-r)*10 +: 10] = out[r][8+:10];
        end
    end
    else if (state == CONV2)begin
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
    else begin
        sram_wdata_n = 0;
    end
end

wire [1:0] test_delay = {x_delay[2][0],y_delay[2][0]};
always@(*)begin
    if(state == CONV1)begin
        case({y_delay[2][0],x_delay[2][0]})
            2'b00:begin
                sram_wen_0_n = 0;
                sram_wen_1_n = 1;
                sram_wen_2_n = 1;
                sram_wen_3_n = 1;
            end
            2'b01:begin
                sram_wen_0_n = 1;
                sram_wen_1_n = 0;
                sram_wen_2_n = 1;
                sram_wen_3_n = 1;
            end
            2'b10:begin
                sram_wen_0_n = 1;
                sram_wen_1_n = 1;
                sram_wen_2_n = 0;
                sram_wen_3_n = 1;
            end
            2'b11:begin
                sram_wen_0_n = 1;
                sram_wen_1_n = 1;
                sram_wen_2_n = 1;
                sram_wen_3_n = 0;
            end
            default:begin
                sram_wen_0_n = 1;
                sram_wen_1_n = 1;
                sram_wen_2_n = 1;
                sram_wen_3_n = 1;
            end
        endcase
    end
    else if (state == CONV2) begin
        sram_wen_0_n = (in_cnt == 2) ? ~(x_delay[2][0]==0 & y_delay[2][0]==0) : 1;
        sram_wen_1_n = (in_cnt == 2) ? ~(x_delay[2][0]==1 & y_delay[2][0]==0) : 1;
        sram_wen_2_n = (in_cnt == 2) ? ~(x_delay[2][0]==0 & y_delay[2][0]==1) : 1;
        sram_wen_3_n = (in_cnt == 2) ? ~(x_delay[2][0]==1 & y_delay[2][0]==1) : 1;        
    end
    else begin    
        sram_wen_0_n = 1;
        sram_wen_1_n = 1;
        sram_wen_2_n = 1;
        sram_wen_3_n = 1;
    end
end

always@(*)begin
    if(state == CONV1)begin
        sram_wordmask_n = 27'd0;
    end
    else if (state == CONV2)begin
        sram_wordmask_n[ 0] = ~(weight_cnt_delay[4]==2); 
        sram_wordmask_n[ 1] = ~(weight_cnt_delay[4]==2); 
        sram_wordmask_n[ 2] = ~(weight_cnt_delay[4]==2); 
        sram_wordmask_n[ 3] = ~(weight_cnt_delay[4]==2); 
        sram_wordmask_n[ 4] = ~(weight_cnt_delay[4]==2); 
        sram_wordmask_n[ 5] = ~(weight_cnt_delay[4]==2); 
        sram_wordmask_n[ 6] = ~(weight_cnt_delay[4]==2); 
        sram_wordmask_n[ 7] = ~(weight_cnt_delay[4]==2); 
        sram_wordmask_n[ 8] = ~(weight_cnt_delay[4]==2); 
        
        sram_wordmask_n[ 9] = ~(weight_cnt_delay[4]==1); 
        sram_wordmask_n[10] = ~(weight_cnt_delay[4]==1); 
        sram_wordmask_n[11] = ~(weight_cnt_delay[4]==1); 
        sram_wordmask_n[12] = ~(weight_cnt_delay[4]==1); 
        sram_wordmask_n[13] = ~(weight_cnt_delay[4]==1); 
        sram_wordmask_n[14] = ~(weight_cnt_delay[4]==1); 
        sram_wordmask_n[15] = ~(weight_cnt_delay[4]==1); 
        sram_wordmask_n[16] = ~(weight_cnt_delay[4]==1); 
        sram_wordmask_n[17] = ~(weight_cnt_delay[4]==1); 
        
        sram_wordmask_n[18] = ~(weight_cnt_delay[4]==0); 
        sram_wordmask_n[19] = ~(weight_cnt_delay[4]==0); 
        sram_wordmask_n[20] = ~(weight_cnt_delay[4]==0); 
        sram_wordmask_n[21] = ~(weight_cnt_delay[4]==0); 
        sram_wordmask_n[22] = ~(weight_cnt_delay[4]==0); 
        sram_wordmask_n[23] = ~(weight_cnt_delay[4]==0); 
        sram_wordmask_n[24] = ~(weight_cnt_delay[4]==0); 
        sram_wordmask_n[25] = ~(weight_cnt_delay[4]==0); 
        sram_wordmask_n[26] = ~(weight_cnt_delay[4]==0); 
    end
    else begin
        sram_wordmask_n = 27'b1111_1111_1111_1111_1111_1111_111;
    end
end


always@(*)begin
    if(state == CONV2)begin
        weight_cnt_n = (in_x == 19 && in_y == 15 && in_cnt == 0)? weight_cnt + 1 : weight_cnt;
    end
    else begin
        weight_cnt_n = 0;
    end
end
/*
always@(*)begin
    if(state == CONV1)begin
        sram_waddr_n = x_delay[2][6:1] + y_delay[2][6:1]*10 + 80;
    end
    else begin
        sram_waddr_n = x_delay[2][6:1] + y_delay[2][6:1]*10 + 160;
    end
end
*/
always@(*)begin
    sram_waddr_n = x_delay[2][6:1] + y_delay[2][6:1]*10;
end


always@(*)begin
    if(state == IDLE || state == BLANK || state == CONV1)begin
        sram_raddr_0_n = in_x[6:1] + in_y[6:1]*10;
        sram_raddr_1_n = in_x[6:1] + in_y[6:1]*10;
        sram_raddr_2_n = in_x[6:1] + in_y[6:1]*10;
        sram_raddr_3_n = in_x[6:1] + in_y[6:1]*10;
    end
    else begin
        sram_raddr_0_n = in_x[6:1] + in_x[0] + (in_y[6:1] + in_y[0]) * 10 + 80;
        sram_raddr_1_n = in_x[6:1]           + (in_y[6:1] + in_y[0]) * 10 + 80;
        sram_raddr_2_n = in_x[6:1] + in_x[0] + (in_y[6:1]          ) * 10 + 80;
        sram_raddr_3_n = in_x[6:1]           + (in_y[6:1]          ) * 10 + 80;
    end
end


always@(*)begin
    if(state == IDLE || state == BLANK ||state == CONV1)begin
        sram_raddr_weight_n = 0;
    end
    else if(state == BLANK2 || state == CONV2)begin
        if(in_cnt == 2)begin
            sram_raddr_weight_n = 2 + weight_cnt*3;
        end
        else if(in_cnt == 0)begin
            sram_raddr_weight_n = 3 + weight_cnt*3;
        end
        else begin
            sram_raddr_weight_n = 1 + weight_cnt*3;
        end
    end
    else begin
        sram_raddr_weight_n = 0;
    end
end



always@(*)begin
    if(state == IDLE)begin
        sram_raddr_bias_n = 0;
        bias_cnt_n = 0;
    end
    else if(state == BLANK || state == CONV1)begin
        sram_raddr_bias_n = (sram_raddr_bias == 2)? sram_raddr_bias : sram_raddr_bias + 1;
        bias_cnt_n = (bias_cnt == 3)? bias_cnt : bias_cnt+1;
    end
    else if(state == BLANK2 || state == CONV2)begin
        sram_raddr_bias_n = (in_x == 0 && in_y == 0 && in_cnt == 2) ? sram_raddr_bias + 1 : sram_raddr_bias;
        bias_cnt_n = 0;
    end
    else begin
        sram_raddr_bias_n = sram_raddr_bias;
        bias_cnt_n = 0;
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

    weight_cnt <= weight_cnt_n;

    bias_cnt <= bias_cnt_n;

    valid_conv1 <= valid_conv1_n;
end

always@(*)begin
    valid_n = (state == FINISH)? 1:0; 
    valid_conv1_n = (state == WAIT_SHIFT_MEM || state == WAIT_SHIFT_MEM2)? 1: 0;
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
            in_x_n = 0;
            in_y_n = 0;
            x_n = 0;
            y_n = 0;
        end
        BLANK:begin
            state_n = (in_cnt == 2)? CONV1 : BLANK;
            in_cnt_n = (in_cnt == 2)? 0 : in_cnt + 1;
            
            in_x_n = (in_cnt == 1 || in_cnt == 2)? in_x + 1 : in_x;
            in_y_n = 0;
            
            x_n = 0;
            y_n = 0;            
        end
        CONV1:begin
            state_n = (x_delay[2] == 19 && y_delay[2] == 15) ? WAIT_SHIFT_MEM : CONV1;
            //in_cnt_n = (in_cnt == 3) ? 0 : in_cnt + 1;
            in_cnt_n = 0;

            in_x_n = (in_x == 19) ? 0 : in_x + 1;
            in_y_n = (in_x == 19) ? in_y + 1 : in_y;

            x_n = (x == 19) ? 0 : x + 1;
            y_n = (x == 19) ? y + 1 : y;
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

            //in_x_n = (in_cnt == 0)? 0 : in_x + 1;
            in_x_n = 0;
            in_y_n = 0;

            x_n = 0;
            y_n = 0;
        end
        CONV2:begin
            state_n =  (x_delay[2] == 19 && y_delay[2] == 15 && in_cnt == 2 && weight_cnt_delay[4] == 2) ? WAIT_SHIFT_MEM2 : CONV2;
            //state_n = CONV2;
            in_cnt_n = (in_cnt == 2) ? 0 : in_cnt + 1;

            in_x_n = (in_cnt == 0) ? (in_x == 19) ? 0 : in_x + 1 : in_x;
            in_y_n = (in_cnt == 0) ? (in_x == 19) ? (in_y == 15)? 0 : in_y + 1 : in_y : in_y;

            //x_n = (x == 39) ? 0 : x + 1;
            //y_n = (x == 39) ? y + 1 : y;
            
            x_n = (in_cnt == 2) ? (x == 19) ? 0 : x + 1 : x;
            y_n = (in_cnt == 2) ? (x == 19) ? (y==15) ? 0 :  y + 1 : y : y;
        end
        
        WAIT_SHIFT_MEM2:begin
            state_n = (shift_finish) ? FINISH : WAIT_SHIFT_MEM2;
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

