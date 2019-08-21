module fp2smag
	(
		input wire [12:0] iFp,
		output wire [7:0] oSmag,
		output wire oUF, oOF
	);

	wire [3:0] exp;
	wire [7:0] frac;
	wire [6:0] mag;

	assign exp = iFp[11:8];
	assign frac = iFp[7:0];

	assign oUF = (exp == 4'b0 & frac != 8'd0);
	assign oOF = (exp > 4'd7);
	assign mag = (oUF | oOF) ? frac : frac >> (4'd8 - exp);

	assign oSmag = {iFp[12], mag};
endmodule
