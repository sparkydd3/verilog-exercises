module bsl32_parl_top
	(
		input wire [31:0] GPIO_0,
		input wire [4:0] SW,
		output wire [31:0] GPIO_1
	);

	// 228 logic elements used
	// 17.32 ns worst case propagation delay
	bsl_parl #(.N(32)) bsl
		(.iA(GPIO_0), .iAmt(SW), .oY(GPIO_1));

endmodule
