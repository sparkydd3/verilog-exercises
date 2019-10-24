module vga_sync
	(
		output wire [9:0] o_pixel_x, 
		output wire [9:0] o_pixel_y,
		output wire o_hsync, 
		output wire o_vsync, 
		output wire o_video_on, 
		output wire o_p_tick,
		input wire i_clk, 
		input wire i_reset
	);

	// constant declaration
	// VGA 640-by-480 sync parameters
	localparam HD = 640;	// horizontal display area
	localparam HF = 16 ;	// horizontal front porch
	localparam HB = 48 ;	// horizontal back porch
	localparam HR = 96 ;	// horizontal retrace
	localparam VD = 480;	// vertical display area
	localparam VF = 10 ;	// vertical front porch
	localparam VB = 33 ;	// vertical back porch
	localparam VR = 2  ;	// vertical retrace

	// mod-2 counter
	reg mod2_reg;

	// sync counters
	reg [9:0] h_count_reg, h_count_next;
	reg [9:0] v_count_reg, v_count_next;
	// status signal
	wire h_end, v_end, pixel_tick;

	// body
	// registers
	always @(posedge i_clk, posedge i_reset)
		if (i_reset)
			begin
				mod2_reg <= 1'b0;
				v_count_reg <= 0;
				h_count_reg <= 0;
			end
		else
			begin
				mod2_reg <= ~mod2_reg;
				v_count_reg <= v_count_next;
				h_count_reg <= h_count_next;
			end

	// mod-2 circuit to generate 25 MHz enable tick
	assign pixel_tick = mod2_reg;

	// status signals
	// end of horizontal counter (799)
	assign h_end = (h_count_reg == (HD + HF + HB + HR - 1));
	// end of vertical counter (524)
	assign v_end = (v_count_reg == (VD + VF + VB + VR - 1));
	
	// next-state logic of mod-800 horizontal sync counter
	always @*
		if (pixel_tick)	// 25 MHz pulse
			if (h_end)
				h_count_next = 0;
			else
				h_count_next = h_count_reg + 1;
		else
			h_count_next = h_count_reg;

	// next-state logic of mod-525 vertical sync counter
	always @*
		if (pixel_tick & h_end)
			if (v_end)
				v_count_next = 0;
			else
				v_count_next = v_count_reg + 1;
		else
			v_count_next = v_count_reg;
	
	// h_sync
	assign o_hsync = h_count_reg < (HD + HF) || h_count_reg > (HD + HF + HR - 1);
	// v_sync
	assign o_vsync = v_count_reg < (VD + VF) || v_count_reg > (VD + VF + VR - 1);

	// video on/off
	assign o_video_on = (h_count_reg < HD) && (v_count_reg < VD);

	// output
	assign o_pixel_x = h_count_reg;
	assign o_pixel_y = v_count_reg;
	assign o_p_tick = pixel_tick;
endmodule
