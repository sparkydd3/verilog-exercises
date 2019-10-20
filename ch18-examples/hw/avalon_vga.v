module avalon_vga
	(
		// Avalon MM interface
		output wire [31:0] readdata_o,
		output wire readdatavalid_o,
		output wire waitrequest_o,
		input wire [19:0] address_i,
		input wire chipselect_i,
		input wire read_i, 
		input wire write_i,
		input wire [31:0] writedata_i,

		// conduit (to VGA monitor)
		output wire hsync_o,
		output wire vsync_o,
		output wire [11:0] rgb_o,

		// conduit (to/from SRAM)
		output wire [17:0] sram_addr_o,
		output wire sram_ub_n_o,
		output wire sram_lb_n_o, 
		output wire sram_ce_n_o, 
		output wire sram_oe_n_o, 
		output wire sram_we_n_o,
		inout wire [15:0] sram_dq_io,

		input wire clk, 
		input wire reset
	);
	
	// signal declaration
	reg video_on_reg, vsync_reg, hsync_reg;
	wire video_on, vsync, hsync;
	wire p_tick;
	wire [9:0] pixel_x, pixel_y;
	reg [9:0] pixel_x_reg, pixel_y_reg;
	reg pixel_read_reg;
	wire wr_vram, rd_vram, rd_data_valid_vram;
	wire [7:0] cpu_readdata, vga_readdata;
	wire [11:0] color;

	// body
	//=======================================================================
	// instantiation
	//=======================================================================
	// instantiate VGA sync circuit
	vga_sync vga_sync
		(.hsync_o(hsync), 
		 .vsync_o(vsync),
		 .video_on_o(video_on), 
		 .p_tick_o(p_tick),
		 .pixel_x_o(pixel_x), 
		 .pixel_y_o(pixel_y),
		 .clk(clk),
		 .reset(reset)
		);

	// instantiate video SRAM control
	vram_ctrl vram_ctrl
		(// to video
		 .vga_readdata_o(vga_readdata), 

		 // avalon bus interface
		 .cpu_readdata_o(cpu_readdata),
		 .cpu_readdatavalid_o(rd_data_valid_vram), 
		 .cpu_waitrequest_o(waitrequest_o),
		 .cpu_address_i(address_i[18:0]),
		 .cpu_writedata_i(writedata_i[7:0]),
		 .cpu_read_i(rd_vram),
		 .cpu_write_i(wr_vram), 

		 // to/from SRAM chip
		 .sram_addr_o(sram_addr_o), 
		 .sram_ub_n_o(sram_ub_n_o), 
		 .sram_lb_n_o(sram_lb_n_o),
		 .sram_ce_n_o(sram_ce_n_o),	 
		 .sram_oe_n_o(sram_oe_n_o), 
		 .sram_we_n_o(sram_we_n_o), 
		 .sram_dq_io(sram_dq_io),

		 // from video sync
		 .pixel_x_i(pixel_x), 
		 .pixel_y_i(pixel_y), 
		 .p_tick_i(p_tick),

		 .clk(clk),
		 .reset(reset)
		);

	// instantiate palette table (8-bit to 12-bit conversion)
	palette palette
		(.color_i(vga_readdata), 
		 .color_o(color)
		);

	//=======================================================================
	// registers, write decoding, and read multiplexing
	//=======================================================================
	// delay vga sync to accomodate memory access
	always @(posedge clk)
		begin
			vsync_reg <= vsync;
			hsync_reg <= hsync;
			video_on_reg <= video_on;
		end

	// delay pixel_x and pixel_y readdata by one cycle and assert readdatavalid
	always @(posedge clk)
		begin
			pixel_x_reg <= pixel_x;
			pixel_y_reg <= pixel_y;
		end

	always @(posedge clk, posedge reset)
		if (reset)
			pixel_read_reg <= 1'b0;
		else
			pixel_read_reg <= read_i & chipselect_i & address_i[19];

	assign readdatavalid_o = rd_data_valid_vram | pixel_read_reg;

	// memory read/write decoding
	assign wr_vram = write_i & chipselect_i & ~address_i[19];
	assign rd_vram = read_i & chipselect_i & ~address_i[19];

	// read data mux
	assign readdata_o = ~pixel_read_reg ? {24'b0, cpu_readdata} :
	                                      {12'b0, pixel_y_reg, pixel_x_reg};
	// video output
	assign rgb_o = video_on_reg ? color : 12'b0;
	assign vsync_o = vsync_reg;
	assign hsync_o = hsync_reg;
endmodule
