# generate table of results for 8-bit signed magnitude addition

width = 8
f = open("smag_rom_adder8.txt", "w")

for i in range(2**(2*width)):
	bin_str = bin(i)
	bin_str = bin_str[2:]				# strip leading 0b
	bin_str = bin_str.zfill(2*width)
	
	(a_str, b_str) = (bin_str[:width], bin_str[width:])
	(a_sign, b_sign) = map(lambda x: 1 if x == "0" else -1, (a_str[0], b_str[0]))
	(a_mag, b_mag) = map(lambda x: int(x, 2), (a_str[1:], b_str[1:]))
	
	res_dec = a_sign * a_mag + b_sign * b_mag
	res_sign = "0" if res_dec > 0 else "0" if res_dec == 0 and a_sign == 1 else "1"
	
	res_mag = bin(abs(res_dec))
	res_mag = res_mag[2:]				# strip leading 0b
	res_mag = res_mag.zfill(width-1)
	res_mag = res_mag[-(width-1):]
	
	f.write("{}\n".format(res_sign + res_mag))

f.close()
