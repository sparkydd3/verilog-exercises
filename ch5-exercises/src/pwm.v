module pwm
	(
		input wire iClk, iReset, iEn,
		input wire [3:0] iW,
		output wire oPWM
	);

	reg [3:0] cnt_reg, cnt_next;
	reg [3:0] w_reg, w_next;
	reg pwm_reg, pwm_next;

	always @(posedge iClk, posedge iReset)
		if (iReset)
			begin
				cnt_reg <= 4'b1111;
				w_reg   <= 4'b1111;
				pwm_reg <= 4'b0;
			end
		else
			begin
				cnt_reg <= cnt_next;
				w_reg   <= w_next;
				pwm_reg <= pwm_next;
			end
	
	always @*
	if (iEn)
		begin
			cnt_next = (cnt_reg == 4'b1111) ? 0    : cnt_next + 1;
			w_next   = (cnt_reg == 4'b1111) ? iW   : w_reg;
			pwm_next = (cnt_next == w_next) ? 1'b0 :
			           (cnt_next == 4'b0)   ? 1'b1 :
					    pwm_reg;
		end
	else
		begin
			cnt_next = cnt_reg;
			w_next   = w_reg;
			pwm_next = pwm_reg;
		end
endmodule
