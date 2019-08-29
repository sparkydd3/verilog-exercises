`include "assert.vh"
`timescale 1 ns / 1 ps

module pwm_tb;
	// clock and reset setup	
	localparam T = 20;	// 20 ns clock period
	reg clk, reset;

	// uut setup
	reg [3:0] w_i;
	reg pwm_e, en;
	wire pwm_o;

	pwm uut
		(.iClk(clk), .iReset(reset), .iEn(en),
		 .iW(w_i),
		 .oPWM(pwm_o));


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
	localparam N = 50;
	integer clk_num;
	reg [4:0] testvectors[N-1:0];

	initial
	begin
		en = 1'b1;

		$readmemb("../test/tv/pwm_tb.tv", testvectors);
		{w_i, pwm_e} = testvectors[0];
		@(negedge reset);	// wait for reset deassert
		
		for (clk_num = 1; clk_num < N; clk_num = clk_num + 1)
		begin
			@(posedge clk);
			`ASSERT((pwm_o == pwm_e), 
				("tick #%0d: output = %b, expected = %b",
				  clk_num - 1, pwm_o, pwm_e));

			{w_i, pwm_e} = testvectors[clk_num];
		end
		
		$display("Test finished succesfully");
		$finish;
	end
endmodule
