module bsmfunc_rev
	#(
		parameter N = 8,
		parameter W = $clog2(N)
	)
	(
		input wire [N-1:0] iA,
		input wire [W-1:0] iAmt,
		input wire iLR,
		output wire [N-1:0] oY
	);

	wire [N-1:0] bsl_in, iA_rev, bsl_out, bsl_out_rev;
	genvar i;

	generate
	for (i = 0; i < N; i = i + 1) begin: in
		assign iA_rev[i] = iA[N-1-i];
	end
	endgenerate

	generate
	for (i = 0; i < N; i = i + 1) begin: out
		assign bsl_out_rev[i] = bsl_out[N-1-i];
	end
	endgenerate

	assign bsl_in = iLR ? iA : iA_rev;
	assign oY = iLR ? bsl_out : bsl_out_rev;

	bsl_parl #(.N(N)) bsl
		(.iA(bsl_in), .iAmt(iAmt), .oY(bsl_out));

endmodule
