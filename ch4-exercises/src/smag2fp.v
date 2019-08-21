module smag2fp
	(
		input wire [7:0] iSmag,
		output reg [12:0] oFp
	);

	reg [11:0] fp_mag;

	always @*
	begin
		casex(iSmag[6:0])
			7'b1xxxxxx: fp_mag = {4'd7, iSmag[6:0], 1'b0};
			7'b01xxxxx: fp_mag = {4'd6, iSmag[5:0], 2'b0}; 
			7'b001xxxx: fp_mag = {4'd5, iSmag[4:0], 3'b0}; 
			7'b0001xxx: fp_mag = {4'd4, iSmag[3:0], 4'b0}; 
			7'b00001xx: fp_mag = {4'd3, iSmag[2:0], 5'b0}; 
			7'b000001x: fp_mag = {4'd2, iSmag[1:0], 6'b0}; 
			7'b0000001: fp_mag = {4'd1, iSmag[0:0], 7'b0}; 
			default:    fp_mag = {12{1'b0}};
		endcase

		oFp[12] = iSmag[7];	// sign bit
		oFp[11:0] = fp_mag;
	end
endmodule
