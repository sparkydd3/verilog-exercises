module gtr2
	(
		input wire [1:0] iA,
		input wire [1:0] iB,
		output wire oGtr
	);

	wire p0, p1, p2;

	assign p0 =  iA[1] & ~iB[1];
	assign p1 =  iA[1] &  iA[0] & ~iB[0];
	assign p2 = ~iB[1] &  iA[0] & ~iB[0];

	assign oGtr = p0 | p1 | p2;
endmodule
