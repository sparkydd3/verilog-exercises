`include "assert.vh"
`timescale 1 ns / 1 ps

module parking_lot_counter_tb;
	// clock and reset setup	
	localparam T = 20;	// 20 ns clock period
	reg clk, reset;

	// uut setup
	reg a_i, b_i;
	reg enter_e, exit_e, error_e;
	wire enter_o, exit_o, error_o;

	parking_lot_counter uut
		(.iCLK(clk), .iRESET(reset),
		 .iA(a_i), .iB(b_i),
		 .oEnter(enter_o), .oExit(exit_o), .oError(error_o));


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
	localparam N = 80;
	integer clk_num;
	reg [4:0] testvectors[N-1:0];

	initial
	begin
		$readmemb("../test/tv/parking_lot_counter_tb.tv", testvectors);
		{a_i, b_i, enter_e, exit_e, error_e} = testvectors[0];
		@(negedge reset);	// wait for reset deassert
		
		for (clk_num = 0; clk_num < N; clk_num = clk_num + 1)
		begin
			{a_i, b_i, enter_e, exit_e, error_e} = testvectors[clk_num];
			#(T/4);
			`ASSERT(({enter_o, exit_o, error_o} == {enter_e, exit_e, error_e}), 
				("test vector #%0d failed", clk_num));
			@(posedge clk);
		end
		
		$display("Test finished succesfully");
		$finish;
	end
endmodule
