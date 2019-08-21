module bin2sseg
	(
		input wire [3:0] iBin,
		output reg [6:0] oSseg	// output active low
	);

	always @*
	begin
		case(iBin)
			4'h0: oSseg = 7'b1000000;
			4'h1: oSseg = 7'b1111001;
			4'h2: oSseg = 7'b0100100;
			4'h3: oSseg = 7'b0110000;
			4'h4: oSseg = 7'b0011001;
			4'h5: oSseg = 7'b0010010;
			4'h6: oSseg = 7'b0000010;
			4'h7: oSseg = 7'b1111000;
			4'h8: oSseg = 7'b0000000;
			4'h9: oSseg = 7'b0010000;
			4'ha: oSseg = 7'b0001000;
			4'hb: oSseg = 7'b0000011;
			4'hc: oSseg = 7'b1000110;
			4'hd: oSseg = 7'b0100001;
			4'he: oSseg = 7'b0000110;
			default: oSseg = 7'b0001110;	// 4'hf
		endcase
	end
endmodule
