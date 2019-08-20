`include "assert.vh"
`timescale 1 ns / 1 ps

module dec3to8_tb;
	reg  [2:0] Enc_i; 
	reg  [7:0] Dec_e;
	wire [7:0] Dec_o;

	localparam TEST_NUM = 8;
	integer vectornum;
	reg [10:0] testvectors[TEST_NUM-1:0];

	// instantiate the circuit under test
	dec3to8 uut (.iEnc(Enc_i), .oDec(Dec_o));

	// test vector generator
	initial
	begin
		$readmemb("../test/tv/dec3to8_tb.tv", testvectors);

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
