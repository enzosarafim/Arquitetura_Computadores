lw x10, a
lw x11, b

add x12, x0, x0 # m = 0

bge x11, x12, se # if b >= m, go to the end

add x12, x10, x11
j end

se:
sub x12, x10, x11

end:
sw x12, m # Save
halt

a: .word 6 # 6, 14, 25
b: .word 15 # 15, 7, 12
m: .word 0x0000 # 







