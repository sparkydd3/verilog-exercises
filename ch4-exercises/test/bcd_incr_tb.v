`include "assert.vh"
`timescale 1 ns / 1 ps

module bcd_incr_tb;
	reg [11:0] bcd_i, incr_e;
	reg [3:0] overflow_e, invalid_e;

	wire [11:0] incr_o;
	wire overflow_o, invalid_o;

	localparam N = 8;
	integer vectornum;
	reg [31:0] testvectors[N-1:0];

	bcd_incr uut
		(.iBCD(bcd_i), .oIncr(incr_o),
		 .oOverflow(overflow_o), .oInvalid(invalid_o));

	// test vector generator
	initial
	begin
		$readmemh("../test/tv/bcd_incr_tb.tv", testvectors);

		for (vectornum = 0; vectornum < N; vectornum = vectornum + 1)
		begin
			{bcd_i, incr_e, overflow_e, invalid_e} = testvectors[vectornum];
			#100;
		
			`ASSERT(
				(incr_o == incr_e && 
				 overflow_o == overflow_e[0] && 
				 invalid_o == invalid_e[0]), 
				({"test vector #%0d:\n",
				  "\tinput = %0h%0h%0h\n",
				  "\toutput = {%0h%0h%0h, %b %b}\n",
				  "\texpected = {%0h%0h%0h, %b %b}\n"},
				 vectornum, 
				 bcd_i[11:8], bcd_i[7:4], bcd_i[3:0], 
				 incr_o[11:8], incr_o[7:4], incr_o[3:0], overflow_o, invalid_o,
				 incr_e[11:8], incr_e[7:4], incr_e[3:0], overflow_e[0], invalid_e[0]));
		end
		
		$display("Test finished succesfully");
		$finish;
	end
endmodule
