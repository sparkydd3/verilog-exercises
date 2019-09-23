module avalon_prd_cnt
	(
		input wire clk, reset,
		input wire [31:0] write_data,
		input wire write,
		output wire [31:0] read_data,
		input wire sig,
		output wire irq
	);

	wire prd_start, prd_ready, prd_done_tick, prd_done_clr;
	reg prd_done_reg;
	wire [19:0] prd_out;

	prd_cnt prd_cnt_unit
		(.iCLK(clk), .iRESET(reset),
		 .iSTART(prd_start), .iSIG(sig),
		 .oREADY(prd_ready), .oDONE(prd_done_tick),
		 .oPRD(prd_out));

	always @(posedge clk, posedge reset)
		if (reset)
			prd_done_reg <= 0;
		else
			if (prd_done_tick)
				prd_done_reg <= 1;
			else if (prd_done_clr)
				prd_done_reg <= 0;

	assign prd_done_clr = (write & write_data[31]);
	assign prd_start = (write & write_data[30]);

	assign irq = prd_done_reg;
	assign read_data = {prd_done_reg, prd_ready, 10'bx, prd_out};
endmodule
