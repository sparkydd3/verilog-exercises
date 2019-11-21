module avalon_vga_3_bit_color_dbuffer
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
		input wire i_cpu_clk,
		input wire i_cpu_reset,

		// conduit (to/from SRAM)
		output wire [17:0] o_sram_addr,
		output wire o_sram_ub_n,
		output wire o_sram_lb_n, 
		output wire o_sram_ce_n, 
		output wire o_sram_oe_n, 
		output wire o_sram_we_n,
		inout wire [15:0] io_sram_dq,

		// conduit (to VGA monitor)
		output wire o_vga_hsync,
		output wire o_vga_vsync,
		output wire [11:0] o_vga_rgb,
		input wire i_vga_clk,
		input wire i_vga_reset
	);
	
	// signal declaration
	wire video_on, vsync, hsync;
	wire [9:0] pixel_x, pixel_y;

	wire vga_video_on; 
	wire wr_vram, rd_vram, rd_data_valid_vram, sw_vram;

	wire [3:0] cpu_readdata, vga_readdata;
	wire [11:0] color;

	// body
	//=======================================================================
	// instantiation
	//=======================================================================
	// instantiate VGA sync circuit
	vga_clk_sync vga_clk_sync
		(.o_hsync(hsync), 
		 .o_vsync(vsync),
		 .o_video_on(video_on), 
		 .o_pixel_x(pixel_x), 
		 .o_pixel_y(pixel_y),

		 .i_clk(i_vga_clk),
		 .i_reset(i_vga_reset)
		);

	// instantiate video SRAM control
	vram_3_bit_color_dbuffer_ctrl vram_3_bit_color_dbuffer_ctrl 
		(// to video
		 .o_vga_readdata(vga_readdata), 
		 .o_vga_hsync(o_vga_hsync),
		 .o_vga_vsync(o_vga_vsync),
		 .o_vga_video_on(vga_video_on),

		 // avalon bus interface
		 .o_cpu_readdata(cpu_readdata),
		 .o_cpu_readdatavalid(rd_data_valid_vram), 
		 .o_cpu_waitrequest(o_waitrequest),
		 .i_cpu_address(i_address[18:0]),
		 .i_cpu_writedata(i_writedata[3:0]),
		 .i_cpu_switch_dbuffer(sw_vram),
		 .i_cpu_read(rd_vram),
		 .i_cpu_write(wr_vram), 
		 .i_cpu_clk(i_cpu_clk),
		 .i_cpu_reset(i_cpu_reset),

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
		 .i_hsync(hsync),
		 .i_vsync(vsync),
		 .i_video_on(video_on),
		 .i_vga_clk(i_vga_clk),
		 .i_vga_reset(i_vga_reset)
		);

	// instantiate palette table (3-bit to 12-bit conversion)
	palette_3_bit_color palette_3_bit_color
		(.i_color(vga_readdata), 
		 .o_color(color)
		);

	// 2-FF synchronizer from vga clock domain
	reg [9:0] q1_pixel_x, q2_pixel_x;
	reg [9:0] q1_pixel_y, q2_pixel_y;
	always @(posedge i_cpu_clk, posedge i_cpu_reset)
		if (i_cpu_reset)
			begin
				{q2_pixel_x, q1_pixel_x} <= 0;
				{q2_pixel_y, q1_pixel_y} <= 0;
			end
		else
			begin
				{q2_pixel_x, q1_pixel_x} <= {q1_pixel_x, pixel_x};
				{q2_pixel_y, q1_pixel_y} <= {q1_pixel_y, pixel_y};
			end

	// assert readdatavalid 1 cycle after pixel read command 
	reg pixel_read_reg;
	always @(posedge i_cpu_clk, posedge i_cpu_reset)
		if (i_cpu_reset)
			pixel_read_reg <= 1'b0;
		else
			pixel_read_reg <= i_read & i_chipselect & i_address[19];

	assign o_readdatavalid = rd_data_valid_vram | pixel_read_reg;

	// memory read/write decoding
	assign wr_vram = i_write & i_chipselect & ~i_address[19];
	assign rd_vram = i_read & i_chipselect & ~i_address[19];
	assign sw_vram = i_write & i_chipselect & i_address[19];

	// read data mux
	assign o_readdata = ~pixel_read_reg ? {28'b0, cpu_readdata} :
	                                      {12'b0, q2_pixel_y, q1_pixel_x};
	// video output
	assign o_vga_rgb = vga_video_on ? color : 12'b0;
endmodule
