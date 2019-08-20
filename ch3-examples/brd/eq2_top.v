module eq2_top
	(
		input wire [3:0] SW,
		output wire [0:0] LEDR
	);

	// body
	// instantiate 2-bit comparator
	eq2 eq_unit
		(.a(SW[3:2]), .b(SW[1:0]), .aeqb(LEDR[0]));
endmodule
