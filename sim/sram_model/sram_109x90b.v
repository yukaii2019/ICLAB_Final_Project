module sram_109x90b #(       //for weight
parameter WEIGHT_PER_ADDR = 9,
parameter BW_PER_PARAM = 10
)
(
input clk,
input csb,  //chip enable
input wsb,  //write enable
input [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] wdata, //write data
input [6:0] waddr, //write address
input [6:0] raddr, //read address

output reg [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] rdata
);
/*
Data location
/////////////////////
addr 0: conv1 weights(1)
addr 1~9: conv2 weights(9)
addr 10~27: conv3_1 weights(9)
addr 28~36: conv3 weights (9)
addr 37~54: conv4_1 weights (9)
addr 55~63: conv4_2 weights (9)
addr 64~72: conv4 weights (9)
addr 73~108: conv5 weights (9)
/////////////////////
*/
reg [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] mem [0:109-1];
reg [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] _rdata;

always @(posedge clk) begin
    if(~csb && ~wsb)
        mem[waddr] <= wdata;
end

always @(posedge clk) begin
    if(~csb)
        _rdata <= mem[raddr];
end

always @* begin
    rdata = #(1) _rdata;
end

task load_param(
    input integer index,
    input [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] param_input
);
    mem[index] = param_input;
endtask

endmodule
