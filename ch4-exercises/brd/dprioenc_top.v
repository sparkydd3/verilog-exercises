module dprioenc_top
	(
		input wire [9:0] SW,
		output wire [6:0] HEX3, HEX2, HEX1, HEX0
	);

	wire [4:0] first, second;

	dprioenc uut
		(.iReq(SW), .oFirst(first), .oSecond(second));

	bin2sseg sseg_first
		(.iBin(first), .oSseg(HEX1));

	bin2sseg sseg_second
		(.iBin(second), .oSseg(HEX0));

	assign HEX3 = 7'd0;
	assign HEX2 = 7'd0;
endmodule
