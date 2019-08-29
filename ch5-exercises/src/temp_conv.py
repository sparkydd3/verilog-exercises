# generate table of celcius to farenheit conversion 
# (0-100 C) 
# (32 - 212 F)

fw = open("temp_conv.txt", "w")

for c in range(2**8-1):
	if c > 100:
		fw.write("00000000\n")
		continue

	f_res = int(9.0 / 5.0 * c + 32.0)
	f_str = bin(f_res)
	f_str = f_str[2:]
	f_str = f_str.zfill(8)
	
	fw.write("{}\n".format(f_str))

for f in range(2**8-1):
	if f > 212 or f < 32:
		fw.write("00000000\n")
		continue
	
	c = int((f - 32.0) * 5.0 / 9.0)
	c_str = bin(c)
	c_str = c_str[2:]
	c_str = c_str.zfill(8)

	fw.write("{}\n".format(c_str))

fw.close()
