module bin_to_sseg_test
	(
		input wire [7:0] SW,
		output wire [6:0] HEX3, HEX2, HEX1, HEX0
	);

	// signal declaration
	wire [7:0] inc;

	// body
	// increment input
	assign inc = SW + 1;

	// instantiate four instances of 7-seg LED decoders
	bin_to_sseg disp_unit_0
		(.bin(SW[3:0]), .sseg(HEX0));
	bin_to_sseg disp_unit_1
		(.bin(SW[7:4]), .sseg(HEX1));
	bin_to_sseg disp_unit_2
		(.bin(inc[3:0]), .sseg(HEX2));
	bin_to_sseg disp_unit_3
		(.bin(inc[7:4]), .sseg(HEX3));
endmodule
