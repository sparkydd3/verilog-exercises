module parking_lot_counter
	(
		input wire iCLK, iRESET,
		input wire iA, iB,
		output reg oENTER, oEXIT, oERROR
	);
	
	localparam [3:0]
		idle    = 4'b0000,
		enter_0 = 4'b0001,
		enter_1 = 4'b0010,
		enter_2 = 4'b0011,
		entered = 4'b0100,
		exit_0  = 4'b0101,
		exit_1  = 4'b0110,
		exit_2  = 4'b0111,
		exited  = 4'b1000,
		error   = 4'b1001;

	reg [3:0] state_reg, state_next;

	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			state_reg <= idle;
		else
			state_reg <= state_next;

	always @*
	begin
		state_next = state_reg;
		oENTER = 1'b0;
		oEXIT = 1'b0;
		oERROR = 1'b0;

		case (state_reg)
			idle:
				case ({iA, iB})
					2'b01 : state_next = exit_0;
					2'b10 : state_next = enter_0;
					2'b11 : state_next = error;
				endcase
			enter_0:
				case ({iA, iB})
					2'b00 : state_next = idle; 
					2'b01 : state_next = error;
					2'b11 : state_next = enter_1;
				endcase
			enter_1:
				case ({iA, iB})
					2'b00 : state_next = error; 
					2'b01 : state_next = enter_2;
					2'b10 : state_next = enter_0;
				endcase
			enter_2:
				case ({iA, iB})
					2'b00 : state_next = entered; 
					2'b10 : state_next = error;
					2'b11 : state_next = enter_1;
				endcase
			entered:
				begin
					oENTER = 1'b1;
					state_next = idle;
				end
			exit_0:
				case ({iA, iB})
					2'b00 : state_next = idle; 
					2'b10 : state_next = error;
					2'b11 : state_next = exit_1;
				endcase
			exit_1:
				case ({iA, iB})
					2'b00 : state_next = error; 
					2'b01 : state_next = exit_0;
					2'b10 : state_next = exit_2;
				endcase
			exit_2:
				case ({iA, iB})
					2'b00 : state_next = exited; 
					2'b01 : state_next = error;
					2'b11 : state_next = exit_1;
				endcase
			exited:
				begin
					oEXIT = 1'b1;
					state_next = idle;
				end
			error:
				begin
					oERROR = 1'b1;
					state_next = idle;
				end
			default:
				begin
					oERROR = 1'b1;
					state_next = idle;
				end
		endcase
	end
endmodule
