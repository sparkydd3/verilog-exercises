module univ_bin_counter
	#(
		parameter N = 8
	)
	(
		input wire iCLK, iRESET,
		input wire iCLEAR, iLOAD, iEN, iUP,
		input wire [N-1:0] iD,
		output wire oMAX, oMIN,
		output reg [N-1:0] oQ
	);

	// body
	// register and next-state logic
	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			oQ <= 0;
		else if (iCLEAR)
			oQ <= 0;
		else if (iLOAD)
			oQ <= iD;
		else if (iEN & iUP)
			oQ <= oQ + 1;
		else if (iEN & ~iUP)
			oQ <= oQ - 1;
		// no else branch since q <= q is implicitly implied
	
	// output logic
	assign oMAX = (oQ == 2**N - 1) ? 1'b1 : 1'b0;
	assign oMIN = (oQ == 0) ? 1'b1 : 1'b0;
endmodule
