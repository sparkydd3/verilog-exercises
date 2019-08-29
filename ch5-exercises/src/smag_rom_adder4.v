module smag_rom_adder4
	(
		input wire iCLK,
		input wire [3:0] iA, iB,
		output wire [3:0] oSUM
	);

	reg [3:0] rom [0:2**8-1];
	reg [3:0] data_reg;

	initial
		$readmemb("smag_rom_adder4.txt", rom);

	always @(posedge iCLK)
		data_reg <= rom[{iA, iB}];

	assign oSUM = data_reg;
endmodule
