module reg_file
	#(
		parameter DATA_WIDTH = 8,	// number of bits in a word
		          ADDR_WIDTH = 4
	)
	(
		output wire [DATA_WIDTH-1:0] o_r_data,

		input wire [ADDR_WIDTH-1:0] i_r_addr,
		input wire [ADDR_WIDTH-1:0] i_w_addr, 
		input wire [DATA_WIDTH-1:0] i_w_data,
		input wire i_wr_en,

		input wire i_clk
	);

	// signal declaration
	reg [DATA_WIDTH-1:0] array_reg [2**ADDR_WIDTH-1:0];

	// body
	// write operation
	always @(posedge i_clk)
		if (i_wr_en)
			array_reg[i_w_addr] <= i_w_data;

	// read operation
	assign o_r_data =  array_reg[i_r_addr];
endmodule
