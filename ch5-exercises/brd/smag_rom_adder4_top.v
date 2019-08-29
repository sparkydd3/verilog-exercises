// 1024 memory bits used

module smag_rom_adder4_top
	(
		input wire CLOCK_50,
		input wire [7:0] GPIO_0,
		output wire [3:0] GPIO_1
	);

	smag_rom_adder4 adder
		(.iCLK(CLOCK_50), 
		 .iA(GPIO_0[7:4]), .iB(GPIO_0[3:0]),
		 .oSUM(GPIO_1[3:0]));
endmodule
