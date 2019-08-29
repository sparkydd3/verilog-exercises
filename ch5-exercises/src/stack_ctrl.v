module stack_ctrl
	#(
		parameter ADDR_WIDTH = 4
	)
	(
		input wire iCLK, iRESET,
		input wire iPUSH, iPOP,
		output wire oFULL, oEMPTY, oWE,
		output wire [ADDR_WIDTH-1:0] oSPTR, oSPTR_NEXT
	);

	reg full_reg, full_next, empty_reg, empty_next, wr_en_next;
	reg [ADDR_WIDTH-1:0] stack_ptr_reg, stack_ptr_next;
	reg [ADDR_WIDTH-1:0] stack_ptr_succ, stack_ptr_prev;

	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			begin
				full_reg <= 1'b0;
				empty_reg <= 1'b1;
				stack_ptr_reg <= ADDR_WIDTH**2 - 1;	// first write on addr + 1 = 0
			end
		else
			begin
				full_reg <= full_next;
				empty_reg <= empty_next;
				stack_ptr_reg <= stack_ptr_next;
			end

	always @*
	begin
		full_next = full_reg;
		empty_next = empty_reg;
		stack_ptr_next = stack_ptr_reg;
		wr_en_next = 1'b0;

		stack_ptr_succ = stack_ptr_reg + 1;
		stack_ptr_prev = stack_ptr_reg - 1;

		case({iPUSH, iPOP})
			// 2'b00 : do nothing
			2'b10 : 
				if (~full_reg)
					begin
						wr_en_next = 1'b1;
						empty_next = 1'b0;
						stack_ptr_next = stack_ptr_succ;

						if (stack_ptr_succ == ADDR_WIDTH**2 - 1)
							full_next = 1'b1;
					end
			2'b01 :
				if (~empty_reg)
					begin
						full_next = 1'b0;
						stack_ptr_next = stack_ptr_prev;
						
						if (stack_ptr_prev == 0)
							empty_next = 1'b1;
					end
			2'b11:
				wr_en_next= 1'b1;
		endcase
	end

	assign oFULL = full_reg;
	assign oEMPTY = empty_reg;
	assign oWE = wr_en_next;
	assign oSPTR = stack_ptr_reg;
	assign oSPTR_NEXT = stack_ptr_next;
endmodule
