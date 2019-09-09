module nios_led2_top
	(
		input wire CLOCK_50,
		input wire [9:0] SW,
		input wire [4:0] KEY,
		output wire [7:0] LEDG,
		output wire [9:0] LEDR,
		output wire [6:0] HEX3, HEX2, HEX1, HEX0,
		output wire [17:0] SRAM_ADDR,
		inout [15:0] SRAM_DQ,
		output SRAM_CE_N, SRAM_OE_N, SRAM_WE_N,
		output SRAM_LB_N, SRAM_UB_N
	);
	
	// signal declaration
	wire [31:0] sseg;

	// body
	// instantiate nios
	nios_led2 nios_cpu_unit
		(.clk_clk(CLOCK_50),
		 .reset_reset_n(1'b1),
		 .switch_external_connection_export(SW),
		 .btn_external_connection_export(KEY),
		 .ledg_external_connection_export(LEDG),
		 .ledr_external_connection_export(LEDR),
		 .sseg_external_connection_export(sseg),
		 .sram_sram_addr_addr(SRAM_ADDR),
		 .sram_sram_addr_ce_n(SRAM_CE_N),
		 .sram_sram_addr_dq(SRAM_DQ),
		 .sram_sram_addr_lb_n(SRAM_LB_N),
		 .sram_sram_addr_oe_n(SRAM_OE_N),
		 .sram_sram_addr_ub_n(SRAM_UB_N),
		 .sram_sram_addr_we_n(SRAM_WE_N)
		);

	// output assignment
	assign HEX3 = sseg[30:24];
	assign HEX2 = sseg[22:16];
	assign HEX1 = sseg[14:8];
	assign HEX0 = sseg[6:0];
endmodule
