`include "assert.vh"
`timescale 1 ns / 1 ps

module bin2bcd_tb;
	// clock and reset setup	
	localparam T = 20;	// 20 ns clock period
	reg clk, reset;

	// uut setup
	reg [12:0] bin_i;
	reg start_i;

	reg [3:0] bcd3_e, bcd2_e, bcd1_e, bcd0_e;
	reg ready_e, done_e;
	wire [3:0] bcd3_o, bcd2_o, bcd1_o, bcd0_o;
	wire ready_o, done_o;

	bin2bcd uut
		(.clk(clk), .reset(reset),
		 .bin(bin_i), .start(start_i),
		 .ready(ready_o), .done_tick(done_o),
		 .bcd3(bcd3_o), .bcd2(bcd2_o), .bcd1(bcd1_o), .bcd0(bcd0_o));


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
	reg [31:0] testvectors[N-1:0];

	initial
	begin
		$readmemb("../test/tv/bin2bcd_tb.tv", testvectors);
		{bin_i, start_i, ready_e, done_e, bcd3_e, bcd2_e, bcd1_e, bcd0_e} = testvectors[0];
		@(negedge reset);	// wait for reset deassert
		
		for (clk_num = 0; clk_num < N; clk_num = clk_num + 1)
		begin
			{bin_i, start_i, ready_e, done_e, bcd3_e, bcd2_e, bcd1_e, bcd0_e} = testvectors[clk_num];
			#(T/4);
			`ASSERT(({ready_o, done_o, bcd3_o, bcd2_o, bcd1_o, bcd0_o} == 
				{ready_e, done_e, bcd3_e, bcd2_e, bcd1_e, bcd0_e}), 
				("test vector #%0d failed", clk_num));
			@(posedge clk);
		end
		
		$display("Test finished succesfully");
		$finish;
	end
endmodule
