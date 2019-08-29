// 15 logic elements used

module smag_adder4_top
	(
		input wire [7:0] GPIO_0,
		output wire [3:0] GPIO_1
	);

	smag_adder #(.N(4)) adder
		(.iA(GPIO_0[7:4]), .iB(GPIO_0[3:0]),
		 .oSUM(GPIO_1[3:0]));
endmodule
