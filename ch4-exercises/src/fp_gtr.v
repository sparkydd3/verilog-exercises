module fp_gtr
	(
		input wire iSign1, iSign2,
		input wire [3:0] iExp1, iExp2,
		input wire [7:0] iFrac1, iFrac2,
		output reg oGtr
	);

	always @*
		case({iSign1, iSign2})
			2'b00: oGtr = {iExp1, iFrac1} > {iExp2, iFrac2};	// both positive
			2'b11: oGtr = {iExp1, iFrac1} < {iExp2, iFrac2};	// both negative
			2'b10: oGtr = 1'b0;
			2'b01: oGtr = 1'b1;
		endcase
endmodule
