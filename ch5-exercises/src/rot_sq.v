module rot_sq
	(
		input wire iCLK, iRESET,
		input wire iEN, iCW,
		output reg [7:0] oSQ,
		output reg [6:0] oSSEG3, oSSEG2, oSSEG1, oSSEG0
	);

	reg [7:0] sq_reg, sq_next;

	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			sq_reg <= 8'b10000000;
		else
			sq_reg <= sq_next;

	always @*
		if (iEN)
			sq_next = (iCW) ? {sq_reg[0], sq_reg[7:1]} : 
			                  {sq_reg[6:0], sq_reg[7]}; 
		else
			sq_next = sq_reg;

	always @*
	begin
		oSSEG3 = 7'b1111111;
		oSSEG2 = 7'b1111111;
		oSSEG1 = 7'b1111111;
		oSSEG0 = 7'b1111111;

		case (sq_reg)
			8'b10000000: oSSEG3 = 7'b0011100;
			8'b01000000: oSSEG2 = 7'b0011100;
			8'b00100000: oSSEG1 = 7'b0011100;
			8'b00010000: oSSEG0 = 7'b0011100;
			8'b00001000: oSSEG0 = 7'b0100011;
			8'b00000100: oSSEG1 = 7'b0100011;
			8'b00000010: oSSEG2 = 7'b0100011;
			8'b00000001: oSSEG3 = 7'b0100011;
		endcase
	end
endmodule
