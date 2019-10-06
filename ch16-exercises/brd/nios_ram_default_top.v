module nios_ram_default_top
	(
		input wire CLOCK_50,
		input wire [0:0] KEY,

		// to/from SRAM
		// test time: 191 ms
		output wire [17:0] SRAM_ADDR,
		output wire SRAM_CE_N, SRAM_OE_N, SRAM_WE_N,
		output wire SRAM_LB_N, SRAM_UB_N,
		inout wire [15:0] SRAM_DQ,

		// to/from SDRAM 
		// test time: 3312 ms
		output wire DRAM_CLK,
		output wire DRAM_CS_N, DRAM_CKE, DRAM_LDQM, DRAM_UDQM,
		output wire DRAM_CAS_N, DRAM_RAS_N, DRAM_WE_N,
		output wire [11:0] DRAM_ADDR,
		output wire DRAM_BA_0, DRAM_BA_1,
		inout wire [15:0] DRAM_DQ
	);
	
	// body
	// instantiate nios
	nios_ram_default cpu_unit (
		.clk_clk(CLOCK_50),
		.sdram_clk_clk(DRAM_CLK),
		.reset_reset_n(KEY[0]),

		// SRAM
		.sram_ctrl_sram_ADDR(SRAM_ADDR),
		.sram_ctrl_sram_DQ(SRAM_DQ),
		.sram_ctrl_sram_CE_N(SRAM_CE_N),
		.sram_ctrl_sram_OE_N(SRAM_OE_N),
		.sram_ctrl_sram_WE_N(SRAM_WE_N),
		.sram_ctrl_sram_LB_N(SRAM_LB_N),
		.sram_ctrl_sram_UB_N(SRAM_UB_N),

		// SDRAM
		.sdram_ctrl_sdram_addr(DRAM_ADDR),
		.sdram_ctrl_sdram_ba({DRAM_BA_1, DRAM_BA_0}),
		.sdram_ctrl_sdram_cas_n(DRAM_CAS_N),
		.sdram_ctrl_sdram_cke(DRAM_CKE),
		.sdram_ctrl_sdram_cs_n(DRAM_CS_N),
		.sdram_ctrl_sdram_dq(DRAM_DQ),
		.sdram_ctrl_sdram_dqm({DRAM_UDQM, DRAM_LDQM}),
		.sdram_ctrl_sdram_ras_n(DRAM_RAS_N),
		.sdram_ctrl_sdram_we_n(DRAM_WE_N)
	);
endmodule
