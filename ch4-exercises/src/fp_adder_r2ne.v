module fp_adder_r2ne
	(
		input wire iSign1, iSign2,
		input wire [3:0] iExp1, iExp2,
		input wire [7:0] iFrac1, iFrac2,
		output reg oSign,
		output reg [3:0] oExp,
		output reg [7:0] oFrac
	);
	
	// signal declaration
	// suffix b, s, a, n for
	//        big, small, aligned, normalized number
	reg signb, signs;
	reg [3:0] expb, exps, expn, exp_diff;
	reg [7:0] fracb, fracs, fraca, fracn, sum_norm;
	reg [15:0] _fraca;
	reg [8:0] sum;
	reg [2:0] lead0;

	// body
	always @*
	begin
		// 1st stage: sort to find the largest number
		if ({iExp1, iFrac1} > {iExp2, iFrac2})
			begin
				signb = iSign1;
				signs = iSign2;
				expb = iExp1;
				exps = iExp2;
				fracb = iFrac1;
				fracs = iFrac2;
			end
		else
			begin
				signb = iSign2;
				signs = iSign1;
				expb = iExp2;
				exps = iExp1;
				fracb = iFrac2;
				fracs = iFrac1;
			end

		// 2nd stage: align smaller number, round to nearest even
		exp_diff = expb - exps;
		_fraca = {fracs, 8'd0};
		_fraca = _fraca >> exp_diff;
		fraca = _fraca[15:8];
		
		// if bit after cutoff is 1 and bits remaining, round up
		// if bit after cutoff is 1 and no bits remaining, round down
		fraca = (_fraca[7] & (|_fraca[6:0])) ? fraca + 8'd1 : fraca;

		// 3rd stage: add/subtract
		if (signb == signs)
			sum = {1'b0, fracb} + {1'b0, fraca};
		else
			sum = {1'b0, fracb} - {1'b0, fraca};

		// 4th stage: normalize
		// count leading 0s
		if (sum[7])
			lead0 = 3'o0;
		else if (sum[6])
			lead0 = 3'o1;
		else if (sum[5])
			lead0 = 3'o2;
		else if (sum[4])
			lead0 = 3'o3;
		else if (sum[3])
			lead0 = 3'o4;
		else if (sum[2])
			lead0 = 3'o5;
		else if (sum[1])
			lead0 = 3'o6;
		else
			lead0 = 3'o7;
		
		// shift significand according to leading 0
		sum_norm = sum << lead0;
		// normalize with special conditions
		if (sum[8])		// with carry out; shift frac to right
			begin
				expn = expb + 1;
				fracn = sum[8:1];
			end
		else if (lead0 > expb)	// too small to normalize
			begin
				expn = 0;		// set to 0
				fracn = 0;
			end
		else
			begin
				expn = expb - lead0;
				fracn = sum_norm;
			end

		// form output
		oSign = signb;
		oExp = expn;
		oFrac = fracn;
	end
endmodule
