module nios_top
	(
		input wire CLOCK_50,
		input wire [9:0] SW,
		input wire [3:0] KEY,
		output wire [7:0] LEDG,
		output wire [9:0] LEDR,
		output wire [6:0] HEX3, HEX2, HEX1, HEX0,

		output wire [17:0] SRAM_ADDR,
		output wire SRAM_CE_N, SRAM_OE_N, SRAM_WE_N,
		output wire SRAM_LB_N, SRAM_UB_N,
		inout wire [15:0] SRAM_DQ,

		inout PS2_CLK, PS2_DAT
	);

	wire [18:0] led;
	wire [31:0] sseg;

	nios cpu (
        .clk_clk(CLOCK_50),
        .reset_reset_n(1'b1),
        .switch_external_connection_export(SW),
        .btn_external_connection_export(KEY),
        .led_external_connection_export(led),
        .sseg_external_connection_export(sseg),
        .ps2_ps2_phys_ps2d(PS2_DAT),
        .ps2_ps2_phys_ps2c(PS2_CLK),
		.sram_sram_ctrl_addr(SRAM_ADDR),
		.sram_sram_ctrl_dq(SRAM_DQ),
		.sram_sram_ctrl_ce_n(SRAM_CE_N),
		.sram_sram_ctrl_oe_n(SRAM_OE_N),
		.sram_sram_ctrl_we_n(SRAM_WE_N),
		.sram_sram_ctrl_lb_n(SRAM_LB_N),
		.sram_sram_ctrl_ub_n(SRAM_UB_N)
    );

	assign HEX3 = sseg[30:24];
	assign HEX2 = sseg[22:16];
	assign HEX1 = sseg[14:8];
	assign HEX0 = sseg[6:0];

	assign LEDR = led[17:8];
	assign LEDG = led[7:0];
endmodule
