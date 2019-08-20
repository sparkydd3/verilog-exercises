module gtr4
	(
		input wire [3:0] iA,
		input wire [3:0] iB,
		output wire oGtr
	);

	wire top_Gtr, top_Eq, bot_Gtr;

	gtr2 gtr_top
		(.iA(iA[3:2]), .iB(iB[3:2]), .oGtr(top_Gtr));
	
	eq2 eq_top
		(.iA(iA[3:2]), .iB(iB[3:2]), .oEq(top_Eq));

	gtr2 gtr_bot
		(.iA(iA[1:0]), .iB(iB[1:0]), .oGtr(bot_Gtr));

	assign oGtr = top_Gtr | (top_Eq & bot_Gtr);

endmodule
