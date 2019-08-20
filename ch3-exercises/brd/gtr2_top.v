module gtr2_top
	(
		input wire [3:0] SW,
		output wire [0:0] LEDR
	);

	gtr2 gtr_unit
		(.iA(SW[3:2]), .iB(SW[1:0]), .oGtr(LEDR[0]));
endmodule
