module debounce_test_mealy
	(
		input wire CLOCK_50,
		input wire [0:0] SW,
		input wire [0:0] KEY,
		output wire [6:0] HEX3, HEX2, HEX1, HEX0
	);

	// signal declaration
	reg [7:0] b_reg, d_reg;
	wire [7:0] b_next, d_next;
	reg sw_reg, db_reg;
	wire clk, db_level, db_tick, sw_tick, reset;

	assign clk = CLOCK_50;
	assign reset = ~KEY[0];

	// instantiate debouncing circuit
	db_fsm db_unit
		(.iCLK(clk), .iRESET(reset), .iSW(SW[0]), .oDB(db_level));
	// instantiate four instances of 7-seg LED decoders
	bin2sseg disp_unit_0
		(.iBIN(d_reg[3:0]), .oSSEG(HEX0));
	bin2sseg disp_unit_1
		(.iBIN(d_reg[7:4]), .oSSEG(HEX1));
	bin2sseg disp_unit_2
		(.iBIN(b_reg[3:0]), .oSSEG(HEX2));
	bin2sseg disp_unit_3
		(.iBIN(b_reg[7:4]), .oSSEG(HEX3));

	// edge detection circuits
	dedge_det_mealy sw_det
		(.iCLK(clk), .iRESET(reset), .iLEVEL(SW[0]), .oTICK(sw_tick));
	dedge_det_mealy db_det
		(.iCLK(clk), .iRESET(reset), .iLEVEL(db_level), .oTICK(db_tick));

	// two counters
	always @(posedge clk)
		begin
			b_reg <= b_next;
			d_reg <= d_next;
		end
	assign b_next = (reset)      ? 8'b0 :
	                (sw_tick) ? b_reg + 1 : b_reg;
	assign d_next = (reset)      ? 8'b0 :
	                (db_tick)  ? d_reg + 1 : d_reg;
endmodule
