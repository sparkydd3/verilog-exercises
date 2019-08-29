`include "assert.vh"
`timescale 1 ns / 1 ps

module sw_gen_tb;
	// clock and reset setup	
	localparam T = 20;	// 20 ns clock period
	reg clk, reset;

	// uut setup
	reg [3:0] m_i, n_i;
	reg sq_e;
	wire sq_o;

	sw_gen uut
		(.iCLK(clk), .iRESET(reset), 
		 .iM(m_i), .iN(n_i),
		 .oSQ(sq_o));

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
	localparam N = 25;
	integer clk_num;
	reg [8:0] testvectors[N-1:0];

	initial
	begin
		$readmemb("../test/tv/sw_gen_tb.tv", testvectors);
		{m_i, n_i, sq_e} = testvectors[0];
		@(negedge reset);	// wait for reset deassert
		
		for (clk_num = 1; clk_num < N; clk_num = clk_num + 1)
		begin
			repeat(5) @(posedge clk);
			`ASSERT((sq_o == sq_e), 
				("tick #%0d: output = %b, expected = %b",
				  clk_num - 1, sq_o, sq_e));

			{m_i, n_i, sq_e} = testvectors[clk_num];
		end
		
		$display("Test finished succesfully");
		$finish;
	end
endmodule
