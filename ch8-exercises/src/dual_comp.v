module dual_comp
	#(
		parameter W = 8
	)
	(
		input wire [W-1:0] iA, iB,
		input wire iSIGNED,
		output reg oGT
	);
	
	reg signed [W-1:0] a_signed, b_signed;
	reg [W-1:0] a_unsigned, b_unsigned;

	always @*
	begin
		a_signed = $signed(iA);
		b_signed = $signed(iB);
		a_unsigned = iA;
		b_unsigned = iB;

		oGT = (iSIGNED) ? a_signed > b_signed :
		                  a_unsigned > b_unsigned ;
	end
endmodule
