module bsmfunc_dual
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

	wire [N-1:0] bsl_y, bsr_y;

	bsl_parl #(.N(N)) bsl
		(.iA(iA), .iAmt(iAmt), .oY(bsl_y)); 
	bsr_parl #(.N(N)) bsr
		(.iA(iA), .iAmt(iAmt), .oY(bsr_y)); 

	assign oY = iLR ? bsl_y : bsr_y;
endmodule
