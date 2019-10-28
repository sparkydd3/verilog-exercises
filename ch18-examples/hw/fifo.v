module fifo
	#(
		parameter DATA_WIDTH = 8,	// number of bits in a word
		          ADDR_WIDTH = 4	// number of address bits
	)
	(
		output wire [DATA_WIDTH-1:0] o_r_data,
		output wire o_empty, 
		output wire o_full,

		input wire [DATA_WIDTH-1:0] i_w_data,
		input wire i_rd,
		input wire i_wr,

		input wire i_clk,
		input wire i_reset
	);

	// signal declaration
	wire [ADDR_WIDTH-1:0] w_addr, r_addr;
	wire wr_en;

	// body
	// write enabled only when FIFO is not o_full
	assign wr_en = i_wr & ~o_full;

	// instantiate fifo control circuit
	fifo_ctrl #(.ADDR_WIDTH(ADDR_WIDTH)) fifo_ctrl
		(.o_r_addr(r_addr),
		 .o_r_addr_next(),
		 .o_w_addr(w_addr),
		 .o_empty(o_empty),
		 .o_full(o_full),

		 .i_rd(i_rd),
		 .i_wr(wr_en),

		 .i_clk(i_clk),
		 .i_reset(i_reset)
		);
		
	// instantiate register file
	reg_file #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) reg_file
		(.o_r_data(o_r_data),
		 .i_w_data(i_w_data),
		 .i_w_addr(w_addr),
		 .i_r_addr(r_addr),
		 .i_wr_en(wr_en),

		 .i_clk(i_clk)
		);
endmodule
