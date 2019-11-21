module fifo_async
	#(
		parameter DATA_WIDTH = 16,
		          ADDR_WIDTH = 9
	)
	(
		output wire [DATA_WIDTH-1:0] o_rd_data,
		output wire o_rd_empty,
		input wire i_read,
		input wire i_rd_clk,
		input wire i_rd_reset,

		output wire o_wr_full,
		input wire [DATA_WIDTH-1:0] i_wr_data,
		input wire i_write,
		input wire i_wr_clk,
		input wire i_wr_reset
	);

	reg [DATA_WIDTH-1:0] fifo_mem [0:2**ADDR_WIDTH - 1];

	reg [ADDR_WIDTH:0] r_addr_reg;
	reg [DATA_WIDTH-1:0] r_data_reg;
	always @(posedge i_rd_clk, posedge i_rd_reset)
		if (i_rd_reset)
			begin
				r_addr_reg <= 0;
				r_data_reg <= 0;
			end
		else 
			begin
				r_data_reg <= fifo_mem[r_addr_reg];

				if (i_read && ~o_rd_empty)
					r_addr_reg <= r_addr_reg + 1;
			end

	assign o_rd_data = r_data_reg;

	reg [ADDR_WIDTH:0] w_addr_reg;
	always @(posedge i_wr_clk, posedge i_wr_reset)
		if (i_wr_reset)
			w_addr_reg <= 0;
		else if (i_write & ~o_wr_full)
			begin
				fifo_mem[w_addr_reg] <= i_wr_data;
				w_addr_reg <= w_addr_reg + 1;
			end
	
	// clock domain crossing synchronization

	// use gray code to only change one bit at a time at crossing
	wire [ADDR_WIDTH:0] r_addr_gray, w_addr_gray;
	assign r_addr_gray = r_addr_reg ^ (r_addr_reg >> 1);
	assign w_addr_gray = w_addr_reg ^ (w_addr_reg >> 1);

	reg [ADDR_WIDTH:0] rq2_wgray, rq1_wgray;
	reg [ADDR_WIDTH:0] wq2_rgray, wq1_rgray;
	
	// 2 FF synchronizers
	always @(posedge i_rd_clk, posedge i_rd_reset)
		if (i_rd_reset)
			{rq2_wgray, rq1_wgray} <= 0;
		else
			{rq2_wgray, rq1_wgray} <= {rq1_wgray, w_addr_gray};

	always @(posedge i_wr_clk, posedge i_wr_reset)
		if (i_wr_reset)
			{wq2_rgray, wq1_rgray} <= 0;
		else
			{wq2_rgray, wq1_rgray} <= {wq1_rgray, r_addr_gray};
	
	// pointer width is ADDR_WIDTH + 1. When full, the write pointer's MSB 
	// is flipped and the top 2 bits in gray code will be flipped from the 
	// read pointer
	assign o_wr_full = 
		(w_addr_gray[ADDR_WIDTH:ADDR_WIDTH-1] == ~wq2_rgray[ADDR_WIDTH:ADDR_WIDTH-1])
		&& (w_addr_gray[ADDR_WIDTH-2:0] == wq2_rgray[ADDR_WIDTH-2:0]);

	assign o_rd_empty = (r_addr_gray == rq2_wgray);
endmodule
