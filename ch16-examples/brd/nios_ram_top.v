module nios_ram_top
	(
		input wire CLOCK_50,
		// to/from SRAM
		output wire [17:0] SRAM_ADDR,
		output wire SRAM_CE_N, SRAM_OE_N, SRAM_WE_N,
		output wire SRAM_LB_N, SRAM_UB_N,
		inout wire [15:0] SRAM_DQ,
		// to/from SDRAM 
		output wire DRAM_CLK,
		output wire DRAM_CS_N, DRAM_CKE, DRAM_LDQM, DRAM_UDQM,
		output wire DRAM_CAS_N, DRAM_RAS_N, DRAM_WE_N,
		output wire [11:0] DRAM_ADDR,
		output wire DRAM_BA_0, DRAM_BA_1,
		inout wire [15:0] DRAM_DQ
	);

	// body
	// instantiate nios
	nios_ram cpu_unit (
		.clk_clk(CLOCK_50),
		.sdram_clk_clk(DRAM_CLK),
		.reset_reset_n(1'b1),
		// SRAM
		.sram_ctrl_sram_addr(SRAM_ADDR),
		.sram_ctrl_sram_dq(SRAM_DQ),
		.sram_ctrl_sram_ce_n(SRAM_CE_N),
		.sram_ctrl_sram_oe_n(SRAM_OE_N),
		.sram_ctrl_sram_we_n(SRAM_WE_N),
		.sram_ctrl_sram_lb_n(SRAM_LB_N),
		.sram_ctrl_sram_ub_n(SRAM_UB_N),
		// SDRAM
		.sdram_wire_addr(DRAM_ADDR),
		.sdram_wire_ba({DRAM_BA_1, DRAM_BA_0}),
		.sdram_wire_cas_n(DRAM_CAS_N),
		.sdram_wire_cke(DRAM_CKE),
		.sdram_wire_cs_n(DRAM_CS_N),
		.sdram_wire_dq(DRAM_DQ),
		.sdram_wire_dqm({DRAM_UDQM, DRAM_LDQM}),
		.sdram_wire_ras_n(DRAM_RAS_N),
		.sdram_wire_we_n(DRAM_WE_N)
	);
endmodule
