module pwm_top
	(
		input wire CLOCK_50,
		input wire [9:0] SW,
		input wire [3:0] KEY,
		output wire [7:0] LEDG
	);
	
	pwm cpu (
		.clk_clk(CLOCK_50),
		.reset_reset_n(KEY[0]),
		.switch_external_connection_export(SW),
		.ledg_external_connection_export(LEDG)
	);
endmodule
