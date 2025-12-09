// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission
module mac_tile (clk, out_s, in_w, out_e, in_n, inst_w, inst_e, reset, ws_os_mode);

parameter bw = 4;
parameter psum_bw = 16;

// inst[1]: execute, inst[0]: kernel loading
output [psum_bw-1:0] out_s;    // PSUM output (WS) or activation output (OS)
input  [bw-1:0] in_w;    	 // activation (WS) or weight (OS)
output [bw-1:0] out_e;    	 // activation output (WS) or weight output (OS)
input  [1:0] inst_w;   	 // instruction input from west
output [1:0] inst_e;   	 // instruction output to east
input  [psum_bw-1:0] in_n;    // PSUM input (WS) or activation input (OS)
input  clk;
input  reset;
input ws_os_mode;		// 0 = WS, 1 = OS

// add latches
reg [1:0] inst_q;    // instruction register
reg [bw-1:0] a_q;    // activation
reg [bw-1:0] b_q;    // weight
reg [psum_bw-1:0] c_q;    // partial sum
reg load_ready_q;    // indicator --> ready to load new weight

// MAC result
wire [psum_bw-1:0] mac_out;

mac #(.bw(bw), .psum_bw(psum_bw)) mac_instance (
    	.a(a_q),
    	.b(b_q),
    	.c(c_q),
    .out(mac_out)
);


// assign all reg to something to prevent flipflop -> latch
always @(posedge clk) begin

    // determine if load required
    if (reset) begin
   	 inst_q <= 2'b00;
   	 load_ready_q <= 1'b1;
   	 a_q <= 0;
   	 b_q <= 0;
   	 c_q <= 0;
    end else begin

		// Weight Stationary Mode
		if (!ws_os_mode) begin
			// load weights
			if (inst_w[0] && load_ready_q) begin
				b_q <= in_w;			// load weight from west
				load_ready_q <= 1'b0;	// weight loadde
			end
			// execution
			if (inst_w[1]) begin
				a_q <= in_w;		// activation from west
			end
			// propagate instruction
			if (!load_ready_q) begin
				inst_q[0] <= inst_w[0];		// propagate load after weights loaded
			end
			inst_q[1] <= inst_w[1];			// propagate the execution
			// PSUM (north to south)
			c_q <= in_n;
		end

		// Output Stationary Mode
		else begin
			// load weights
			if (inst_w[0] && load_ready_q) begin
				b_q <= in_w;
			end
			// execution
			if (inst_w[1]) begin
				a_q <= in_n[bw-1:0];	// activation from north
				c_q <= mac_out;			// accumulate PSUM
			end else begin
				c_q <= 0;		// clear PSUM
			end
			// propagate instruction
			inst_q <= inst_w;
		end

    end
end

// connect outputs for next PE (with new MUXes for WS vs. OS)
assign out_e = ws_os_mode ? b_q : a_q;	// WS (activation), OS (weight)
assign inst_e = inst_q;
assign out_s = ws_os_mode ? {{(psum_bw-bw){1'b0}}, a_q} : mac_out; // WS (PSUM), OS (activation)

endmodule
