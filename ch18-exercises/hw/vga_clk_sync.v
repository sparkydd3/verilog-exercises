module vga_clk_sync
	(
		output wire [9:0] o_pixel_x, 
		output wire [9:0] o_pixel_y,
		output wire o_hsync, 
		output wire o_vsync, 
		output wire o_video_on, 

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

	// sync counters
	reg [9:0] h_count_reg, v_count_reg;
	// status signal
	wire h_end, v_end, pixel_tick;

	// body
	always @(posedge i_clk, posedge i_reset)
		if (i_reset)
			begin
				v_count_reg <= 0;
				h_count_reg <= 0;
			end
		else
			if (h_end)
				begin
					h_count_reg <= 0;

					if (v_end)
						v_count_reg <= 0;
					else
						v_count_reg <= v_count_reg + 1;
				end
			else
				h_count_reg <= h_count_reg + 1;
		
	// status signals
	// end of horizontal counter (799)
	assign h_end = (h_count_reg == (HD + HF + HB + HR - 1));
	// end of vertical counter (524)
	assign v_end = (v_count_reg == (VD + VF + VB + VR - 1));
	
	// h_sync
	assign o_hsync = h_count_reg < (HD + HF) || h_count_reg > (HD + HF + HR - 1);
	// v_sync
	assign o_vsync = v_count_reg < (VD + VF) || v_count_reg > (VD + VF + VR - 1);

	// video on/off
	assign o_video_on = (h_count_reg < HD) && (v_count_reg < VD);

	// output
	assign o_pixel_x = h_count_reg;
	assign o_pixel_y = v_count_reg;
endmodule
