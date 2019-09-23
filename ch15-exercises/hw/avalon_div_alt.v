module avalon_div_alt
	#(
		parameter W = 32,
		CBIT = $clog2(W) + 1
	)
	(
		// to be connected to Avalon clock input interface
		input wire clk, reset,
		// to be connected to Avalon MM slave interface
		input wire [2:0] div_address,
		input wire div_chipselect,
		input wire div_write,
		input wire [W-1:0] div_writedata,
		output wire [W-1:0] div_readdata,
		// to be connected to interrupt sender interface
		output wire div_irq,
		// to be connected to Avalon conduit interface
		output wire [7:0] div_led
	);

	// signal declaration
	wire div_start, div_ready, set_done_tick, clr_done_tick;
	wire [W-1:0] dvsr_wire;
	reg [W-1:0] dvnd_reg;
	reg done_tick_reg;
	wire [W-1:0] quo, rmd;
	wire wr_en, wr_dvnd, wr_dvsr;

	//body
	//===============================================================
	// instantiate division circuit	
	//===============================================================
	div #(.W(W)) d_unit
		(.iCLK(clk), .iRESET(reset),
		 .iSTART(div_start),
		 .iDVND(dvnd_reg), .iDVSR(dvsr_wire),
		 .oQUO(quo), .oRMD(rmd),
		 .oREADY(div_ready), .oDONE(set_done_tick));
	
	//===============================================================
	// register, write encoding, and read multiplexing
	//===============================================================
	// registers
	always @(posedge clk, posedge reset)
		if (reset)
			begin
				dvnd_reg <= 0;
				done_tick_reg <= 1'b0;
			end
		else
			begin
				if (wr_dvnd) 
					dvnd_reg <= div_writedata;

				if (set_done_tick)
					done_tick_reg <= 1'b1;
				else if (clr_done_tick)
					done_tick_reg <= 1'b0;
			end
	// write decoding logic
	assign wr_en = div_write & div_chipselect;
	assign wr_dvnd = (div_address == 3'b000) & wr_en;
	assign div_start = (div_address == 3'b001) & wr_en;
	assign dvsr_wire = (div_address == 3'b001) & wr_en ? div_writedata : 0;
	assign clr_done_tick = (div_address== 3'b101) & wr_en;
	
	// read multiplexing logic
	assign div_readdata = (div_address == 3'b010) ? quo :
	                      (div_address == 3'b011) ? rmd :
						  (div_address == 3'b100) ? {31'b0, div_ready} :
						                            {31'b0, done_tick_reg};

	// conduit signals
	assign div_led = rmd[7:0];	// assume that W > 7

	// interrupt signals
	assign div_irq = done_tick_reg;
endmodule
