`include "assert.vh"
`timescale 1 ns / 1 ps

module univ_bin_counter_tb;
	// clock and reset setup	
	localparam T = 20;	// 20 ns clock period
	reg clk, reset;

	// uut setup
	localparam REG_N = 4;
	reg syn_clr_i, load_i, en_i, up_i;
	reg [REG_N-1:0] d_i;

	reg max_tick_e, min_tick_e;
	reg [REG_N-1:0] q_e;
	wire max_tick_o, min_tick_o;
	wire [REG_N-1:0] q_o;

	univ_bin_counter #(.N(REG_N)) uut
		(.clk(clk), .reset(reset), 
		 .d(d_i),
		 .syn_clr(syn_clr_i), .load(load_i), .en(en_i), .up(up_i),
		 .q(q_o), 
		 .max_tick(max_tick_o), .min_tick(min_tick_o));

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
	reg [(2*REG_N+5):0] testvectors[N-1:0];

	initial
	begin
		$readmemb("../test/tv/univ_bin_counter_tb.tv", testvectors);
		{d_i, q_e, syn_clr_i, load_i, en_i, up_i, max_tick_e, min_tick_e} = testvectors[0];
		@(negedge reset);	// wait for reset deassert
		
		for (clk_num = 1; clk_num < N; clk_num = clk_num + 1)
		begin
			@(posedge clk);
			`ASSERT(({q_o, max_tick_o, min_tick_o} == {q_e, max_tick_e, min_tick_e}), 
				("clk cycle #%0d: output = (%b), expected = (%b)",
				  clk_num - 1, q_o, q_e));

			{d_i, q_e, syn_clr_i, load_i, en_i, up_i, max_tick_e, min_tick_e} = testvectors[clk_num];
		end
		
		$display("Test finished succesfully");
		$finish;
	end
endmodule
