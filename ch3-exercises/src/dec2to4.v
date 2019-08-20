module dec2to4
	(
		input wire [1:0] iEnc,
		output wire [3:0] oDec
	);

	assign oDec[3] =  iEnc[1] &  iEnc[0];
	assign oDec[2] =  iEnc[1] & ~iEnc[0];
	assign oDec[1] = ~iEnc[1] &  iEnc[0];
	assign oDec[0] = ~iEnc[1] & ~iEnc[0];

endmodule
