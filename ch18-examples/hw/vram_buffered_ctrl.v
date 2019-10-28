module vram_buffered_ctrl
	(
		// memory interface to vga read
		output wire [7:0] o_vga_readdata,
		output wire o_vga_hsync,
		output wire o_vga_vsync,
		output wire o_vga_video_on,

		// memory interface to cpu
		output wire [7:0] o_cpu_readdata,
		output wire o_cpu_readdatavalid,
		output wire o_cpu_waitrequest, 
		input wire [18:0] i_cpu_address,
		input wire [7:0] i_cpu_writedata,
		input wire i_cpu_read,
		input wire i_cpu_write, 

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
		input wire i_p_tick,
		input wire i_hsync,
		input wire i_vsync,
		input wire i_video_on,

		input wire i_clk, 
		input wire i_reset
	);

	localparam ROW_PX_CNT = 640;
	localparam ADDR_WIDTH = $clog2(ROW_PX_CNT / 2); // read 2 bytes at once

	wire [15:0] fifo_r_data;
	wire fifo_rd;
	wire fifo_wr;

	fifo #(.DATA_WIDTH(16), .ADDR_WIDTH(ADDR_WIDTH)) fifo
		(.o_r_data(fifo_r_data),
		 .o_empty(),
		 .o_full(),
		 
		 .i_w_data(io_sram_dq),
		 .i_wr(fifo_wr),
		 .i_rd(fifo_rd),

		 .i_clk(i_clk),
		 .i_reset(i_reset)
		);

	// symbolic state declaration
	localparam [0:0]
		idle	= 1'b0,
		refresh = 1'b1;
	reg [0:0] state_reg;

	// signal declaration
	reg [7:0] cpu_wr_data_reg;
	reg [7:0] cpu_rd_data_reg;

	reg refresh_pending_reg;
	reg [9:0] row_cnt_reg;

	reg [18:0] sram_addr_reg;
	reg [1:0] sram_ulb_n_reg;
	reg ce_n_reg;
	reg oe_n_reg;
	reg we_n_reg;

	wire cpu_rd, cpu_wr;
	assign cpu_rd = i_cpu_read & ~o_cpu_waitrequest;
	assign cpu_wr = i_cpu_write & ~o_cpu_waitrequest;

	wire [18:0] vga_row_calc_addr;
	assign vga_row_calc_addr = {i_pixel_y, 9'b0} + {2'b0, i_pixel_y, 7'b0};

	// sram control
	always @(posedge i_clk, posedge i_reset)
		if (i_reset)
			begin
				state_reg <= idle;

				cpu_wr_data_reg <= 0;

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
				sram_addr_reg <= 0;
				sram_ulb_n_reg <= 2'b11;
				ce_n_reg <= 1'b1;
				oe_n_reg <= 1'b1;
				we_n_reg <= 1'b1;

				case (state_reg)
					idle:
						begin
							if (~i_video_on)
								refresh_pending_reg <= 1'b1;
								
							if (i_video_on & refresh_pending_reg)
								begin
									state_reg <= refresh;
									row_cnt_reg <= 319;	// 640 / 2, read 2 bytes at once

									ce_n_reg <= 1'b0;
									oe_n_reg <= 1'b0;
									sram_ulb_n_reg <= 2'b00;
									sram_addr_reg <= vga_row_calc_addr;
								end
							else if (cpu_rd)
								begin
									ce_n_reg <= 1'b0;
									oe_n_reg <= 1'b0;
									sram_ulb_n_reg <= 2'b00;
									sram_addr_reg <= i_cpu_address;
								end
							else if (cpu_wr)
								begin
									ce_n_reg <= 1'b0;
									we_n_reg <= 1'b0;
									sram_ulb_n_reg <= i_cpu_address[0] ? 2'b01 : 2'b10;
									sram_addr_reg <= i_cpu_address;
									cpu_wr_data_reg <= i_cpu_writedata;
								end
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
									sram_addr_reg <= sram_addr_reg + 2;
									
									row_cnt_reg <= row_cnt_reg - 1;
								end
						end
				endcase
			end
	
	// cpu read control
	reg [1:0] cpu_rd_pipe;
	always @(posedge i_clk, posedge i_reset)
		if (i_reset)
			begin
				cpu_rd_pipe <= 0;
				cpu_rd_data_reg <= 0;
			end
		else
			begin
				if (cpu_rd_pipe[0])
					cpu_rd_data_reg <= (sram_addr_reg[0]) ? io_sram_dq[15:8] : io_sram_dq[7:0];

				cpu_rd_pipe <= {cpu_rd_pipe[0], cpu_rd};
			end

	assign fifo_wr = (state_reg == refresh);

	assign o_cpu_waitrequest = (i_video_on & refresh_pending_reg) | (state_reg == refresh);
	assign o_cpu_readdatavalid = cpu_rd_pipe[1];
	assign o_cpu_readdata = cpu_rd_data_reg;
	
	// vga read control
	reg [1:0] hsync_pipe;
	reg [1:0] vsync_pipe;
	reg [1:0] video_on_pipe;
	reg [1:0] p_tick_pipe;	
	reg vga_rd_lb_reg;

	always @(posedge i_clk, posedge i_reset)
		if (i_reset)
			begin
				hsync_pipe <= 2'b00;
				vsync_pipe <= 2'b00;
				video_on_pipe <= 2'b00;
				p_tick_pipe <= 2'b00;
				vga_rd_lb_reg <= 1'b1;
			end
		else
			begin
				hsync_pipe <= {hsync_pipe[0], i_hsync};
				vsync_pipe <= {vsync_pipe[0], i_vsync};
				video_on_pipe <= {video_on_pipe[0], i_video_on};
				p_tick_pipe <= {p_tick_pipe[0], i_p_tick};
				
				if (~video_on_pipe[1])
					vga_rd_lb_reg <=1'b1;
				else if (video_on_pipe[1] & p_tick_pipe[1])
					vga_rd_lb_reg <= ~vga_rd_lb_reg;
			end
	
	assign fifo_rd = video_on_pipe[1] & p_tick_pipe[1] & ~vga_rd_lb_reg;

	assign o_vga_hsync = hsync_pipe[1];
	assign o_vga_vsync = vsync_pipe[1];
	assign o_vga_video_on = video_on_pipe[1];
	assign o_vga_readdata = vga_rd_lb_reg ? fifo_r_data[7:0] : fifo_r_data[15:8];

	//=======================================================================
	// SRAM interface signals
	//=======================================================================
	// configure SRAM as 512K-by-8

	assign o_sram_addr = sram_addr_reg[18:1];
	assign o_sram_lb_n = sram_ulb_n_reg[0];
	assign o_sram_ub_n = sram_ulb_n_reg[1];
	assign o_sram_ce_n = ce_n_reg;
	assign o_sram_oe_n = oe_n_reg;
	assign o_sram_we_n = we_n_reg;
	assign io_sram_dq = we_n_reg ? 16'bz : {cpu_wr_data_reg, cpu_wr_data_reg};
endmodule
