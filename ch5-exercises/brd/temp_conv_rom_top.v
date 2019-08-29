module temp_rom_conv_top
	(
		input wire CLOCK_50,
		input wire [8:0] SW,
		output wire [7:0] LEDR
	);

	temp_rom_conv uut
		(.iCLK(CLOCK_50),
		 .iD(SW[7:0]), .iFMT(SW[8]),
		 .oD(LEDR[7:0]));

endmodule
