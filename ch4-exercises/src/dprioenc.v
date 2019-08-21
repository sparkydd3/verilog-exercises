module dprioenc
	(
		input wire [11:0] iReq,
		output reg [3:0] oFirst, oSecond
	);

	reg [11:0] req_slice;

	always @*
	begin
		casex(iReq)
			12'b1xxx_xxxx_xxxx : {oFirst, req_slice} = {4'd12, 1'd0,  iReq[10:0]};
			12'b01xx_xxxx_xxxx : {oFirst, req_slice} = {4'd11, 2'd0,  iReq[9:0]};
			12'b001x_xxxx_xxxx : {oFirst, req_slice} = {4'd10, 3'd0,  iReq[8:0]};
			12'b0001_xxxx_xxxx : {oFirst, req_slice} = {4'd9,  4'd0,  iReq[7:0]};
			12'b0000_1xxx_xxxx : {oFirst, req_slice} = {4'd8,  5'd0,  iReq[6:0]};
			12'b0000_01xx_xxxx : {oFirst, req_slice} = {4'd7,  6'd0,  iReq[5:0]};
			12'b0000_001x_xxxx : {oFirst, req_slice} = {4'd6,  7'd0,  iReq[4:0]};
			12'b0000_0001_xxxx : {oFirst, req_slice} = {4'd5,  8'd0,  iReq[3:0]};
			12'b0000_0000_1xxx : {oFirst, req_slice} = {4'd4,  9'd0,  iReq[2:0]};
			12'b0000_0000_01xx : {oFirst, req_slice} = {4'd3,  10'd0, iReq[1:0]};
			12'b0000_0000_001x : {oFirst, req_slice} = {4'd2,  11'd0, iReq[0]};
			12'b0000_0000_0001 : {oFirst, req_slice} = {4'd1,  12'd0};
			default:             {oFirst, req_slice} = {4'd0,  12'd0};
		endcase

		casex(req_slice)
			12'b01xx_xxxx_xxxx : oSecond = 4'd11;
			12'b001x_xxxx_xxxx : oSecond = 4'd10;
			12'b0001_xxxx_xxxx : oSecond = 4'd9;
			12'b0000_1xxx_xxxx : oSecond = 4'd8;
			12'b0000_01xx_xxxx : oSecond = 4'd7;
			12'b0000_001x_xxxx : oSecond = 4'd6;
			12'b0000_0001_xxxx : oSecond = 4'd5;
			12'b0000_0000_1xxx : oSecond = 4'd4;
			12'b0000_0000_01xx : oSecond = 4'd3;
			12'b0000_0000_001x : oSecond = 4'd2;
			12'b0000_0000_0001 : oSecond = 4'd1;
			default:             oSecond = 4'd0;
		endcase
	end
endmodule
