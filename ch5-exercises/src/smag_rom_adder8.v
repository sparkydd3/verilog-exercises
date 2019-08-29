module smag_rom_adder8
	(
		input wire iCLK,
		input wire [7:0] iA, iB,
		output wire [7:0] oSUM
	);

	reg [7:0] rom [0:2**16-1];
	reg [7:0] data_reg;

	initial
		$readmemb("smag_rom_adder8.txt", rom);

	always @(posedge iCLK)
		data_reg <= rom[{iA, iB}];

	assign oSUM = data_reg;
endmodule
