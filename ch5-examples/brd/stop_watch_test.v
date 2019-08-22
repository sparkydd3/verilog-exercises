module stop_watch_test
	(
		input wire CLOCK_50,
		input wire [1:0] KEY,
		output wire [7:0] HEX3, HEX2, HEX1, HEX0
	);
	
	// signal declaration
	wire [3:0] d2, d1, d0;
	wire go, clr;

	// body
	assign go = ~KEY[1];
	assign clr = ~KEY[0];

	// instantiate stopwatch
	stop_watch_if counter_unit
		(.clk(CLOCK_50), .go(go), .clr(clr),
		 .d2(d2), .d1(d1), .d0(d0));
	
	// instantiate four instances of 7-seg LED decoders
	bin_to_sseg disp_unit_0
		(.bin(d0), .sseg(HEX0));
	bin_to_sseg disp_unit_1
		(.bin(d1), .sseg(HEX1));
	bin_to_sseg disp_unit_2
		(.bin(d2), .sseg(HEX2));
	bin_to_sseg disp_unit_3
		(.bin(4'b0), .sseg(HEX3));
endmodule
