`include "assert.vh"
`timescale 1 ns / 1 ps

module dprioenc_tb;
	reg [11:0] req_i;
	reg [3:0] first_e, second_e;
	wire [3:0] first_o, second_o; 

	localparam N = 299;
	integer vectornum;
	reg [19:0] testvectors[N-1:0];

	dprioenc uut
		(.iReq(req_i), .oFirst(first_o), .oSecond(second_o));

	// test vector generator
	initial
	begin
		$readmemh("../test/tv/dprioenc_tb.tv", testvectors);

		for (vectornum = 0; vectornum < N; vectornum = vectornum + 1)
		begin
			{req_i, first_e, second_e} = testvectors[vectornum];
			#100;
		
			`ASSERT((first_o == first_e && second_o == second_e), 
				("test vector #%0d: input = %b, output = {%0d, %0d}, expected = {%0d, %0d}",
				vectornum, req_i, first_o, second_o, first_e, second_e));
		end
		
		$display("Test finished succesfully");
		$finish;
	end
endmodule
