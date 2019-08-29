module altera_dual_port_ram_simple
	#(
		parameter DATA_WIDTH = 8,	// number of bits in a word
		          ADDR_WIDTH = 10	// number of address bits
	)
	(
		input wire iCLK,
		input wire iWE,
		input wire [ADDR_WIDTH-1:0] iWADDR, iRADDR,
		input wire [DATA_WIDTH-1:0] iD,
		output wire [DATA_WIDTH-1:0] oQ
	);

	// signal declaration
	reg [DATA_WIDTH-1:0] ram [2**ADDR_WIDTH-1:0];
	reg [ADDR_WIDTH-1:0] addr_reg;

	// body
	// write operation
	always @(posedge iCLK)
	begin
		if (iWE)
			ram[iWADDR] <= iD;
		addr_reg <= iRADDR;
	end

	// read operation
	assign oQ = ram[addr_reg];
endmodule
