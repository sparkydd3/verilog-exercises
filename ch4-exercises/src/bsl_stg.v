module bsl_stg
	#(
		parameter N = 8,
		parameter W = $clog2(N)
	)
	(
		input wire [N-1:0] iA,
		input wire [W-1:0] iAmt,
		output wire [N-1:0] oY
	);

	wire [N-1:0] stages [W:0];

	assign stages[W] = iA;
	generate
		genvar i;
		for (i = W-1; i >= 0; i = i - 1) begin: gen
			assign stages[i] = iAmt[i] ? 
				{stages[i+1][N-1-2**i:0], stages[i+1][N-1:N-2**i]} : 
				 stages[i+1];
		end
	endgenerate

	assign oY = stages[0];

endmodule
