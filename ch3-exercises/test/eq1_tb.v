`include "assert.vh"
`timescale 1 ns / 1 ps

module eq1_tb;
	reg A_i, B_i;
	reg Eq_e;
	wire Eq_o;

	localparam TEST_NUM = 4;
	integer vectornum;
	reg [2:0] testvectors[TEST_NUM-1:0];

	// instantiate the circuit under test
	eq1 uut (.iA(A_i), .iB(B_i), .oEq(Eq_o));

	// test vector generator
	initial
	begin
		$readmemb("../test/tv/eq1_tb.tv", testvectors);

		for (vectornum = 0; vectornum < TEST_NUM; vectornum = vectornum + 1)
		begin
			{A_i, B_i, Eq_e} = testvectors[vectornum];
			#100;
		
			`ASSERT((Eq_o == Eq_e), 
				("test vector #%0d: input = {%0d, %0d}, output = %b, expected = %b",
				vectornum, A_i, B_i, Eq_o, Eq_e));
		end
		$finish;
	end
endmodule
