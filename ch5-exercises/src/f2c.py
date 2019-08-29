# generate table of farenheit to celsius conversion (32-212 F) 

fw = open("f2c.txt", "w")

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
