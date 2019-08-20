module dec2to4_top
	(
		input wire [1:0] SW,
		output wire [3:0] LEDR
	);

	dec2to4 dec_unit
		(.iEnc(SW[1:0]), .oDec(LEDR[3:0]));
endmodule
