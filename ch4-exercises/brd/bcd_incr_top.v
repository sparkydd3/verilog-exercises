module bcd_incr_top
	(
		input wire [9:0] SW,
		output wire [6:0] HEX3, HEX2, HEX1, HEX0,
		output wire [1:0] LEDR
	);

	wire [11:0] bcd_incr;

	bcd_incr uut
		(.iBCD({2'b0, SW}), .oIncr(bcd_incr),
		 .oInvalid(LEDR[1]), .oOverflow(LEDR[0]));
	
	bin2sseg hundreds
		(.iBin(bcd_incr[11:8]), .oSseg(HEX2));
	bin2sseg tens
		(.iBin(bcd_incr[7:4]), .oSseg(HEX1));
	bin2sseg ones
		(.iBin(bcd_incr[3:0]), .oSseg(HEX0));
	
	assign HEX3 = 7'd0;
endmodule
