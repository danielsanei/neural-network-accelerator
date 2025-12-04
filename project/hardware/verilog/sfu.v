// Special Function Unit (SFU)
// Performs accumulation and ReLU operations

module sfu #(
    parameter psum_bw = 16,
    parameter col = 8
) (
    input clk,
    input reset,
    input acc,                                  // accumulation enable signal
    input signed [psum_bw*col-1:0] psum_in,     // PSUM inputs from OFIFO
    
    input signed [psum_bw*col-1:0] base_in,  //Earlier sums from PMEM
    output signed [psum_bw*col-1:0] sum_out, //New sum to write back to PMEM

    
    output reg signed [psum_bw*col-1:0] sfp_out        // final output after acc + ReLU
);
    
    // hardware components (2's complement) for each lane (output channel x8)
//    reg signed [psum_bw-1:0] accumulator [0:col-1];

//    wire signed [psum_bw-1:0] next_sum [0:col-1];

    wire signed [psum_bw-1:0] psum_lane [0:col-1];

    wire signed [psum_bw-1:0] base_lane [0:col-1];
    wire signed [psum_bw-1:0] sum_lane [0:col-1];
    wire signed [psum_bw-1:0] relu_lane [0:col-1];



    // create, wire 8 lanes for each PSUM
    genvar g;
    generate
        for (g = 0; g < col; g = g + 1) begin : GEN_LANES
            // assign to unpack input vector per lane
            assign psum_lane[g] = psum_in[psum_bw*(g+1)-1 : psum_bw*g];
	    assign base_lane[g] = base_in[psum_bw*(g+1)-1 : psum_bw*g];
   
            assign sum_lane[g] = base_lane[g] + psum_lane[g];
	 end
    endgenerate


    // take sum + ReLU of partial sums
    integer i;
    always @(posedge clk) begin
            if (reset) begin
                  sum_out <= {psum_bw*col{1'b0}};
                  sfp_out <= {psum_bw*col{1'b0}};
            end
       	    else begin
                for (i = 0; i < col; i = i + 1) begin
                    sum_out[psum_bw*(i+1)-1:psum_bw*i] <= sum_lane[i];
                end
		if (!acc) begin
                	for (i=0; i < col; i = i +1) begin
                           sfp_out[psum_bw*(i+1)-1 : psum_bw*i] <= (sum_lane[i][psum_bw-1]) ? {psum_bw{1'b0}} : sum_lane[i];
		   end
            	end
    	    end
    end
endmodule
