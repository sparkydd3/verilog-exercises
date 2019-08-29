module stack
	#(
		parameter DATA_WIDTH = 8,
		          ADDR_WIDTH = 4
	)
	(
		input wire iCLK, iRESET,
		input wire iPUSH, iPOP,
		output wire oFULL, oEMPTY,
		input wire [DATA_WIDTH-1:0] iWDATA,
		output wire [DATA_WIDTH-1:0] oRDATA
	);

	wire wr_en;
	wire [ADDR_WIDTH-1:0] stack_ptr, stack_ptr_next;

	reg_file #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) mem
		(.iCLK(iCLK), .iWE(wr_en), 
		 .iRADDR(stack_ptr), .iWADDR(stack_ptr_next),
		 .iWDATA(iWDATA), .oRDATA(oRDATA));

	stack_ctrl #(.ADDR_WIDTH(ADDR_WIDTH)) ctrl
		(.iCLK(iCLK), .iRESET(iRESET),
		 .iPUSH(iPUSH), .iPOP(iPOP),
		 .oSPTR(stack_ptr), .oSPTR_NEXT(stack_ptr_next), .oWE(wr_en),
		 .oFULL(oFULL), .oEMPTY(oEMPTY));

endmodule
