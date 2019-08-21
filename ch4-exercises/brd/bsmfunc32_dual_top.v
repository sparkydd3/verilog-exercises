module bsmfunc32_dual_top
	(
		input wire [31:0] GPIO_0,
		input wire [4:0] SW,
		input wire [0:0] KEY,
		output wire [31:0] GPIO_1
	);

	// 296 logic elements used
	// 18.45 ns worst case propagation delay
	bsmfunc_dual #(.N(32)) bsmfunc
		(.iA(GPIO_0), .iAmt(SW), .iLR(~KEY), .oY(GPIO_1));

endmodule
