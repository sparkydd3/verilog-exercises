module rot_sq_top
	(
		input wire CLOCK_50,
		input wire [9:0] SW,
		input wire [0:0] KEY,
		output wire [6:0] HEX3, HEX2, HEX1, HEX0
	);
	
	rot_sq cpu (
		.clk_clk(CLOCK_50),
		.reset_reset_n(KEY[0]),
		.switch_external_connection_export(SW),
		.hex3_external_connection_export(HEX3),
		.hex2_external_connection_export(HEX2),
		.hex1_external_connection_export(HEX1),
		.hex0_external_connection_export(HEX0),
	);
endmodule
