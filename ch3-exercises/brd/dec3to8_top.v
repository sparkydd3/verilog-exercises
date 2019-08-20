module dec3to8_top
	(
		input wire [2:0] SW,
		output wire [7:0] LEDR
	);

	dec3to8 dec_unit
		(.iEnc(SW[2:0]), .oDec(LEDR[7:0]));
endmodule
