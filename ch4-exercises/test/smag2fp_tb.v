`include "assert.vh"
`timescale 1 ns / 1 ps

module smag2fp_tb;
	// test signals
	reg [7:0] smag_i;
	reg [12:0] fp_e;
	wire [12:0] fp_o;

	// test vector setup
	localparam N = 10;
	integer vectornum;
	reg [20:0] testvectors[N-1:0];

	// unit under test
	smag2fp uut
		(.iSmag(smag_i), .oFp(fp_o));
	
	initial
	begin
		$readmemb("../test/tv/smag2fp_tb.tv", testvectors);

		for (vectornum = 0; vectornum < N; vectornum = vectornum + 1)
		begin
			{smag_i, fp_e} = testvectors[vectornum];
			#100;
		
			`ASSERT((fp_o == fp_e), 
				({"test vector #%0d:",
				  "input = {%b %d},",
				  "output = {%b %0d %b},",
				  "expected = {%b %0d %b}"},
				  vectornum, 
				  smag_i[7], smag_i[6:0],
				  fp_o[12], fp_o[11:8], fp_o[7:0],
				  fp_e[12], fp_e[11:8], fp_e[7:0]));
		end
		
		$display("Test finished succesfully");
		$finish;
	end
endmodule
