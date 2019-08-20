module dec4to16
	(
		input  wire [3:0] iEnc,
		output wire [15:0] oDec
	);

	wire [3:0] dec_bot, dec_top;

	dec2to4 dec_b
		(.iEnc(iEnc[1:0]), .oDec(dec_bot));

	dec2to4 dec_t
		(.iEnc(iEnc[3:2]), .oDec(dec_top));

	assign oDec[3:0]   = {4{dec_top[0]}} & dec_bot;
	assign oDec[7:4]   = {4{dec_top[1]}} & dec_bot;
	assign oDec[11:8]  = {4{dec_top[2]}} & dec_bot;
	assign oDec[15:12] = {4{dec_top[3]}} & dec_bot;

endmodule
