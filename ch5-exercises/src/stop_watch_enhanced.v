module stop_watch_enhanced
	(
		input wire iCLK,
		input wire iGO, iCLR, iUP,
		output wire [3:0] oD3, oD2, oD1, oD0
	);

	// 0.1 sec tick generator
	localparam DVSR = 5000000;
	wire ms_tick;	
	mod_m_counter #(.SIZE(DVSR)) ms_tick_gen
		(.iCLK(iCLK), .iRESET(iCLR), .iEN(1'b1),
		 .oCNT(), .oTICK(ms_tick));

	// parameter declarations
	reg [3:0] d3_reg, d2_reg, d1_reg, d0_reg;
	reg [3:0] d3_next, d2_next, d1_next, d0_next;

	// body
	// register
	always @(posedge iCLK)
	begin
		d3_reg <= d3_next;
		d2_reg <= d2_next;
		d1_reg <= d1_next;
		d0_reg <= d0_next;
	end

	// 3-digit bcd counter
	always @*
	begin
		// default: keep the previous value
		d0_next = d0_reg;
		d1_next = d1_reg;
		d2_next = d2_reg;
		d3_next = d3_reg;
		if (iCLR)
			begin
				d0_next = 4'b0;
				d1_next = 4'b0;
				d2_next = 4'b0;
				d3_next = 4'b0;
			end
		else if (iGO) 
			if (ms_tick && iUP)
				if (d0_reg != 9)
					d0_next = d0_reg + 1;
				else
					begin
						d0_next = 4'b0;
						if (d1_reg != 9)
							d1_next = d1_reg + 1;
						else
							begin
								d1_next = 4'b0;
								if (d2_reg != 5)
									d2_next = d2_reg + 1;
								else
									begin
										d2_next = 4'b0;
										if (d3_reg != 9)
											d3_next = d3_reg + 1;
										else
											d3_next = 4'b0;
									end
							end
					end
			else if (ms_tick && ~iUP)
				if (d0_reg != 0)
					d0_next = d0_reg - 1;
				else
					begin
						d0_next = 4'd9;
						if (d1_reg != 0)
							d1_next = d1_reg - 1;
						else
							begin
								d1_next = 4'd9;
								if (d2_reg != 0)
									d2_next = d2_reg - 1;
								else
									begin
										d2_next = 4'd5;
										if (d3_reg != 0)
											d3_next = d3_reg - 1;
										else
											d3_next = 4'd9;
									end
							end
					end
	end

	// output logic
	assign oD0 = d0_reg;
	assign oD1 = d1_reg;
	assign oD2 = d2_reg;
	assign oD3 = d3_reg;
endmodule
