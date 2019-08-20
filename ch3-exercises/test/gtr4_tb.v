`include "assert.vh"
`timescale 1 ns / 1 ps

module gtr4_tb;
	reg [3:0] A_i, B_i;
	reg Gtr_e;
	wire Gtr_o;

	localparam TEST_NUM = 256;
	integer vectornum;
	reg [8:0] testvectors[TEST_NUM-1:0];

	// instantiate the circuit under test
	gtr4 uut (.iA(A_i), .iB(B_i), .oGtr(Gtr_o));

	// test vector generator
	initial
	begin
		$readmemb("../test/tv/gtr4_tb.tv", testvectors);

		for (vectornum = 0; vectornum < TEST_NUM; vectornum = vectornum + 1)
		begin
			{A_i, B_i, Gtr_e} = testvectors[vectornum];
			#100;
		
			`ASSERT((Gtr_o == Gtr_e), 
				("test vector #%0d: input = {%0d, %0d}, output = %b, expected = %b",
				vectornum,A_i, B_i, Gtr_o, Gtr_e));
		end
		$finish;
	end
endmodule
