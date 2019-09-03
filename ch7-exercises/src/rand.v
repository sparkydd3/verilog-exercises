module rand
	(
		input wire iCLK, iRESET,
		input wire iEN, iLOAD,
		input wire [15:0] iSEED,
		output wire [15:0] oRAND
	);
	
	reg [15:0] shift_reg, shift_next;

	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			shift_reg <= 16'b1000011100110101;
		else if (iLOAD)
			shift_reg <= iSEED;
		else if (iEN)
			shift_reg <= shift_next;

	always @*
		shift_next = 
			{shift_reg[14:0], 
			 shift_reg[15] ^ shift_reg[13] ^ shift_reg[12] ^ shift_reg[10]};

	assign oRAND = shift_reg;
endmodule

