	lw x19, f
	lw x20, g
	lw x21, h
	lw x22, i
	lw x23, j
	beq x22, x23, end1
	beq x0, x0, end2
halt

end1: add x19, x20, x21
	sw x19, f
halt

end2: sub x19, x20, x21
	sw x19, f



f: .word 0
g: .word 2
h: .word	1
i: .word 2
j: .word 1
