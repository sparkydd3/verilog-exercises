module bsmfunc16_dual_top
	(
		input wire [15:0] GPIO_0,
		input wire [3:0] SW,
		input wire [0:0] KEY,
		output wire [15:0] GPIO_1
	);

	// 116 logic elements used
	// 16.34 worst case propagation delay
	bsmfunc_dual #(.N(16)) bsmfunc
		(.iA(GPIO_0), .iAmt(SW), .iLR(~KEY), .oY(GPIO_1));

endmodule
