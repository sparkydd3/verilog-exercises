module nios_led1_top
	(
		input wire CLOCK_50,
		input wire [9:0] SW,
		output wire [1:0] LEDG
	);

	// body
	// instantiate nios
	nios_led1 cpu_unit
		(.clk_clk(CLOCK_50),
		 .switch_external_connection_export(SW),
		 .led_external_connection_export(LEDG)
		);
endmodule
