module sw_gen
	(
		input wire iCLK, iRESET,
		input wire [3:0] iM, iN,
		output wire oSQ
	);

	// 100 ns tick generator
	localparam DVSR = 5;	// 100 ns tick, 20 ns clk
	wire tick;
	mod_m_counter #(.SIZE(DVSR)) mod_5_cnt
		(.iCLK(iCLK), .iRESET(iRESET), .iEN(1'b1),
		 .oCNT(), .oTICK(tick));

	// square wave generator
	reg [4:0] cnt_reg, cnt_next; 
	reg sq_reg, sq_next;

	always @(posedge iCLK, posedge iRESET) 
	if (iRESET) 
		begin
			cnt_reg <= 0;
			sq_reg <= 0;
		end
	else
		begin
			cnt_reg <= cnt_next;
			sq_reg <= sq_next;
		end

	// intended behavior
	// sq wave edge can only occur on tick
	// m == 0 && n == 0: maintain previous level
	// m == 0: maintain sq = 1'b1
	// n == 0: maintain sq = 1'b0
	// m > 0 && n > 0: normal sq wave operation

	always @*
	if (tick)
		begin
			cnt_next = cnt_reg;
			sq_next = sq_reg;

			if (cnt_reg != 0)
				cnt_next = cnt_reg - 1;
			else if (sq_reg == 1'b0 && iM != 0)
				begin
					sq_next = 1'b1;
					cnt_next = iM - 1;
				end
			else if (sq_reg == 1'b1 && iN != 0)
				begin
					sq_next = 1'b0;
					cnt_next = iN - 1;
				end
		end
	else
		begin
			cnt_next = cnt_reg;
			sq_next = sq_reg;
		end

	assign oSQ = sq_reg;
endmodule
