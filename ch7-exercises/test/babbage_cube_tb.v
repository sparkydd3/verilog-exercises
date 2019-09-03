`include "assert.vh"
`timescale 1 ns / 1 ps

module babbage_cube_tb;
	// clock and reset setup	
	localparam T = 20;	// 20 ns clock period
	reg clk, reset;

	// uut setup
	reg [5:0] n_i;
	reg start_i;
	
	wire [17:0] f_o;
	wire ready_o, done_o;

	babbage_cube uut
		(.iCLK(clk), .iRESET(reset),
		 .iN(n_i),
		 .iSTART(start_i),
		 .oF(f_o),
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
	localparam N = 64;
	integer vec_num;
	integer f;

	initial
	begin
		n_i = 0;
		start_i = 1'b0;
		@(negedge reset);	// wait for reset deassert
		
		for (vec_num = 0; vec_num < N; vec_num = vec_num + 1)
		begin
			f = vec_num**3 + 2*vec_num**2 + 2*vec_num + 1;
			n_i = vec_num[5:0];
			start_i = 1'b1;

			@(posedge clk);
			start_i = 1'b0;

			@(done_o);
			`ASSERT((f[17:0] == f_o), 
				("f(%0d) = %0d expected, got %0d", vec_num, f, f_o));
			@(posedge ready_o);
		end
		
		$display("Test finished succesfully");
		$finish;
	end
endmodule
