`include "assert.vh"
`timescale 1 ns / 1 ps

module fp_adder_r2ne_tb;
	reg [7:0] frac1_i, frac2_i, frac_out_e;
	reg [3:0] exp1_i, exp2_i, exp_out_e;
	reg [3:0] sign1_i, sign2_i, sign_out_e;

	wire [7:0] frac_out_o;
	wire [3:0] exp_out_o;
	wire sign_out_o;


	localparam TEST_NUM = 12;
	integer vectornum;
	reg [47:0] testvectors[TEST_NUM-1:0];

	fp_adder_r2ne uut
		(.iSign1(sign1_i[0]), .iExp1(exp1_i), .iFrac1(frac1_i),
		 .iSign2(sign2_i[0]), .iExp2(exp2_i), .iFrac2(frac2_i),
		 .oSign(sign_out_o), .oExp(exp_out_o), .oFrac(frac_out_o));

	// test vector generator
	initial
	begin
		$readmemh("../test/tv/fp_adder_r2ne_tb.tv", testvectors);

		for (vectornum = 0; vectornum < TEST_NUM; vectornum = vectornum + 1)
		begin
			{sign1_i, exp1_i, frac1_i,
			 sign2_i, exp2_i, frac2_i,
			 sign_out_e, exp_out_e, frac_out_e} = testvectors[vectornum];
			
			#100;
		
			`ASSERT(
				({sign_out_e[0], exp_out_e, frac_out_e} == 
				 {sign_out_o,    exp_out_o, frac_out_o}), 
				({"test vector #%0d:\n",
				  "\tinput 1: (%b) (%0d) (%b)\n",
				  "\tinput 2: (%b) (%0d) (%b)\n",
				  "\toutput:  (%b) (%0d) (%b)\n",
				  "\texpect:  (%b) (%0d) (%b)\n"},
				  vectornum,
				  sign1_i[0], exp1_i, frac1_i,
				  sign2_i[0], exp2_i, frac2_i,
				  sign_out_o, exp_out_o, frac_out_o,
				  sign_out_e[0], exp_out_e, frac_out_e));
			#100;
		end

		$display("Test finished successfully");
		$finish;
	end
endmodule
