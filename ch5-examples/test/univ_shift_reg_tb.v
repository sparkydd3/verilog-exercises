`include "assert.vh"
`timescale 1 ns / 1 ps

module univ_shift_reg_tb;
	// clock and reset setup	
	localparam T = 20;	// 20 ns clock period
	reg clk, reset;

	// uut setup
	localparam REG_N = 8;
	reg [REG_N-1:0] d_i, q_e;
	reg [1:0] ctrl_i;
	wire [REG_N-1:0] q_o;

	univ_shift_reg #(.N(REG_N)) uut
		(.clk(clk), .reset(reset), 
		 .ctrl(ctrl_i), .d(d_i), .q(q_o));

	// clock generator
	always begin
		clk = 1'b1;
		#(T/2);
		clk = 1'b0;
		#(T/2);
	end

	// watchdog circuit
	localparam T_WD = 100 * 20;
	initial begin
		#(T_WD);
		`ASSERT((0), ("Watchdog expired: %0d ns", T_WD));		
	end

	// initial reset
	initial begin
		reset = 1'b1;
		#(T/2);
		reset = 1'b0;
	end

	// test vector generator
	localparam N = 21;
	integer clk_num;
	reg [(2*REG_N+1):0] testvectors[N-1:0];

	initial
	begin
		$readmemb("../test/tv/univ_shift_reg_tb.tv", testvectors);
		{d_i, q_e, ctrl_i} = testvectors[0];
		@(negedge reset);	// wait for reset deassert
		
		for (clk_num = 1; clk_num < N; clk_num = clk_num + 1)
		begin
			@(posedge clk);
			`ASSERT((q_o == q_e), 
				("clk cycle #%0d: input = (%b: %b), output = %b, expected = %b",
				 clk_num - 1, ctrl_i, d_i, q_o, q_e));

			{d_i, q_e, ctrl_i} = testvectors[clk_num];
		end
		
		$display("Test finished succesfully");
		$finish;
	end
endmodule
