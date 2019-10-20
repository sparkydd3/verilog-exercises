module vram_ctrl
	(
		// memory interface to vga read
		output wire [7:0] vga_readdata_o,

		// memory interface to cpu
		output wire [7:0] cpu_readdata_o,
		output wire cpu_readdatavalid_o,
		output wire cpu_waitrequest_o, 
		input wire [18:0] cpu_address_i,
		input wire [7:0] cpu_writedata_i,
		input wire cpu_read_i,
		input wire cpu_write_i, 

		// to/from SRAM
		output wire [17:0] sram_addr_o,
		output wire sram_ub_n_o,
		output wire sram_lb_n_o, 
		output wire sram_ce_n_o, 
		output wire sram_oe_n_o, 
		output wire sram_we_n_o,
		inout wire [15:0] sram_dq_io,

		// from video sync
		input wire [9:0] pixel_x_i, 
		input wire [9:0] pixel_y_i,
		input wire p_tick_i,

		input wire clk, 
		input wire reset
	);

	// symbolic state declaration
	localparam [2:0]
		idle	= 3'b000,
		wait_rd	= 3'b001,
		rd		= 3'b010,
		wait_wr	= 3'b100,
		wr		= 3'b101;
	
	// signal declaration
	reg [2:0] state_reg, state_next;
	reg [18:0] cpu_addr_reg, cpu_addr_next;
	reg [18:0] mem_addr_reg, mem_addr_next;
	reg rd_valid_reg, rd_valid_next;
	reg [7:0] cpu_wr_data_reg, cpu_wr_data_next;
	reg [7:0] cpu_rd_data_reg, cpu_rd_data_next;
	reg [7:0] vga_rd_data_reg, vga_rd_data_next; 
	reg we_n_reg, we_n_next;

	wire [7:0] byte_from_sram;
	wire [18:0] vga_addr_calc;

	// body
	// p-tick asserted every 2 clock cycles
	//=======================================================================
	// VGA port SRAM read operation
	//=======================================================================

	always @(posedge clk, posedge reset)
		if (reset)
			vga_rd_data_reg <= 0;
		else if (p_tick_i)
			vga_rd_data_reg <= byte_from_sram;

	assign vga_readdata_o = vga_rd_data_reg;

	//=======================================================================
	// CPU port SRAM read operation
	//=======================================================================
	assign cpu_readdata_o = cpu_rd_data_reg;
	assign cpu_readdatavalid_o = rd_valid_reg;
	assign cpu_waitrequest_o = ~(state_reg == idle);

	// FSMD state & data registers
	always @(posedge clk, posedge reset)
		if (reset)
			begin
				state_reg <= idle;
				cpu_addr_reg <= 0;
				cpu_wr_data_reg <= 0;
				cpu_rd_data_reg <= 0;
				rd_valid_reg <= 1'b0;
				we_n_reg <= 1'b0;
				mem_addr_reg <= 0;
			end
		else
			begin
				state_reg <= state_next;
				cpu_addr_reg <= cpu_addr_next;
				cpu_wr_data_reg <= cpu_wr_data_next;
				cpu_rd_data_reg <= cpu_rd_data_next;
				rd_valid_reg <= rd_valid_next;
				we_n_reg <= we_n_next;
				mem_addr_reg <= mem_addr_next;
			end

	always @*
		begin
			state_next = state_reg;
			cpu_addr_next = cpu_addr_reg;
			cpu_wr_data_next = cpu_wr_data_reg;
			cpu_rd_data_next = cpu_rd_data_reg;
			mem_addr_next = vga_addr_calc;
			
			rd_valid_next = 1'b0;
			we_n_next = 1'b1;

			case (state_reg)
				idle:
					if (cpu_read_i)
						if (p_tick_i)
							begin
								state_next = rd;
								mem_addr_next = cpu_address_i;
							end
						else
							begin
								state_next = wait_rd;
								cpu_addr_next = cpu_address_i;
							end
					else if (cpu_write_i)
						if (p_tick_i)
							begin
								state_next = wr;
								mem_addr_next = cpu_address_i;
								cpu_wr_data_next = cpu_writedata_i;
								we_n_next = 1'b0;
							end
						else
							begin
								state_next= wait_wr;
								cpu_addr_next = cpu_address_i;
								cpu_wr_data_next = cpu_writedata_i;
							end
				rd:
					begin
						state_next = idle;
						cpu_rd_data_next = byte_from_sram;
						rd_valid_next = 1'b1;
					end
				wr:
					state_next = idle;
				wait_rd:
					begin
						state_next = rd;
						mem_addr_next = cpu_addr_reg;
					end
				wait_wr:
					begin
						state_next = wr;
						mem_addr_next = cpu_addr_reg;
						we_n_next = 1'b0;
					end
			endcase
		end

	// VGA port address offset = 640 * y + x = 512 * y + 128 * y + x
	assign vga_addr_calc = {pixel_y_i, 9'b0} + {2'b0, pixel_y_i, 7'b0} + {9'b0, pixel_x_i};

	//=======================================================================
	// SRAM interface signals
	//=======================================================================
	// configure SRAM as 512K-by-8

	assign sram_addr_o = mem_addr_reg[18:1];
	assign sram_lb_n_o = mem_addr_reg[0];
	assign sram_ub_n_o = ~mem_addr_reg[0];
	assign sram_ce_n_o = 1'b0;
	assign sram_oe_n_o = 1'b0;
	assign sram_we_n_o = we_n_reg;
	assign sram_dq_io = we_n_reg ? 16'bz : {cpu_wr_data_reg, cpu_wr_data_reg};

	// LSB control 
	assign byte_from_sram = mem_addr_reg[0] ? sram_dq_io[15:8] : sram_dq_io[7:0];
endmodule
