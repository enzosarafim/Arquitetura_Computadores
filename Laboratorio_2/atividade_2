	lw x10, a
	lw x11, b
	sw x10, m
	lw x12, m
	blt x11, x12, end1
	beq x0, x0, end2
halt
end1: add x21, x10, x11
	sw x21, m
halt
end2: sub x21, x10, x11
	sw x21, m



a: .word 1
b: .word 2
m: .word 0
