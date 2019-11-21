module vram_ctrl
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

	localparam [2:0]
		idle	= 3'b000,
		wait_rd	= 3'b001,
		rd		= 3'b010,
		wait_wr	= 3'b100,
		wr		= 3'b101;
	reg [2:0] state_reg;

	reg [7:0] cpu_wr_data_reg;
	reg [7:0] cpu_rd_data_reg;
	reg [7:0] vga_rd_data_reg;

	reg [18:0] sram_addr_reg;
	reg [1:0] sram_ulb_n_reg;
	reg ce_n_reg;
	reg oe_n_reg;
	reg we_n_reg;

	reg [1:0] rd_fetch_pipe;
	reg [1:0] rd_done_pipe;
	
	wire vga_rd, cpu_rd, cpu_wr;
	assign vga_rd = i_video_on & ~i_p_tick;
	assign cpu_rd = i_cpu_read & ~i_video_on;
	assign cpu_wr = i_cpu_write & ~i_video_on;

	wire [18:0] vga_calc_addr;
	assign vga_calc_addr = {i_pixel_y, 9'b0} + {2'b0, i_pixel_y, 7'b0} + {9'b0, i_pixel_x};

	always @(posedge i_clk, posedge i_reset)
		if (i_reset)
			begin
				rd_fetch_pipe <= 2'b00;
				rd_done_pipe <= 2'b00;
				cpu_rd_data_reg <= 0;
				cpu_wr_data_reg <= 0;
				vga_rd_data_reg <= 0;

				sram_addr_reg <= 0;
				sram_ulb_n_reg <= 2'b11;
				ce_n_reg <= 1'b1;
				oe_n_reg <= 1'b1;
				we_n_reg <= 1'b1;
			end
		else
			begin
				sram_ulb_n_reg <= 2'b11;
				ce_n_reg <= 1'b1;
				oe_n_reg <= 1'b1;
				we_n_reg <= 1'b1;

				if (vga_rd)
					begin
						ce_n_reg <= 1'b0;
						oe_n_reg <= 1'b0;
						sram_ulb_n_reg <= vga_calc_addr[0] ? 2'b01 : 2'b10;
						sram_addr_reg <= vga_calc_addr;
					end
				else if (cpu_rd)
					begin
						ce_n_reg <= 1'b0;
						oe_n_reg <= 1'b0;
						sram_ulb_n_reg <= i_cpu_address[0] ? 2'b01 : 2'b10;
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

				if (rd_fetch_pipe[0])
					cpu_rd_data_reg <= (sram_addr_reg[0]) ? io_sram_dq[15:8] : io_sram_dq[7:0];

				if (rd_fetch_pipe[1])
					vga_rd_data_reg <= (sram_addr_reg[0]) ? io_sram_dq[15:8] : io_sram_dq[7:0];
				
				rd_fetch_pipe <= {vga_rd, cpu_rd};
				rd_done_pipe <= rd_fetch_pipe;
			end
	
	reg [1:0] hsync_pipe;
	reg [1:0] vsync_pipe;
	reg [1:0] video_on_pipe;
	always @(posedge i_clk)
		begin
			hsync_pipe <= {hsync_pipe[0], i_hsync};
			vsync_pipe <= {vsync_pipe[0], i_vsync};
			video_on_pipe <= {video_on_pipe[0], i_video_on};
		end
	
	assign o_cpu_waitrequest = i_video_on;
	assign o_cpu_readdatavalid = rd_done_pipe[0];
	assign o_cpu_readdata = cpu_rd_data_reg;

	//=======================================================================
	// VGA interface signals
	//=======================================================================
	assign o_vga_readdata = vga_rd_data_reg;
	assign o_vga_hsync = hsync_pipe[1];
	assign o_vga_vsync = vsync_pipe[1];
	assign o_vga_video_on = video_on_pipe[1];

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
