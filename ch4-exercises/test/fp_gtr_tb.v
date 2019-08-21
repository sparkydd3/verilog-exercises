`include "assert.vh"
`timescale 1 ns / 1 ps

module fp_gtr_tb;
	reg sign1_i, sign2_i;
	reg [3:0] exp1_i, exp2_i;
	reg [7:0] frac1_i, frac2_i;

	wire gtr_o;
	reg gtr_e;

	localparam N = 10;
	integer vectornum;
	reg [26:0] testvectors[N-1:0];

	fp_gtr uut
		(.iSign1(sign1_i), .iExp1(exp1_i), .iFrac1(frac1_i),
		 .iSign2(sign2_i), .iExp2(exp2_i), .iFrac2(frac2_i),
		 .oGtr(gtr_o));

	// test vector generator
	initial
	begin
		$readmemb("../test/tv/fp_gtr_tb.tv", testvectors);

		for (vectornum = 0; vectornum < N; vectornum = vectornum + 1)
		begin
			{sign1_i, exp1_i, frac1_i,
			 sign2_i, exp2_i, frac2_i,
			 gtr_e} = testvectors[vectornum];
			#100;
		
			`ASSERT((gtr_o == gtr_e), 
				({"test vector #%0d: input = (%b %0d %b) (%b %0d %b)", 
				  "output = %b, expected = %b"},
				   vectornum, 
				   sign1_i, exp1_i, frac1_i, 
				   sign2_i, exp2_i, frac2_i,
				   gtr_o, gtr_e));
		end
		
		$display("Test finished succesfully");
		$finish;
	end
endmodule
