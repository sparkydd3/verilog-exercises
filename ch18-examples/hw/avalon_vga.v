module avalon_vga
	(
		// Avalon MM interface
		output wire [31:0] o_readdata,
		output wire o_readdatavalid,
		output wire o_waitrequest,
		input wire [19:0] i_address,
		input wire i_chipselect,
		input wire i_read, 
		input wire i_write,
		input wire [31:0] i_writedata,

		// conduit (to VGA monitor)
		output wire o_hsync,
		output wire o_vsync,
		output wire [11:0] o_rgb,

		// conduit (to/from SRAM)
		output wire [17:0] o_sram_addr,
		output wire o_sram_ub_n,
		output wire o_sram_lb_n, 
		output wire o_sram_ce_n, 
		output wire o_sram_oe_n, 
		output wire o_sram_we_n,
		inout wire [15:0] io_sram_dq,

		input wire i_clk, 
		input wire i_reset
	);
	
	// signal declaration
	wire video_on, o_video_on, vsync, hsync;
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
		(.o_hsync(hsync), 
		 .o_vsync(vsync),
		 .o_video_on(video_on), 
		 .o_p_tick(p_tick),
		 .o_pixel_x(pixel_x), 
		 .o_pixel_y(pixel_y),
		 .i_clk(i_clk),
		 .i_reset(i_reset)
		);

	// instantiate video SRAM control
	vram_ctrl vram_ctrl
		(// to video
		 .o_vga_readdata(vga_readdata), 
		 .o_hsync(o_hsync),
		 .o_vsync(o_vsync),
		 .o_video_on(o_video_on),

		 // avalon bus interface
		 .o_cpu_readdata(cpu_readdata),
		 .o_cpu_readdatavalid(rd_data_valid_vram), 
		 .o_cpu_waitrequest(o_waitrequest),
		 .i_cpu_address(i_address[18:0]),
		 .i_cpu_writedata(i_writedata[7:0]),
		 .i_cpu_read(rd_vram),
		 .i_cpu_write(wr_vram), 

		 // to/from SRAM chip
		 .o_sram_addr(o_sram_addr), 
		 .o_sram_ub_n(o_sram_ub_n), 
		 .o_sram_lb_n(o_sram_lb_n),
		 .o_sram_ce_n(o_sram_ce_n),	 
		 .o_sram_oe_n(o_sram_oe_n), 
		 .o_sram_we_n(o_sram_we_n), 
		 .io_sram_dq(io_sram_dq),

		 // from video sync
		 .i_pixel_x(pixel_x), 
		 .i_pixel_y(pixel_y), 
		 .i_p_tick(p_tick),
		 .i_hsync(hsync),
		 .i_vsync(vsync),
		 .i_video_on(video_on),

		 .i_clk(i_clk),
		 .i_reset(i_reset)
		);

	// instantiate palette table (8-bit to 12-bit conversion)
	palette palette
		(.i_color(vga_readdata), 
		 .o_color(color)
		);

	// delay pixel_x and pixel_y readdata by one cycle and assert readdatavalid
	always @(posedge i_clk)
		begin
			pixel_x_reg <= pixel_x;
			pixel_y_reg <= pixel_y;
		end

	always @(posedge i_clk, posedge i_reset)
		if (i_reset)
			pixel_read_reg <= 1'b0;
		else
			pixel_read_reg <= i_read & i_chipselect & i_address[19];

	assign o_readdatavalid = rd_data_valid_vram | pixel_read_reg;

	// memory read/write decoding
	assign wr_vram = i_write & i_chipselect & ~i_address[19];
	assign rd_vram = i_read & i_chipselect & ~i_address[19];

	// read data mux
	assign o_readdata = ~pixel_read_reg ? {24'b0, cpu_readdata} :
	                                      {12'b0, pixel_y_reg, pixel_x_reg};
	// video output
	assign o_rgb = o_video_on ? color : 12'b0;
endmodule
