module heartbeat_top
	(
		input wire CLOCK_50,
		input wire [0:0] KEY,
		output wire [6:0] HEX3, HEX2, HEX1, HEX0
	);
	
	heartbeat cpu (
		.clk_clk(CLOCK_50),
		.reset_reset_n(KEY[0]),
		.hex3_external_connection_export(HEX3),
		.hex2_external_connection_export(HEX2),
		.hex1_external_connection_export(HEX1),
		.hex0_external_connection_export(HEX0),
	);
endmodule
