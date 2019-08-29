module fifo_dual_ctrl
	#(
		parameter ADDR_WIDTH = 4	// number of address bits
	)
	(
		input wire iCLK, iRESET,
		input wire iRD, iWR,
		output wire oEMPTY, oFULL, oRUPPER,
		output wire [ADDR_WIDTH-1:0] oWADDR,
		output wire [ADDR_WIDTH-1:0] oRADDR, oRADDR_NEXT
	);

	// signal declaration
	reg [ADDR_WIDTH-1:0] w_ptr_reg, w_ptr_next, w_ptr_succ;
	reg [ADDR_WIDTH-1:0] r_ptr_reg, r_ptr_next, r_ptr_succ;
	reg full_reg, empty_reg, full_next, empty_next;
	reg r_upper_reg, r_upper_next;

	// body
	// fifo control logic
	// registers for status and read and write pointers
	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			begin
				w_ptr_reg <= 0;
				r_ptr_reg <= 0;
				full_reg <= 1'b0;
				empty_reg <= 1'b1;
				r_upper_reg <= 1'b1;
			end
		else
			begin
				w_ptr_reg <= w_ptr_next;
				r_ptr_reg <= r_ptr_next;
				full_reg <= full_next;
				empty_reg <= empty_next;
				r_upper_reg <= r_upper_next;
			end

	// next-state logic for read and write pointers
	always @*
	begin
		// successive pointer values
		w_ptr_succ = w_ptr_reg + 1;
		r_ptr_succ = r_ptr_reg + 1;
	
		// default: keep old values
		w_ptr_next = w_ptr_reg;
		r_ptr_next = r_ptr_reg;
		full_next = full_reg;
		empty_next = empty_reg;
		r_upper_next = r_upper_reg;

		case ({iWR, iRD})
			// 2'b00: no op
			2'b01:	// read
				if (~empty_reg)	// not empty
					if (r_upper_reg)
						r_upper_next = 1'b0;
					else
						begin
							r_ptr_next = r_ptr_succ;
							full_next = 1'b0;
							r_upper_next = 1'b1;
							if (r_ptr_next == w_ptr_reg)
								empty_next = 1'b1;
						end
			2'b10: // write
				if (~full_reg)	// not full
					begin
						w_ptr_next = w_ptr_succ;
						empty_next = 1'b0;
						if (w_ptr_next == r_ptr_reg)
							full_next = 1'b1;
					end
			2'b11:	// write and read
				begin
					if (~full_reg) 
						begin
							w_ptr_next = w_ptr_succ;
							empty_next = 1'b0;
						end

					if (r_upper_next)
						r_upper_next = 1'b0;
					else
						begin
							r_ptr_next = r_ptr_succ;
							r_upper_next = 1'b1;
							full_next = 1'b0;
						end
					
					if (w_ptr_next == r_ptr_next)
						full_next = 1'b1;
				end
		endcase
	end
	
	// output
	assign oWADDR = w_ptr_reg;
	assign oRADDR = r_ptr_reg;
	assign oRADDR_NEXT = r_ptr_next;
	assign oRUPPER = r_upper_reg;
	assign oFULL = full_reg;
	assign oEMPTY = empty_reg;
endmodule
