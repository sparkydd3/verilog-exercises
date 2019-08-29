// 524288 memory bits used

module smag_rom_adder8_top
	(
		input wire CLOCK_50,
		input wire [15:0] GPIO_0,
		output wire [7:0] GPIO_1
	);

	smag_rom_adder8 adder
		(.iCLK(CLOCK_50), 
		 .iA(GPIO_0[15:8]), .iB(GPIO_0[7:0]),
		 .oSUM(GPIO_1[7:0]));
endmodule
