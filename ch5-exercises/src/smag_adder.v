module smag_adder
	#(
		parameter N = 4
	)
	(
		input wire [N-1:0] iA, iB,
		output reg [N-1:0] oSUM
	);

	// signal declaration
	reg [N-2:0] mag_a, mag_b, mag_sum, max, min;
	reg sign_a, sign_b, sign_sum;

	// body
	always @*
	begin
		// separate magnitude and sign
		mag_a = iA[N-2:0];
		mag_b = iB[N-2:0];
		sign_a = iA[N-1];
		sign_b = iB[N-1];
		// sort according to magnitude
		if (mag_a > mag_b)
			begin
				max = mag_a;
				min = mag_b;
				sign_sum = sign_a;
			end
		else
			begin
				max = mag_b;
				min = mag_a;
				sign_sum = sign_b;
			end
		// add/subtract magnitude
		if (sign_a == sign_b)
			mag_sum = max + min;
		else
			mag_sum = max - min;
		// form output
		oSUM = {sign_sum, mag_sum};
	end
endmodule
