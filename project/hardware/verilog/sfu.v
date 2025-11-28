// Special Function Unit (SFU)
// Performs accumulation and ReLU operations
// Created for ECE284 Project Part 1

// TODO --> NEEDS CORRECTION
// currently, sfu.v only processes 1 single output channel out of the 1, 2, ... 8 lanes from MAC array output
// where each of these output channels performs 3x3 convolution
// so only doing accumulate + ReLU for a single output channel, but there are 7 other output channels
// need to wrap current code in a loop to process all output channels, each output channel must produce its own PSUM

module sfu #(
    parameter psum_bw = 16
) (
    input clk,
    input reset,
    input acc,                              // accumulation enable signal
    input signed [psum_bw-1:0] psum_in,     // partial sum input from psum memory
    output reg [psum_bw-1:0] sfp_out        // final output after acc + ReLU
);
    
    // hardware components (2's complement)
    reg signed [psum_bw-1:0] accumulator;
    wire signed [psum_bw-1:0] relu_out;
    
    // take sum + ReLU of partial sums
    always @(posedge clk) begin
        // reset signal
        if (reset) begin
            accumulator <= 0;
            sfp_out <= 0;
        end
        // accumulate (add current psum to running total)
        else if (acc) begin
            accumulator <= accumulator + psum_in;
        end
        // apply ReLU, reset accumulator for next set
        else begin
            sfp_out <= relu_out;
            accumulator <= 0;
        end
    end
    
    // ReLU: if negative (MSB=1 in 2's complement), output 0
    assign relu_out = accumulator[psum_bw-1] ? 0 : accumulator;

endmodule