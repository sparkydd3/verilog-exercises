module shifter_case_test
	(
		input wire [2:0] KEY,
		input wire [7:0] SW,
		output wire [7:0] LEDR
	);
	
	// instantiate shifter
	barrel_shifter_case shift_unit
		(.a(SW), .amt(~KEY), .y(LEDR));
endmodule
