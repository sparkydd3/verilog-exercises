module bsr32_stg_top
	(
		input wire [31:0] GPIO_0,
		input wire [4:0] SW,
		output wire [31:0] GPIO_1
	);

	// 228 logic elements used
	// 17.10 ns worst case propagation delay
	bsr_stg #(.N(32)) bsr
		(.iA(GPIO_0), .iAmt(SW), .oY(GPIO_1));

endmodule
