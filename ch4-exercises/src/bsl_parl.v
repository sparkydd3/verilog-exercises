module bsl_parl
	#(
		parameter N = 8,
		parameter W = $clog2(N)
	)
	(
		input wire [N-1:0] iA,
		input wire [W-1:0] iAmt,
		output wire [N-1:0] oY
	);

	wire [N-1:0] mux_in [N-1:0];

	generate
		genvar i;
		for (i = 0; i < N; i = i + 1) begin: gen
			assign mux_in[i] = {iA[N-1-i:0], iA[N-1:N-1-i]} >> 1;
		end
	endgenerate

	assign oY = mux_in[iAmt];

endmodule
