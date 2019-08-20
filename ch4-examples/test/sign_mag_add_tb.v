`include "assert.vh"
`timescale 1 ns / 1 ps

module sign_mag_add_tb;
	localparam N = 4;
	
	reg [N-1:0] a_i, b_i, sum_e;
	wire [N-1:0] sum_o;

	localparam TEST_NUM = 20;
	integer vectornum;
	reg [(3*N - 1):0] testvectors[TEST_NUM-1:0];

	sign_mag_add #(.N(4)) uut
		(.a(a_i), .b(b_i), .sum(sum_o));

	// test vector generator
	initial
	begin
		$readmemb("../test/tv/sign_mag_add_tb.tv", testvectors);

		for (vectornum = 0; vectornum < TEST_NUM; vectornum = vectornum + 1)
		begin
			{a_i, b_i, sum_e} = testvectors[vectornum];
			#100;
		
			`ASSERT((sum_o == sum_e), 
				({"test vector #%0d: input = {%b, %0d} + {%b, %0d}", 
				  "output = {%b, %0d}, expected = {%b, %0d}"},
				  vectornum, 
				  a_i[3], a_i[2:0], 
				  b_i[3], b_i[2:0],
				  sum_o[3], sum_o[2:0], 
				  sum_e[3], sum_e[2:0]));
		end

		$display("Test finished successfully");
		$finish;
	end
endmodule
