// 31 logic elements used

module smag_adder8_top
	(
		input wire [15:0] GPIO_0,
		output wire [7:0] GPIO_1
	);

	smag_adder #(.N(8)) adder
		(.iA(GPIO_0[15:8]), .iB(GPIO_0[7:0]),
		 .oSUM(GPIO_1[7:0]));
endmodule
