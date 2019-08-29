module rot_banner
	(
		input wire iCLK, iRESET, iEN, iDIR,
		output wire [3:0] oBIN3, oBIN2, oBIN1, oBIN0
	);

	reg [3:0] bin3_reg, bin2_reg, bin1_reg, bin0_reg;

	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			begin
				bin3_reg <= 4'd0;
				bin2_reg <= 4'd1;
				bin1_reg <= 4'd2;
				bin0_reg <= 4'd3;
			end
		else if (iEN)
			if (iDIR)
				begin
					bin3_reg <= bin2_reg; 
					bin2_reg <= bin1_reg; 
					bin1_reg <= bin0_reg; 
					bin0_reg <= (bin0_reg == 4'd9) ? 4'd0 : bin0_reg + 1;
				end
			else
				begin
					bin3_reg <= (bin3_reg == 4'd0) ? 4'd9 : bin3_reg - 1;
					bin2_reg <= bin3_reg;
					bin1_reg <= bin2_reg; 
					bin0_reg <= bin1_reg;
				end
	
	assign oBIN3 = bin3_reg;
	assign oBIN2 = bin2_reg;
	assign oBIN1 = bin1_reg;
	assign oBIN0 = bin0_reg;
endmodule
