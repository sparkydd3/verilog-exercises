`include "assert.vh"
`timescale 1 ns / 1 ps

module eq2_tb;
	reg [1:0] A_i, B_i;
	reg Eq_e;
	wire Eq_o;

	localparam TEST_NUM = 16;
	integer vectornum;
	reg [4:0] testvectors[TEST_NUM-1:0];

	// instantiate the circuit under test
	eq2 uut (.iA(A_i), .iB(B_i), .oEq(Eq_o));

	// test vector generator
	initial
	begin
		$readmemb("../test/tv/eq2_tb.tv", testvectors);

		for (vectornum = 0; vectornum < TEST_NUM; vectornum = vectornum + 1)
		begin
			{A_i, B_i, Eq_e} = testvectors[vectornum];
			#100;
		
			`ASSERT((Eq_o == Eq_e), 
				("test vector #%0d: input = {%0d, %0d}, output = %b, expected = %b",
				vectornum,A_i, B_i, Eq_o, Eq_e));
		end
		$finish;
	end
endmodule
