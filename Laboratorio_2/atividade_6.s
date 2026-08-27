	lw x11, HIGH
	lw x12, LOW
loop:
	lb x10, 1026(x0)
	andi x10, x10, 1
	beq x10, x0, off
on:
	sb x11, 1029(x0)
	slli x11, x11, 1
	jal x0, loop
off:
	sb x12, 1029(x0)
	jal x0, loop

HIGH: .byte 1
LOW:  .byte 0

