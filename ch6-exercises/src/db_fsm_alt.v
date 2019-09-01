module db_fsm_alt
	(
		input wire iCLK, iRESET,
		input wire iSW,
		output reg oDB
	);

	wire ms_tick;
	mod_m_counter #(.SIZE(50000)) ms_cnt
		(.iCLK(iCLK), .iRESET(iRESET), .iEN(1'b1),
		 .oCNT(), .oTICK(ms_tick));

	localparam [2:0]
		zero    = 3'b000,
		wait1_1 = 3'b001,
		wait1_2 = 3'b010,
		wait1_3 = 3'b011,
		one     = 3'b100,
		wait0_1 = 3'b101,
		wait0_2 = 3'b110,
		wait0_3 = 3'b111;

	reg [2:0] state_reg, state_next;

	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			state_reg <= zero;
		else
			state_reg <= state_next;

	always @*
	begin
		state_next = state_reg;
		case (state_reg)
			zero:
				begin
					oDB = 1'b0;
					if (iSW)
						state_next = wait1_1;
				end
			wait1_1:
				begin
					oDB = 1'b1;
					if (ms_tick)
						state_next = wait1_2;
				end
			wait1_2:
				begin
					oDB = 1'b1;
					if (ms_tick)
						state_next = wait1_3;
				end
			wait1_3:
				begin
					oDB = 1'b1;
					if (ms_tick)
						state_next = one;
				end
			one:
				begin
					oDB = 1'b1;
					if (~iSW)
						state_next = wait0_1;
				end
			wait0_1:
				begin
					oDB = 1'b0;
					if (ms_tick)
						state_next = wait0_2;
				end
			wait0_2:
				begin
					oDB = 1'b0;
					if (ms_tick)
						state_next = wait0_3;
				end
			wait0_3:
				begin
					oDB = 1'b0;
					if (ms_tick)
						state_next = zero;
				end
		endcase
	end
endmodule
