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

output reg [10:0] sram_raddr_0,
output reg [10:0] sram_raddr_1,
output reg [10:0] sram_raddr_2,
output reg [10:0] sram_raddr_3,

output reg [6:0] sram_raddr_weight,
output reg [4:0] sram_raddr_bias,

output reg sram_wen_0,
output reg sram_wen_1,
output reg sram_wen_2,
output reg sram_wen_3,

output reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask,

output reg [10:0] sram_waddr,

output reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata
);

localparam [4:0] IDLE = 0;
localparam [4:0] BLANK = 1;
//localparam [4:0] BLANK2 = 2;
localparam [4:0] CONV1 = 2;
localparam [4:0] FINISH = 3;


reg [10:0] sram_raddr_0_n;
reg [10:0] sram_raddr_1_n;
reg [10:0] sram_raddr_2_n;
reg [10:0] sram_raddr_3_n;
reg [6:0] sram_raddr_weight_n;
reg [4:0] sram_raddr_bias_n;

reg sram_wen_0_n;
reg sram_wen_1_n;
reg sram_wen_2_n;
reg sram_wen_3_n;

reg [27-1:0] sram_wordmask_n;
reg [10:0] sram_waddr_n;
reg [270-1:0] sram_wdata_n;
reg valid_n;

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
reg [22:0] sum [0:27-1];
reg [22:0] out [0:27];


reg [6:0] in_x, in_y;
reg [6:0] in_x_n, in_y_n;

reg [6:0] x,y;
reg [6:0] x_n,y_n;

reg [6:0] x_delay[0:3];
reg [6:0] y_delay[0:3];

//reg [5:0] x_div_3, y_div_3;


reg [1:0] bias_cnt, bias_cnt_n;


integer i,j,k,l,m,n,o,p,q,r,s;


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

always@(*)begin
    if(state == CONV1)begin
        for(i = 0 ; i < 27 ; i = i + 1)begin
            f_n[i] = in[10*i +: 10];
        end
    end
    else begin
        for(i = 0 ; i < 27 ; i = i + 1)begin
            f_n[i] = 0;
        end
    end
end

always@(posedge clk)begin
    for(j = 0 ; j < 27 ; j = j + 1)begin
        f[j] <= f_n[j];
    end
end

always@(*)begin
    for(k = 0 ; k<9 ; k = k + 1)begin
        w_n[k] = sram_rdata_weight[k*10 +: 10];
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
    //b <= 10'b00_0000_1011;
end

always@(*)begin
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

always@(posedge clk)begin
    for(o = 0; o < 81 ; o = o + 1)begin
        mul_result[o] <= mul_result_n[o];
    end
end

always@(*)begin
    for(s = 0 ; s < 3 ; s = s + 1)begin
        for(p = 0 ; p < 9; p = p + 1)begin
            sum_n[p+s*9] = mul_result[p*3 + s*27 + 0] + mul_result[p*3 + s*27 + 1] + mul_result[p*3 + s*27 + 2] + b[s]; 
        end
    end
end

always@(posedge clk)begin
    for(q = 0 ; q < 27 ; q = q + 1)begin
        sum[q] <= sum_n[q];
    end
end

always@(*)begin
    for(r = 0 ; r < 27 ; r = r + 1)begin
        out[r] = sum[r] + 8'b1000_0000;
    end
    for(r = 0 ; r < 27 ; r = r + 1)begin
        sram_wdata_n[(26-r)*10 +: 10] = out[r][8+:10];
    end
end


/*
f[26] * w[0];
f[17] * w[1];
f[ 8] * w[2];

f[25] * w[0];
f[16] * w[1];
f[ 7] * w[2];
*/

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
    else begin
        sram_wordmask_n = 27'b1111_1111_1111_1111_1111_1111_111;
    end
end

/*
always@(posedge clk)begin
    if(state == CONV1)begin
        x_div_3 <= (x_delay[2]==3)? (x_div_3 == 39) ? 0 : x_div_3 + 1 : x_div_3;
        y_div_3 <= (x_delay[2]==3 && x_div_3 == 39) ? y_div_3 + 1 : y_div_3;
    end
    else begin
        x_div_3 <= 0;
        y_div_3 <= 0;
    end
end

*/
/*
always@(*)begin
    x_div_3 = x_delay[2]/3;
    y_div_3 = y_delay[2]/3;
end
*/

always@(*)begin
    if(state == CONV1)begin
        sram_waddr_n = x_delay[2][6:1] + y_delay[2][6:1]*20 + 320;
    end
    else begin
        sram_waddr_n = 640;
    end
end

always@(*)begin
    sram_raddr_0_n = in_x[6:1] + in_y[6:1]*20;
    sram_raddr_1_n = in_x[6:1] + in_y[6:1]*20;
    sram_raddr_2_n = in_x[6:1] + in_y[6:1]*20;
    sram_raddr_3_n = in_x[6:1] + in_y[6:1]*20;
end


always@(*)begin
    if(state == IDLE || state == BLANK ||state == CONV1)begin
        sram_raddr_weight_n = 0;
    end
    else begin
        sram_raddr_weight_n = 0;
    end
end



always@(*)begin
    if(state == BLANK || state == CONV1)begin
        sram_raddr_bias_n = (sram_raddr_bias == 2)? sram_raddr_bias : sram_raddr_bias + 1;
        bias_cnt_n = (bias_cnt == 3)? bias_cnt : bias_cnt+1;
    end
    else begin
        sram_raddr_bias_n = 0;
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
    x_delay[3] <= x_delay[2];
    y_delay[3] <= y_delay[2];

    bias_cnt <= bias_cnt_n;
end

always@(*)begin
    valid_n = (state == FINISH)? 1:0; 
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
            
            in_x_n = (in_cnt == 1 || in_cnt == 2)? in_x_n + 1 : in_x_n;
            in_y_n = 0;
            
            x_n = 0;
            y_n = 0;
            
        end
        /*
        BLANK2:begin
            state_n = CONV1;
            in_cnt_n = 0;
            x_n = 0;
            y_n = 0;
        end
        */
        CONV1:begin
            state_n = (x_delay[2] == 39 && y_delay[2] == 31) ? FINISH : CONV1;
            in_cnt_n = (in_cnt == 3) ? 0 : in_cnt + 1;

            in_x_n = (in_x == 39) ? 0 : in_x + 1;
            in_y_n = (in_x == 39) ? in_y + 1 : in_y;

            //x_n = (x == 119) ? 0 : x + 1;
            //y_n = (x == 119) ? y + 1 : y;
            x_n = (x == 39) ? 0 : x + 1;
            y_n = (x == 39) ? y + 1 : y;
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

