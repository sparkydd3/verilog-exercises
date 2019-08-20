module eq1
	(
		input wire iA, iB,
		output wire oEq
	);

	wire p0, p1;

	assign oEq = p0 | p1;
	assign p0 = ~iA & ~iB;
	assign p1 = iA & iB;
endmodule
