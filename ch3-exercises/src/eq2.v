module eq2
	(
		input wire[1:0] iA, iB,
		output wire oEq
	);

	wire e0, e1;

	eq1 eq_bit0_unit (.iA(iA[0]), .iB(iB[0]), .oEq(e0));
	eq1 eq_bit1_unit (.iA(iA[1]), .iB(iB[1]), .oEq(e1));

	assign oEq = e0 & e1;
endmodule
