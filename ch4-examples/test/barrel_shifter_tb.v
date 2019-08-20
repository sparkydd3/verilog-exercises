`include "assert.vh"
`timescale 1 ns / 1 ps

module barrel_shifter_tb;
	reg [7:0] a_i, y_e;
	reg [2:0] amt_i;
	wire [7:0] y_case_o, y_stage_o;

	localparam TEST_NUM = 8;
	integer vectornum;
	reg [18:0] testvectors[TEST_NUM-1:0];

	barrel_shifter_case uut_case
		(.a(a_i), .amt(amt_i), .y(y_case_o));
	barrel_shifter_stage uut_stage 
		(.a(a_i), .amt(amt_i), .y(y_stage_o));	

	// test vector generator
	initial
	begin
		$readmemb("../test/tv/barrel_shifter_tb.tv", testvectors);

		for (vectornum = 0; vectornum < TEST_NUM; vectornum = vectornum + 1)
		begin
			{a_i, amt_i, y_e} = testvectors[vectornum];
			#100;
		
			`ASSERT((y_case_o == y_e), 
				("test vector #%0d: case shifter: input = {%b, %0d}, output = %b, expected = %b",
				vectornum,a_i, amt_i, y_case_o, y_e));
			
			`ASSERT((y_stage_o == y_e), 
				("test vector #%0d: stage shifter: input = {%b, %0d}, output = %b, expected = %b",
				vectornum,a_i, amt_i, y_stage_o, y_e));
		end
		
		$display("Test finished succesfully");
		$finish;
	end
endmodule
