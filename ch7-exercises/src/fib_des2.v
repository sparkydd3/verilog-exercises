module fib_des2
	(
		input wire iCLK, iRESET,
		input wire iSTART,
		input wire [3:0] iBCD3, iBCD2, iBCD1, iBCD0,
		output wire oREADY, oDONE, oOFLOW,
		output wire [3:0] oBCD3, oBCD2, oBCD1, oBCD0
	);
	
	localparam [1:0]
		idle = 2'b00,
		proc = 2'b01,
		done = 2'b10;
	
	reg [1:0] state_reg, state_next;
	reg [7:0] cnt_reg;
	reg [7:0] cnt_next;
	reg [15:0] t0_reg, t1_reg; 
	reg [15:0] t0_next, t1_next; 
	reg overflow_reg, overflow_next;
	reg ready_next, done_next;

	wire [7:0] cnt_dec;
	wire [15:0] t_sum;
	wire [4:0] t_sum3, t_sum2, t_sum1, t_sum0;

	always @(posedge iCLK, posedge iRESET)
		if (iRESET)
			begin
				cnt_reg <= {4'd0, 4'd0};
				t0_reg <= {4'd0, 4'd0, 4'd0, 4'd0};
				t1_reg <= {4'd0, 4'd0, 4'd0, 4'd0};
				state_reg <= idle;
				overflow_reg <= 1'b0;
			end
		else
			begin
				cnt_reg <= cnt_next;
				t0_reg <= t0_next;
				t1_reg <= t1_next;
				state_reg <= state_next;
				overflow_reg <= overflow_next;
			end
	
	always @*
	begin
		cnt_next = cnt_reg;
		t0_next = t0_reg;
		t1_next = t1_reg;
		state_next = state_reg;
		overflow_next = overflow_reg;
		ready_next = 1'b0;
		done_next = 1'b0;

		case (state_reg)
			idle:
				begin
					ready_next = 1'b1;
					if (iSTART)
						if (iBCD3 > 0 || iBCD2 > 0 || {iBCD1, iBCD0} > {4'd2, 4'd0})
							begin
								t1_next = {4'd9, 4'd9, 4'd9, 4'd9};
								overflow_next = 1'b1;
								state_next = done;
							end
						else
							begin
								t1_next = {4'd0, 4'd0, 4'd0, 4'd1};
								t0_next = {4'd0, 4'd0, 4'd0, 4'd0};
								cnt_next = {iBCD1, iBCD0};
								overflow_next = 1'b0;
								state_next = proc;
							end
				end
			proc:
				if (cnt_reg == {4'd0, 4'd0})
					begin
						t1_next = {4'd0, 4'd0, 4'd0, 4'd0};
						state_next = done;
					end
				else if (cnt_reg == {4'd0, 4'd1})
					begin
						state_next = done;
					end
				else
					begin
						t0_next = t1_reg;
						t1_next = t_sum;
						cnt_next = cnt_dec;
					end
			done:
				begin
					done_next = 1'b1;
					state_next = idle;
				end
		endcase
	end

	assign cnt_dec[3:0] = (cnt_reg[3:0] == 4'd0) ? 4'd9 : cnt_reg[3:0] - 1;
	assign cnt_dec[7:4] = (cnt_reg[3:0] == 4'd0) ? cnt_reg[7:4] - 1 : cnt_reg[7:4];

	assign t_sum0 = t0_reg[3:0] + t1_reg[3:0];
	assign t_sum1 = t0_reg[7:4] + t1_reg[7:4] + ((t_sum0 > 5'd9) ? 1 : 0);
	assign t_sum2 = t0_reg[11:8] + t1_reg[11:8] + ((t_sum1 > 5'd9) ? 1 : 0);
	assign t_sum3 = t0_reg[15:12] + t1_reg[15:12] + ((t_sum2 > 5'd9) ? 1 : 0);

	assign t_sum[3:0] = (t_sum0 > 5'd9) ? t_sum0 + 5'd6 : t_sum0;
	assign t_sum[7:4] = (t_sum1 > 5'd9) ? t_sum1 + 5'd6 : t_sum1;
	assign t_sum[11:8] = (t_sum2 > 5'd9) ? t_sum2 + 5'd6 : t_sum2;
	assign t_sum[15:12] = (t_sum3 > 5'd9) ? t_sum3 + 5'd6 : t_sum3;

	assign oDONE = done_next;
	assign oREADY = ready_next;
	assign oOFLOW = overflow_reg;

	assign oBCD3 = t1_reg[15:12];
	assign oBCD2 = t1_reg[11:8];
	assign oBCD1 = t1_reg[7:4];
	assign oBCD0 = t1_reg[3:0];
endmodule
