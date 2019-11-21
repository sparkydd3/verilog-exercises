module fifo_ctrl
	#(
		parameter ADDR_WIDTH = 4	// number of address bits
	)
	(
		output wire [ADDR_WIDTH-1:0] o_r_addr,
		output wire [ADDR_WIDTH-1:0] o_r_addr_next,
		output wire [ADDR_WIDTH-1:0] o_w_addr,
		output wire o_empty, 
		output wire o_full,
		input wire i_rd, 
		input wire i_wr,

		input wire i_clk, 
		input wire i_reset
	);

	// signal declaration
	reg [ADDR_WIDTH-1:0] w_ptr_reg, w_ptr_next, w_ptr_succ;
	reg [ADDR_WIDTH-1:0] r_ptr_reg, r_ptr_next, r_ptr_succ;
	reg full_reg, empty_reg, full_next, empty_next;

	// body
	// fifo control logic
	// registers for status and read and i_write pointers
	always @(posedge i_clk, posedge i_reset)
		if (i_reset)
			begin
				w_ptr_reg <= 0;
				r_ptr_reg <= 0;
				full_reg <= 1'b0;
				empty_reg <= 1'b1;
			end
		else
			begin
				w_ptr_reg <= w_ptr_next;
				r_ptr_reg <= r_ptr_next;
				full_reg <= full_next;
				empty_reg <= empty_next;
			end

	// next-state logic for read and i_write pointers
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

		case ({i_wr, i_rd})
			//2'b00: no op
			2'b01:	// read
				if (~empty_reg)	// not empty
					begin
						r_ptr_next = r_ptr_succ;
						full_next = 1'b0;
						if (r_ptr_succ == w_ptr_reg)
							empty_next = 1'b1;
					end
			2'b10: // write
				if (~full_reg)	// not full
					begin
						w_ptr_next = w_ptr_succ;
						empty_next = 1'b0;
						if (w_ptr_succ == r_ptr_reg)
							full_next = 1'b1;
					end
			2'b11:	// write and read
				begin
					w_ptr_next = w_ptr_succ;
					r_ptr_next = r_ptr_succ;
				end
		endcase
	end
	
	// output
	assign o_w_addr = w_ptr_reg;
	assign o_r_addr = r_ptr_reg;
	assign o_r_addr_next = r_ptr_next;
	assign o_full = full_reg;
	assign o_empty = empty_reg;
endmodule
