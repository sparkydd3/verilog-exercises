module counter
	#(
		parameter W = 16
	)
	(
		input wire iCLK, iRESET,
		input wire iINC, iDEC,
		output wire [W-1:0] oCNT
	);
	
	reg [W-1:0] cnt_reg;

	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			cnt_reg <= 0;
		else if (iINC)
			cnt_reg <= cnt_reg + 1;
		else if (iDEC)
			cnt_reg <= cnt_reg - 1;
	
	assign oCNT = cnt_reg;
endmodule
