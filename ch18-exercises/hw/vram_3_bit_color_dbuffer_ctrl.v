module vram_3_bit_color_dbuffer_ctrl
	(
		// memory interface to vga read
		output wire [3:0] o_vga_readdata,
		output wire o_vga_hsync,
		output wire o_vga_vsync,
		output wire o_vga_video_on,

		// memory interface to cpu
		output wire [3:0] o_cpu_readdata,
		output wire o_cpu_readdatavalid,
		output wire o_cpu_waitrequest, 
		input wire [18:0] i_cpu_address,
		input wire [3:0] i_cpu_writedata,
		input wire i_cpu_switch_dbuffer,
		input wire i_cpu_read,
		input wire i_cpu_write, 
		input wire i_cpu_clk,
		input wire i_cpu_reset,

		// to/from SRAM
		output wire [17:0] o_sram_addr,
		output wire o_sram_ub_n,
		output wire o_sram_lb_n, 
		output wire o_sram_ce_n, 
		output wire o_sram_oe_n, 
		output wire o_sram_we_n,
		inout wire [15:0] io_sram_dq,

		// from video sync
		input wire [9:0] i_pixel_x,
		input wire [9:0] i_pixel_y,
		input wire i_hsync,
		input wire i_vsync,
		input wire i_video_on,
		input wire i_vga_clk,
		input wire i_vga_reset
	);

	//=======================================================================
	// Clock domain crossing from VGA to CPU
	//=======================================================================
	reg [9:0] q2_pixel_y, q1_pixel_y;
	reg q2_video_on, q1_video_on;

	always @(posedge i_cpu_clk, posedge i_cpu_reset)
		if (i_cpu_reset)
			begin
				{q2_pixel_y, q1_pixel_y} <= 0;
				{q2_video_on, q1_video_on} <= 0;
			end
		else
			begin
				{q2_pixel_y, q1_pixel_y} <= {q1_pixel_y, i_pixel_y};
				{q2_video_on, q1_video_on} <= {q1_video_on, i_video_on};
			end

	//=======================================================================
	// FIFO buffer 
	//=======================================================================

	localparam ROW_PX_CNT = 640;
	localparam ADDR_WIDTH = $clog2(ROW_PX_CNT / 4); // read 4 pixels at once

	wire [15:0] fifo_rd_data;
	wire fifo_rd, fifo_wr;

	fifo_async #(.DATA_WIDTH(16), .ADDR_WIDTH(ADDR_WIDTH)) fifo_async
		(.o_rd_data(fifo_rd_data),
		 .o_rd_empty(),
		 .i_read(fifo_rd),
		 .i_rd_clk(i_vga_clk),
		 .i_rd_reset(i_vga_reset),

		 .o_wr_full(),
		 .i_wr_data(io_sram_dq),
		 .i_write(fifo_wr),
		 .i_wr_clk(i_cpu_clk),
		 .i_wr_reset(i_cpu_reset)
		);

	//=======================================================================
	// CPU SRAM control 
	//=======================================================================
	localparam [1:0]
		idle		= 2'd0,
		refresh 	= 2'd1,
		prewrite	= 2'd2,
		postread    = 2'd3;
	reg [1:0] state_reg;

	reg [3:0] cpu_wr_data_reg;
	reg [3:0] cpu_rd_data_reg;
	reg [15:0] sram_wr_data_reg;

	reg refresh_pending_reg;
	reg [9:0] row_cnt_reg;

	reg sram_buffer_bit_reg;
	reg [19:0] sram_addr_reg;
	reg [1:0] sram_ulb_n_reg;
	reg ce_n_reg;
	reg oe_n_reg;
	reg we_n_reg;

	wire cpu_rd, cpu_wr, cpu_switch_wr_buffer;
	assign cpu_rd = i_cpu_read & ~o_cpu_waitrequest;
	assign cpu_wr = i_cpu_write & ~o_cpu_waitrequest;
	assign cpu_switch_wr_buffer = i_cpu_switch_dbuffer & ~o_cpu_waitrequest;

	wire [18:0] vga_row_calc_addr;
	assign vga_row_calc_addr = {q2_pixel_y, 9'b0} + {2'b0, q2_pixel_y, 7'b0};

	always @(posedge i_cpu_clk, posedge i_cpu_reset)
		if (i_cpu_reset)
			begin
				state_reg <= idle;

				cpu_wr_data_reg <= 0;
				sram_wr_data_reg <= 0;
				sram_buffer_bit_reg <= 1'b0;

				sram_addr_reg <= 0;
				sram_ulb_n_reg <= 2'b11;
				ce_n_reg <= 1'b1;
				oe_n_reg <= 1'b1;
				we_n_reg <= 1'b1;

				refresh_pending_reg <= 1'b1;
				row_cnt_reg <= 0;
			end
		else
			begin
				sram_ulb_n_reg <= 2'b11;
				ce_n_reg <= 1'b1;
				oe_n_reg <= 1'b1;
				we_n_reg <= 1'b1;
				
				case (state_reg)
					idle:
						begin
							if (~q2_video_on)
								refresh_pending_reg <= 1'b1;

							if (q2_video_on && refresh_pending_reg)
								begin
									state_reg <= refresh;
									row_cnt_reg <= 159;	// 640 / 4, read 2 pixels at once

									ce_n_reg <= 1'b0;
									oe_n_reg <= 1'b0;
									sram_ulb_n_reg <= 2'b00;
									sram_addr_reg <= {sram_buffer_bit_reg, vga_row_calc_addr};
								end
							else if (cpu_rd)
								begin
									ce_n_reg <= 1'b0;
									oe_n_reg <= 1'b0;
									sram_ulb_n_reg <= 2'b00;
									sram_addr_reg <= {~sram_buffer_bit_reg, i_cpu_address};
								end
							else if (cpu_wr)
								begin
									state_reg <= prewrite;
									ce_n_reg <= 1'b0;
									oe_n_reg <= 1'b0;
									sram_ulb_n_reg <= 2'b00;
									sram_addr_reg <= {~sram_buffer_bit_reg, i_cpu_address};
									cpu_wr_data_reg <= i_cpu_writedata;
								end
							else if (cpu_switch_wr_buffer)
								begin
 									// switch working buffer
									sram_buffer_bit_reg <= ~sram_buffer_bit_reg;
								end
						end
					prewrite:
						begin
							state_reg <= idle;
							ce_n_reg <= 1'b0;
							we_n_reg <= 1'b0;
							sram_ulb_n_reg <= 2'b00;
							sram_wr_data_reg <= io_sram_dq;
							case (sram_addr_reg[1:0])
								2'd0: sram_wr_data_reg[3:0] <= cpu_wr_data_reg;
								2'd1: sram_wr_data_reg[7:4] <= cpu_wr_data_reg;
								2'd2: sram_wr_data_reg[11:8] <= cpu_wr_data_reg;
								2'd3: sram_wr_data_reg[15:12] <= cpu_wr_data_reg;
							endcase
						end
					refresh:
						begin
							if (row_cnt_reg == 0)
								begin
									state_reg <= idle;
									refresh_pending_reg <= 1'b0;
								end
							else
								begin
									ce_n_reg <= 1'b0;
									oe_n_reg <= 1'b0;
									sram_ulb_n_reg <= 2'b00;
									sram_addr_reg <= sram_addr_reg + 4;
									row_cnt_reg <= row_cnt_reg - 1;
								end
						end
				endcase
			end
	
	//=======================================================================
	// CPU SRAM readdata control and status
	//=======================================================================
	reg [1:0] cpu_rd_pipe;
	always @(posedge i_cpu_clk, posedge i_cpu_reset)
		if (i_cpu_reset)
			begin
				cpu_rd_pipe <= 0;
				cpu_rd_data_reg <= 0;
			end
		else
			begin
				if (cpu_rd_pipe[0])
					case (sram_addr_reg[1:0])
						2'd0 : cpu_rd_data_reg <= io_sram_dq[3:0];
						2'd1 : cpu_rd_data_reg <= io_sram_dq[7:4];
						2'd2 : cpu_rd_data_reg <= io_sram_dq[11:8];
						2'd3 : cpu_rd_data_reg <= io_sram_dq[15:12];
					endcase

				cpu_rd_pipe <= {cpu_rd_pipe[0], cpu_rd};
			end

	assign fifo_wr = (state_reg == refresh);

	assign o_cpu_waitrequest = 
		(q2_video_on && refresh_pending_reg) || 
		(state_reg == refresh) ||
		(state_reg == prewrite);

	assign o_cpu_readdatavalid = cpu_rd_pipe[1];
	assign o_cpu_readdata = cpu_rd_data_reg;
	
	//=======================================================================
	// VGA FIFO read control signals
	//=======================================================================
	// delay vga sync signals to give enough time for cpu to begin filling 
	// fifo buffer with data to read
	
	localparam PL = 4;
	reg [PL-1:0] hsync_pipe;
	reg [PL-1:0] vsync_pipe;
	reg [PL-1:0] video_on_pipe;
	reg [1:0] vga_rd_byte_reg;

	always @(posedge i_vga_clk, posedge i_vga_reset)
		if (i_vga_reset)
			begin
				hsync_pipe <= 0;
				vsync_pipe <= 0;
				video_on_pipe <= 0;

				vga_rd_byte_reg <= 0;
			end
		else 
			begin
				hsync_pipe <= {hsync_pipe[PL-2:0], i_hsync};
				vsync_pipe <= {vsync_pipe[PL-2:0], i_vsync};
				video_on_pipe <= {video_on_pipe[PL-2:0], i_video_on};
			
				if (~video_on_pipe[PL-1])
					vga_rd_byte_reg <= 0;
				else
					vga_rd_byte_reg <= vga_rd_byte_reg + 1;
			end
	
	assign fifo_rd = video_on_pipe[PL-1] && (vga_rd_byte_reg == 2);

	//=======================================================================
	// VGA interface signals
	//=======================================================================

	assign o_vga_hsync = hsync_pipe[PL-1];
	assign o_vga_vsync = vsync_pipe[PL-1];
	assign o_vga_video_on = video_on_pipe[PL-1];

	assign o_vga_readdata = 
		(vga_rd_byte_reg == 0) ? fifo_rd_data[3:0]  : 
		(vga_rd_byte_reg == 1) ? fifo_rd_data[7:4]  :
		(vga_rd_byte_reg == 2) ? fifo_rd_data[11:8] :
		                         fifo_rd_data[15:12];

	//=======================================================================
	// SRAM interface signals
	//=======================================================================

	assign o_sram_addr = sram_addr_reg[19:2];
	assign o_sram_lb_n = sram_ulb_n_reg[0];
	assign o_sram_ub_n = sram_ulb_n_reg[1];
	assign o_sram_ce_n = ce_n_reg;
	assign o_sram_oe_n = oe_n_reg;
	assign o_sram_we_n = we_n_reg;
	assign io_sram_dq = we_n_reg ? 16'bz : sram_wr_data_reg;
endmodule
