module gtr4_top
	(
		input wire [7:0] SW,
		output wire [0:0] LEDR
	);

	gtr4 gtr_unit
		(.iA(SW[7:4]), .iB(SW[3:0]), .oGtr(LEDR[0]));
endmodule
