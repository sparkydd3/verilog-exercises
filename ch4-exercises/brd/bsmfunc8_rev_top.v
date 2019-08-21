module bsmfunc8_rev_top
	(
		input wire [7:0] GPIO_0,
		input wire [2:0] SW,
		input wire [0:0] KEY,
		output wire [7:0] GPIO_1
	);

	// 42 logic elements used
	// 15.11 ns worst case propagation delay
	bsmfunc_rev #(.N(8)) bsmfunc
		(.iA(GPIO_0), .iAmt(SW), .iLR(~KEY), .oY(GPIO_1));

endmodule
