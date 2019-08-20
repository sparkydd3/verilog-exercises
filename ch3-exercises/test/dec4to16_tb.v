`include "assert.vh"
`timescale 1 ns / 1 ps

module dec4to16_tb;
	reg  [3:0]  Enc_i; 
	reg  [15:0] Dec_e;
	wire [15:0] Dec_o;

	localparam TEST_NUM = 16;
	integer vectornum;
	reg [19:0] testvectors[TEST_NUM-1:0];

	// instantiate the circuit under test
	dec4to16 uut (.iEnc(Enc_i), .oDec(Dec_o));

	// test vector generator
	initial
	begin
		$readmemb("../test/tv/dec4to16_tb.tv", testvectors);

		for (vectornum = 0; vectornum < TEST_NUM; vectornum = vectornum + 1)
		begin
			{Enc_i, Dec_e} = testvectors[vectornum];
			#100;
		
			`ASSERT((Dec_o == Dec_e), 
				("test vector #%0d: input = %0d, output = %b, expected = %b",
				vectornum, Enc_i, Dec_o, Dec_e));
		end
		$finish;
	end
endmodule
