`include "assert.vh"
`timescale 1 ns / 1 ps

module bcd2bin_tb;
	// clock and reset setup	
	localparam T = 20;	// 20 ns clock period
	reg clk, reset;

	// uut setup
	reg [3:0] bcd3_i, bcd2_i, bcd1_i, bcd0_i;
	reg start_i;
	
	reg [13:0] bin_e;
	reg ready_e, done_e;
	wire [13:0] bin_o;
	wire ready_o, done_o;

	bcd2bin uut
		(.iCLK(clk), .iRESET(reset),
		 .iBCD3(bcd3_i), .iBCD2(bcd2_i), .iBCD1(bcd1_i), .iBCD0(bcd0_i),
		 .iSTART(start_i),
		 .oBIN(bin_o), 
		 .oREADY(ready_o), .oDONE(done_o));


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
	localparam N = 40;
	integer clk_num;
	reg [36:0] testvectors[N-1:0];

	initial
	begin
		$readmemb("../test/tv/bcd2bin_tb.tv", testvectors);
		{bcd3_i, bcd2_i, bcd1_i, bcd0_i, start_i, bin_e, ready_e, done_e} = testvectors[0];
		@(negedge reset);	// wait for reset deassert
		
		for (clk_num = 0; clk_num < N; clk_num = clk_num + 1)
		begin
			{bcd3_i, bcd2_i, bcd1_i, bcd0_i, start_i, bin_e, ready_e, done_e} = testvectors[clk_num];
			#(T/4);
			`ASSERT(({ready_o, done_o, bin_o} == {ready_e, done_e, bin_e}), 
				("test vector #%0d failed", clk_num));
			@(posedge clk);
		end
		
		$display("Test finished succesfully");
		$finish;
	end
endmodule
