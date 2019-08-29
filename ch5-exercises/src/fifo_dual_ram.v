module fifo_dual_ram
	#(
		parameter DATA_WIDTH = 8,	// number of bits in a word
		          ADDR_WIDTH = 10	// number of address bits
	)
	(
		input wire iCLK, iRESET,
		input wire iRD, iWR,
		input wire [2*DATA_WIDTH-1:0] iWDATA,
		output wire oEMPTY, oFULL,
		output wire [DATA_WIDTH-1:0] oRDATA
	);
	
	// signal declaration
	wire [ADDR_WIDTH-1:0] w_addr, r_addr_next;
	wire [2*DATA_WIDTH-1:0] r_data_dual;
	wire r_upper;

	// body
	// instantiate fifo control unit
	fifo_dual_ctrl #(.ADDR_WIDTH(ADDR_WIDTH)) c_unit
		(.iCLK(iCLK), .iRESET(iRESET), .iRD(iRD), .iWR(iWR), 
		 .oEMPTY(oEMPTY), .oFULL(oFULL), 
		 .oWADDR(w_addr), .oRADDR(), .oRADDR_NEXT(r_addr_next),
		 .oRUPPER(r_upper));
	
	// instantiate synchronous SRAM
	altera_dual_port_ram_simple
		#(.DATA_WIDTH(2*DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) ram_unit
		(.iCLK(iCLK), .iWE(iWR & ~oFULL), 
		 .iWADDR(w_addr), .iRADDR(r_addr_next),
		 .iD(iWDATA), .oQ(r_data_dual));
	
	assign oRDATA = (r_upper == 1'b1) ? r_data_dual[2*DATA_WIDTH-1:DATA_WIDTH] :
	                                    r_data_dual[DATA_WIDTH-1:0];
endmodule
