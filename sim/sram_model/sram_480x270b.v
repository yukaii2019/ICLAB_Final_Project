module sram_480x270b #(     //for activation
parameter CH_NUM = 3,
parameter ACT_PER_ADDR = 9,
parameter BW_PER_ACT = 10
)
(
input clk,
input [CH_NUM*ACT_PER_ADDR-1:0] wordmask,  //27 bits
input csb,  //chip enable
input wsb,  //write enable
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] wdata, //write data 270 bits
input [8:0] waddr, //write address
input [8:0] raddr, //read address

output reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] rdata //read data 270 bits
);

reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] _rdata;
reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] mem [0:480-1];
wire [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] bit_mask;

assign bit_mask = {{10{wordmask[26]}}, {10{wordmask[25]}}, {10{wordmask[24]}}, {10{wordmask[23]}}, 
                   {10{wordmask[22]}}, {10{wordmask[21]}}, {10{wordmask[20]}}, {10{wordmask[19]}}, 
                   {10{wordmask[18]}}, {10{wordmask[17]}}, {10{wordmask[16]}}, {10{wordmask[15]}}, 
                   {10{wordmask[14]}}, {10{wordmask[13]}}, {10{wordmask[12]}}, {10{wordmask[11]}},
                   {10{wordmask[10]}}, {10{wordmask[ 9]}}, {10{wordmask[ 8]}}, {10{wordmask[ 7]}},
                   {10{wordmask[ 6]}}, {10{wordmask[ 5]}}, {10{wordmask[ 4]}}, {10{wordmask[ 3]}},
                   {10{wordmask[ 2]}}, {10{wordmask[ 1]}}, {10{wordmask[ 0]}}
                   };

always @(posedge clk) begin
    if(~csb && ~wsb) begin
        mem[waddr] <= (wdata & ~(bit_mask)) | (mem[waddr] & bit_mask);
    end
end

always @(posedge clk) begin
    if(~csb) begin
        _rdata <= mem[raddr];
    end
end

always @* begin
    rdata = #(1) _rdata;
end

task load_input_img(
    input integer index,
    input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] input_data
);
    mem[index] = input_data;
endtask

task load_a_position(
    input integer addr
    input integer index,
    input [BW_PER_ACT-1:0] input_data
);
    mem[addr][index*10+:10] = input_data;
endtask

endmodule
