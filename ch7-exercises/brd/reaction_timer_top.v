module reaction_timer_top
	(
		input wire CLOCK_50,
		input wire [3:0] KEY,
		input wire [9:0] SW,
		output wire [0:0] LEDR,
		output wire [6:0] HEX3, HEX2, HEX1, HEX0
	);

	wire clk, start, stop, clear, reset;	
	wire [15:0] rand_seed;

	assign clk = CLOCK_50;
	assign start = ~KEY[3];
	assign stop = ~KEY[2];
	assign clear = ~KEY[1];
	assign reset = ~KEY[0];
	assign rand_seed = {6'b100001, SW};

	reaction_timer uut
		(.iCLK(clk), .iRESET(reset),
		 .iSTART(start), .iSTOP(stop), .iCLEAR(clear),
		 .iSEED(rand_seed),
		 .oLED(LEDR[0]),
		 .oSSEG3(HEX3), .oSSEG2(HEX2), .oSSEG1(HEX1), .oSSEG0(HEX0));
endmodule
