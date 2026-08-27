	lw x11, HIGH
	lw x12, LOW
	lw x13, number
loop:
	lb x10, 1026(x0)
	andi x10, x10, 1 
on:
	sb x11, 1029(x0)
	lb x10, 1026(x0)
	beq x10, x13, off
	jal x0, on
off:
	slli x11, x11, 1
	sb x12, 1029(x0)
	jal x0, loop

HIGH: .byte 1
LOW:  .byte 0
number: .byte 1
