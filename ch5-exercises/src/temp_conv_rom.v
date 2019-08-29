module temp_rom_conv
	(
		input wire iCLK,
		input wire iFMT,
		input wire [7:0] iD,
		output wire [7:0] oD
	);
	
	reg [7:0] rom [0:2**9-1];
	reg [7:0] data_reg;

	initial
		$readmemb("temp_conv.txt", rom);

	always @(posedge iCLK)
		data_reg <= rom[{iFMT, iD}];

	assign oD = data_reg;
endmodule
