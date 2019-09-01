module bin2sseg
	(
		input wire [3:0] iBIN,
		output reg [6:0] oSSEG	// output active low
	);

	always @*
	begin
		case(iBIN)
			4'h0: oSSEG = 7'b1000000;
			4'h1: oSSEG = 7'b1111001;
			4'h2: oSSEG = 7'b0100100;
			4'h3: oSSEG = 7'b0110000;
			4'h4: oSSEG = 7'b0011001;
			4'h5: oSSEG = 7'b0010010;
			4'h6: oSSEG = 7'b0000010;
			4'h7: oSSEG = 7'b1111000;
			4'h8: oSSEG = 7'b0000000;
			4'h9: oSSEG = 7'b0010000;
			4'ha: oSSEG = 7'b0001000;
			4'hb: oSSEG = 7'b0000011;
			4'hc: oSSEG = 7'b1000110;
			4'hd: oSSEG = 7'b0100001;
			4'he: oSSEG = 7'b0000110;
			default: oSSEG = 7'b0001110;	// 4'hf
		endcase
	end
endmodule
