`include "assert.vh"
`timescale 1 ns / 1 ps

module div_tb;
	// clock and reset setup	
	localparam T = 20;	// 20 ns clock period
	reg clk, reset;

	// uut setup
	localparam W = 4;
	localparam CBIT = 3;
	reg [W-1:0] dvsr_i, dvnd_i;
	reg start_i;

	reg [W-1:0] quo_e, rmd_e;
	reg ready_e, done_e;
	wire [W-1:0] quo_o, rmd_o;
	wire ready_o, done_o;

	div #(.W(W), .CBIT(CBIT)) uut
		(.clk(clk), .reset(reset),
		 .dvsr(dvsr_i), .dvnd(dvnd_i), .start(start_i),
		 .ready(ready_o), .done_tick(done_o),
		 .quo(quo_o), .rmd(rmd_o));


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
	localparam N = 48;
	integer clk_num;
	reg [18:0] testvectors[N-1:0];

	initial
	begin
		$readmemb("../test/tv/div_tb.tv", testvectors);
		{dvsr_i, dvnd_i, start_i, quo_e, rmd_e, ready_e, done_e} = testvectors[0];
		@(negedge reset);	// wait for reset deassert
		
		for (clk_num = 0; clk_num < N; clk_num = clk_num + 1)
		begin
			{dvsr_i, dvnd_i, start_i, quo_e, rmd_e, ready_e, done_e} = testvectors[clk_num];
			#(T/4);
			`ASSERT(({ready_o, done_o, quo_o, rmd_o} == {ready_e, done_e, quo_e, rmd_e}), 
				("test vector #%0d failed", clk_num));
			@(posedge clk);
		end
		
		$display("Test finished succesfully");
		$finish;
	end
endmodule
