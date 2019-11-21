module nios_top
	(
		input wire [9:0] SW,
		input wire [3:0] KEY,
		output wire [7:0] LEDG,
		output wire [9:0] LEDR,
		output wire [6:0] HEX3, HEX2, HEX1, HEX0,

		output wire [17:0] SRAM_ADDR,
		output wire SRAM_UB_N, SRAM_LB_N, 
		output wire SRAM_CE_N, 
		output wire SRAM_OE_N, 
		output wire SRAM_WE_N,
		inout wire [15:0] SRAM_DQ,

		output wire [11:0] DRAM_ADDR,
		output wire DRAM_BA_1, DRAM_BA_0,
		output wire DRAM_UDQM, DRAM_LDQM,
		output wire DRAM_CS_N,
		output wire DRAM_RAS_N, DRAM_CAS_N, 
		output wire DRAM_WE_N, 
		output wire DRAM_CLK, DRAM_CKE, 
		inout wire [15:0] DRAM_DQ,

		output wire [3:0] VGA_R, VGA_G, VGA_B,
		output wire VGA_HS, VGA_VS,

		inout PS2_CLK, PS2_DAT,

		input wire CLOCK_50
	);

	wire [18:0] led;
	wire [31:0] sseg;

	nios cpu (
        .switch_external_connection_export(SW),
        .btn_external_connection_export({KEY[3:1], 1'b1}),
        .led_external_connection_export(led),
        .sseg_external_connection_export(sseg),

        .ps2_ps2_phys_ps2d(PS2_DAT),
        .ps2_ps2_phys_ps2c(PS2_CLK),

		.sdram_wire_addr(DRAM_ADDR),
		.sdram_wire_ba({DRAM_BA_1, DRAM_BA_0}),
		.sdram_wire_dqm({DRAM_UDQM, DRAM_LDQM}),
		.sdram_wire_cs_n(DRAM_CS_N),
		.sdram_wire_ras_n(DRAM_RAS_N),
		.sdram_wire_cas_n(DRAM_CAS_N),
		.sdram_wire_we_n(DRAM_WE_N),
		.sdram_clk_clk(DRAM_CLK),
		.sdram_wire_cke(DRAM_CKE),
		.sdram_wire_dq(DRAM_DQ),

		.vram_ctrl_sram_o_sram_addr(SRAM_ADDR),
		.vram_ctrl_sram_o_sram_ub_n(SRAM_UB_N),
		.vram_ctrl_sram_o_sram_lb_n(SRAM_LB_N),
		.vram_ctrl_sram_o_sram_ce_n(SRAM_CE_N),
		.vram_ctrl_sram_o_sram_oe_n(SRAM_OE_N),
		.vram_ctrl_sram_o_sram_we_n(SRAM_WE_N),
		.vram_ctrl_sram_io_sram_dq(SRAM_DQ),
		
		.vram_ctrl_vga_rgb({VGA_R, VGA_G, VGA_B}),
		.vram_ctrl_vga_hsync(VGA_HS),
		.vram_ctrl_vga_vsync(VGA_VS),

        .clk_clk(CLOCK_50),
        .reset_reset_n(KEY[0])
    );

	assign HEX3 = sseg[30:24];
	assign HEX2 = sseg[22:16];
	assign HEX1 = sseg[14:8];
	assign HEX0 = sseg[6:0];

	assign LEDR = led[17:8];
	assign LEDG = led[7:0];
endmodule
