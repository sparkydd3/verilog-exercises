`include "assert.vh"
`timescale 1 ns / 1 ps

module bin2bcd_tb;
	// clock and reset setup	
	localparam T = 20;	// 20 ns clock period
	reg clk, reset;

	// uut setup
	reg [13:0] bin_i;
	reg start_i;
	
	reg [3:0] bcd3_e, bcd2_e, bcd1_e, bcd0_e;
	reg ready_e, done_e, overflow_e;
	wire [3:0] bcd3_o, bcd2_o, bcd1_o, bcd0_o;
	wire ready_o, done_o, overflow_o;

	bin2bcd uut
		(.iCLK(clk), .iRESET(reset),
		 .iBIN(bin_i),
		 .iSTART(start_i),
		 .oBCD3(bcd3_o), .oBCD2(bcd2_o), .oBCD1(bcd1_o), .oBCD0(bcd0_o),
		 .oREADY(ready_o), .oDONE(done_o), .oOFLOW(overflow_o));


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
	integer vec_num;
	reg [33:0] testvectors[N-1:0];

	initial
	begin
		$readmemb("../test/tv/bin2bcd_tb.tv", testvectors);
		{bin_i, start_i, 
		 bcd3_e, bcd2_e, bcd1_e, bcd0_e, 
		 ready_e, done_e, overflow_e} = testvectors[0];
		@(negedge reset);	// wait for reset deassert
		
		for (vec_num = 0; vec_num < N; vec_num = vec_num + 1)
		begin
			{bin_i, start_i, 
			 bcd3_e, bcd2_e, bcd1_e, bcd0_e, 
			 ready_e, done_e, overflow_e} = testvectors[vec_num];
			#(T/4);
			`ASSERT((
				{bcd3_o, bcd2_o, bcd1_o, bcd0_o, ready_o, done_o, overflow_o} == 
				{bcd3_e, bcd2_e, bcd1_e, bcd0_e, ready_e, done_e, overflow_e}), 
				("test vector #%0d failed", vec_num));
			@(posedge clk);
		end
		
		$display("Test finished succesfully");
		$finish;
	end
endmodule
