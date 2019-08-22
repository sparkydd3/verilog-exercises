`include "assert.vh"
`timescale 1 ns / 1 ps

module mod_m_counter_tb;
	// clock and reset setup	
	localparam T = 20;	// 20 ns clock period
	reg clk, reset;

	// uut setup
	localparam REG_N = 4;
	localparam REG_M = 10;

	reg max_tick_e;
	reg [REG_N-1:0] q_e;
	wire max_tick_o;
	wire [REG_N-1:0] q_o;

	mod_m_counter #(.N(REG_N), .M(REG_M)) uut
		(.clk(clk), .reset(reset), 
		 .q(q_o), .max_tick(max_tick_o));

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
	localparam N = 20;
	integer clk_num;
	reg [REG_N:0] testvectors[N-1:0];

	initial
	begin
		$readmemb("../test/tv/mod_m_counter_tb.tv", testvectors);
		{q_e, max_tick_e} = testvectors[0];
		@(negedge reset);	// wait for reset deassert
		
		for (clk_num = 1; clk_num < N; clk_num = clk_num + 1)
		begin
			@(posedge clk);
			`ASSERT(({q_o, max_tick_o} == {q_e, max_tick_e}), 
				("clk cycle #%0d: output = (%b), expected = (%b)",
				  clk_num - 1, q_o, q_e));

			{q_e, max_tick_e} = testvectors[clk_num];
		end
		
		$display("Test finished succesfully");
		$finish;
	end
endmodule
