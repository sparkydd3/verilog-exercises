`include "assert.vh"
`timescale 1 ns / 1 ps

module fp2smag_tb;
	// test signals
	reg [12:0] fp_i;
	wire [7:0] smag_o;
	reg [7:0] smag_e;
	wire OF_o, UF_o;
	reg OF_e, UF_e;

	// test vector setup
	localparam N = 10;
	integer vectornum;
	reg [22:0] testvectors[N-1:0];

	// unit under test
	fp2smag uut
		(.iFp(fp_i), .oSmag(smag_o), 
		 .oOF(OF_o), .oUF(UF_o));
	
	initial
	begin
		$readmemb("../test/tv/fp2smag_tb.tv", testvectors);

		for (vectornum = 0; vectornum < N; vectornum = vectornum + 1)
		begin
			{fp_i, smag_e, OF_e, UF_e} = testvectors[vectornum];
			#100;
		
			`ASSERT(({smag_o, OF_o, UF_o} == 
			         {smag_e, OF_e, UF_e}), 
				({"test vector #%0d: ",
				  "input = {%b %0d %b}, ",
				  "output = {%b %0d %b %b}, ",
				  "expected = {%b %0d %b %b}"},
				  vectornum, 
				  fp_i[12], fp_i[11:8], fp_i[7:0],
				  smag_o[7], smag_o[6:0], OF_o, UF_o,
				  smag_e[7], smag_e[6:0], OF_e, UF_e));
		end
		$display("Test finished succesfully");
		$finish;
	end
endmodule
