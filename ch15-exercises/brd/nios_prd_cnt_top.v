module nios_prd_cnt_top
	(
		input wire CLOCK_50,
		input wire [0:0] KEY,
		output wire [6:0] HEX3, HEX2, HEX1, HEX0,
		output wire [17:0] SRAM_ADDR,
		inout [15:0] SRAM_DQ,
		output SRAM_CE_N, SRAM_OE_N, SRAM_WE_N,
		output SRAM_LB_N, SRAM_UB_N
	);
	
	// signal declaration
	wire [15:0] bcd; 
	wire sq_wave;

	// body
	// instantiate nios
	nios_prd_cnt nios_cpu_unit
		(.clk_clk(CLOCK_50),
		 .reset_reset_n(KEY[0]),
		 .sram_sram_addr_addr(SRAM_ADDR),
		 .sram_sram_addr_ce_n(SRAM_CE_N),
		 .sram_sram_addr_dq(SRAM_DQ),
		 .sram_sram_addr_lb_n(SRAM_LB_N),
		 .sram_sram_addr_oe_n(SRAM_OE_N),
		 .sram_sram_addr_ub_n(SRAM_UB_N),
		 .sram_sram_addr_we_n(SRAM_WE_N),
		 .sq_gen_sq_export(sq_wave),
		 .prd_cnt_sig_export(sq_wave),
		 .div_div_ledg_export(),
		 .bin2bcd_bcd_export(bcd)
		);

	bin2sseg bin2sseg_u3
		(.iBIN(bcd[15:12]), .oSSEG(HEX3));
	bin2sseg bin2sseg_u2
		(.iBIN(bcd[11:8]), .oSSEG(HEX2));
	bin2sseg bin2sseg_u1
		(.iBIN(bcd[7:4]), .oSSEG(HEX1));
	bin2sseg bin2sseg_u0
		(.iBIN(bcd[3:0]), .oSSEG(HEX0));
endmodule
