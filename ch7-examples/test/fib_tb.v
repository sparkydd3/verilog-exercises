`include "assert.vh"
`timescale 1 ns / 1 ps

module fib_tb;
	// clock and reset setup	
	localparam T = 20;	// 20 ns clock period
	reg clk, reset;

	// uut setup
	reg [4:0] n_i;
	reg start_i;

	reg [19:0] f_e;
	reg ready_e, done_e;
	wire [19:0] f_o;
	wire ready_o, done_o;

	fib uut
		(.clk(clk), .reset(reset),
		 .i(n_i), .start(start_i),
		 .ready(ready_o), .done_tick(done_o),
		 .f(f_o));


	// clock generator
	always begin
		clk = 1'b1;
		#(T/2);
		clk = 1'b0;
		#(T/2);
	end

	// watchdog circuit
	localparam T_WD = 5000 * 20;
	initial begin
		#(T_WD);
		`ASSERT((0), ("Watchdog expired: %0d ns", T_WD));		
	end

	// initial reset
	initial begin
		reset = 1'b1;
		#(3*T/2);
		reset = 1'b0;
	end

	// test vector generator
	localparam N = 24;
	integer clk_num;
	reg [27:0] testvectors[N-1:0];

	initial
	begin
		$readmemb("../test/tv/fib_tb.tv", testvectors);
		{n_i, start_i, ready_e, done_e, f_e} = testvectors[0];
		@(negedge reset);	// wait for reset deassert
		
		for (clk_num = 0; clk_num < N; clk_num = clk_num + 1)
		begin
			{n_i, start_i, ready_e, done_e, f_e} = testvectors[clk_num];
			#(T/4);
			`ASSERT(({ready_o, done_o, f_o} == {ready_e, done_e, f_e}), 
				("test vector #%0d failed", clk_num));
			@(posedge clk);
		end
		
		$display("Test finished succesfully");
		$finish;
	end
endmodule
