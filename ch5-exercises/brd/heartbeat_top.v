module heartbeat_top
	(
		input wire CLOCK_50,
		input wire [0:0] KEY,
		output reg [6:0] HEX3, HEX2, HEX1, HEX0
	);

	wire reset, clk, tick;
	assign reset = ~KEY[0];

	localparam DVSR = 8333333;	// 6 Hz tick		
	mod_m_counter #(.SIZE(DVSR)) tick_gen
		(.iCLK(CLOCK_50), .iRESET(reset), .iEN(1'b1),
		 .oCNT(), .oTICK(tick));

	wire [2:0] hb;
	heartbeat hb_unit
		(.iCLK(CLOCK_50), .iRESET(reset), .iEN(tick),
		 .oHB(hb));

	always @*
	begin
		HEX3 = 7'b1111111;
		HEX2 = 7'b1111111;
		HEX1 = 7'b1111111;
		HEX0 = 7'b1111111;

		if (hb == 3'b001) begin
			HEX2 = 7'b1111001;
			HEX1 = 7'b1001111;
		end
		else if (hb == 3'b010) begin
			HEX2 = 7'b1001111;
			HEX1 = 7'b1111001;
		end
		else if (hb == 3'b100) begin
			HEX3 = 7'b1001111;
			HEX0 = 7'b1111001;
		end
	end
endmodule
