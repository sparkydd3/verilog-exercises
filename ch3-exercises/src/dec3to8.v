module dec3to8
	(
		input  wire [2:0] iEnc,
		output wire [7:0] oDec
	);

	wire [3:0] dec_1_0;

	dec2to4 dec
		(.iEnc(iEnc[1:0]), .oDec(dec_1_0));

	assign oDec[3:0] = ~{4{iEnc[2]}} & dec_1_0;
	assign oDec[7:4] =  {4{iEnc[2]}} & dec_1_0;

endmodule
