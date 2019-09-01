`include "assert.vh"
`timescale 1 ns / 1 ps

module dedge_det_mealy_tb;
	// clock and reset setup	
	localparam T = 20;	// 20 ns clock period
	reg clk, reset;

	// uut setup
	reg level_i;
	reg tick_pre, tick_post, tick_e;
	wire tick_o;

	dedge_det_mealy uut
		(.iCLK(clk), .iRESET(reset),
		 .iLEVEL(level_i),
		 .oTICK(tick_o));


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
	localparam N = 16;
	integer clk_num;
	reg [2:0] testvectors[N-1:0];

	initial
	begin
		$readmemb("../test/tv/dedge_det_mealy_tb.tv", testvectors);
		{level_i, tick_pre, tick_post} = testvectors[0];
		tick_e = tick_pre;
		@(negedge reset);	// wait for reset deassert
		
		for (clk_num = 0; clk_num < N; clk_num = clk_num + 1)
		begin
			{level_i, tick_pre, tick_post} = testvectors[clk_num];
			tick_e = tick_pre;
			#(T/4);
			`ASSERT((tick_o == tick_e), 
				("test vector #%0da failed", clk_num));
			@(posedge clk);
			tick_e = tick_post;
			#(T/4);
			`ASSERT((tick_o == tick_e), 
				("test vector #%0db failed", clk_num));
			@(negedge clk);
		end
		
		$display("Test finished succesfully");
		$finish;
	end
endmodule
