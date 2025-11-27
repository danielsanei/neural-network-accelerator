// special function processor (accumulation + ReLU)
    // testbench will call SFU 9 times in sequence for 3x3 convolution
module sfu(
    input clk,
    input reset,
    input acc,                          // accumulator enable signal
    input [psum_bw-1:0] psum_in,        // partial sum input
    output reg [psum_bw-1:0] sfp_out    // acc + ReLU output
);

    // define hardware components
    parameter psum_bw = 16;
    reg [psum_bw-1:0] accumulator;
    wire [psum_bw-1:0] relu_out;

    // accumulation (sum the input partial sums)
    always @(posedge clk) begin
        
        // reset signal
        if (reset) begin
            accumulator <= 0;
            sfp_out <= 0;
        end else if (acc) begin
            // accumulate next psum
            accumulator <= accumulator + psum_in;
        end else begin
            // finished partial sums for current 3x3 output pixel
            sfp_out <= relu_out;    // apply ReLU
            accumulator <= 0;       // clear accumulator
        end
    end

    // apply ReLu
        // if MSB=1 (2's complement), then negative number
    assign relu_out = accumulator[psum_bw-1] ? 0 : accumulator;

endmodule