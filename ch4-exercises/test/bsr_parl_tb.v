`include "assert.vh"
`timescale 1 ns / 1 ps

module bsr_parl_tb;
	localparam N = 8;
	localparam W = $clog2(N);

	reg [N-1:0] a_i, y_e;
	reg [W-1:0] amt_i;
	wire [N-1:0] y_o; 

	integer vectornum;
	reg [(2*N+W)-1:0] testvectors[N-1:0];

	bsr_parl #(.N(N)) uut
		(.iA(a_i), .iAmt(amt_i), .oY(y_o));

	// test vector generator
	initial
	begin
		$readmemb("../test/tv/bsr_parl_tb.tv", testvectors);

		for (vectornum = 0; vectornum < N; vectornum = vectornum + 1)
		begin
			{a_i, amt_i, y_e} = testvectors[vectornum];
			#100;
		
			`ASSERT((y_o == y_e), 
				("test vector #%0d: input = {%b, %0d}, output = %b, expected = %b",
				vectornum, a_i, amt_i, y_o, y_e));
		end
		
		$display("Test finished succesfully");
		$finish;
	end
endmodule
