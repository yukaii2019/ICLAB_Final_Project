module sram_24x10b #(       //for bias
parameter BIAS_PER_ADDR = 1,
parameter BW_PER_PARAM = 10
)
(
input clk,
input csb,  //chip enable
input wsb,  //write enable
input [BIAS_PER_ADDR*BW_PER_PARAM-1:0] wdata, //write data
input [4:0] waddr, //write address
input [4:0] raddr, //read address

output reg [BIAS_PER_ADDR*BW_PER_PARAM-1:0] rdata
);
/*
Data location
/////////////////////
addr 0~2: conv1 bias(3)
addr 3~5: conv2 bias(3)
addr 6~8: conv3_1 bias(3)
addr 9~11: conv3 bias(3)
addr 12~14: conv4_1 bias(3)
addr 15~17: conv4_2 bias(3)
addr 18~20: conv4 bias(3)
addr 21~23: conv5 bias(3)
/////////////////////
*/
reg [BIAS_PER_ADDR*BW_PER_PARAM-1:0] mem [0:24-1];
reg [BIAS_PER_ADDR*BW_PER_PARAM-1:0] _rdata;

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
    input [BIAS_PER_ADDR*BW_PER_PARAM-1:0] param_input
);
    mem[index] = param_input;
endtask

endmodule