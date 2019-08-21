module bcd_incr
	(
		input wire [11:0] iBCD,
		output reg [11:0] oIncr,
		output reg oOverflow, oInvalid
	);

	wire [3:0] iHundreds, iTens, iOnes;
	assign {iHundreds, iTens, iOnes} = iBCD;

	reg [3:0] oHundreds, oTens, oOnes;

	always @*
	begin
		oOverflow = 1'b0;
		oInvalid = (iOnes > 4'd9) | (iTens > 4'd9) | (iHundreds > 4'd9);
		
		oHundreds = iHundreds;
		oTens = iTens;
		oOnes = iOnes;

		if (iOnes == 4'd9)
			oOnes = 4'd0;
		else 
			oOnes = iOnes + 4'd1;

		if (iOnes == 4'd9) begin
			if (iTens == 4'd9)
				oTens = 4'd0;
			else 
				oTens = iTens + 4'd1;
		end

		if (iOnes == 4'd9 & iTens == 4'd9) begin
			if (iHundreds == 4'd9) begin
				oHundreds = 4'd0;
				oOverflow = 4'b1;
			end
			else
				oHundreds = iHundreds + 4'd1;
		end
		
		oIncr = {oHundreds, oTens, oOnes};
	end
endmodule
