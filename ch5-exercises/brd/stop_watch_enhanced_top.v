module stop_watch_enhanced_top
	(
		input wire CLOCK_50,
		input wire [1:0] SW,
		input wire [0:0] KEY,
		output wire [6:0] HEX3, HEX2, HEX1, HEX0
	);
	
	// signal declaration
	wire [3:0] d3, d2, d1, d0;
	wire clk, go, clr, up;

	// body
	assign clk = CLOCK_50;
	assign up = SW[1];
	assign go = SW[0];
	assign clr = ~KEY[0];

	// instantiate stopwatch
	stop_watch_enhanced stop_watch
		(.iCLK(CLOCK_50), .iGO(go), .iCLR(clr), .iUP(up),
		 .oD3(d3), .oD2(d2), .oD1(d1), .oD0(d0));
	
	// instantiate four instances of 7-seg LED decoders
	bin2sseg_rom disp_unit_0
		(.iCLK(clk), .iBIN(d0), .oSSEG(HEX0));
	bin2sseg_rom disp_unit_1
		(.iCLK(clk), .iBIN(d1), .oSSEG(HEX1));
	bin2sseg_rom disp_unit_2
		(.iCLK(clk), .iBIN(d2), .oSSEG(HEX2));
	bin2sseg_rom disp_unit_3
		(.iCLK(clk), .iBIN(d3), .oSSEG(HEX3));
endmodule
