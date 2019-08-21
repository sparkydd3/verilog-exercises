module bsmfunc16_rev_top
	(
		input wire [15:0] GPIO_0,
		input wire [3:0] SW,
		input wire [0:0] KEY,
		output wire [15:0] GPIO_1
	);

	// 130 logic elements used
	// 18.01 ns worst case propagation delay
	bsmfunc_rev #(.N(16)) bsmfunc
		(.iA(GPIO_0), .iAmt(SW), .iLR(~KEY), .oY(GPIO_1));

endmodule
