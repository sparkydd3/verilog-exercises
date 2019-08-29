module reg_file
	#(
		parameter DATA_WIDTH = 8,	// number of bits in a word
		          ADDR_WIDTH = 4
	)
	(
		input wire iCLK,
		input wire iWE,
		input wire [ADDR_WIDTH-1:0] iWADDR, iRADDR,
		input wire [DATA_WIDTH-1:0] iWDATA,
		output wire [DATA_WIDTH-1:0] oRDATA
	);

	// signal declaration
	reg [DATA_WIDTH-1:0] array_reg [2**ADDR_WIDTH-1:0];

	// body
	// write operation
	always @(posedge iCLK)
		if (iWE)
			array_reg[iWADDR] <= iWDATA;
	// read operation
	assign oRDATA =  array_reg[iRADDR];
endmodule
