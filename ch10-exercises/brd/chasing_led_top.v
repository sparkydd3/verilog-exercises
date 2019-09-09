module chasing_led_top
	(
		input wire CLOCK_50,
		input wire [9:0] SW,
		input wire [3:0] KEY,
		output wire [9:0] LEDR,
		output wire [7:0] LEDG
	);
	
	chasing_led cpu (
		.clk_clk(CLOCK_50),
		.switch_external_connection_export(SW),
		.key_external_connection_export(~KEY),
		.ledr_external_connection_export(LEDR),
		.ledg_external_connection_export(LEDG)
	);
endmodule
