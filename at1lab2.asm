lw x10, a
lw x11, b

add x12, x10, x0 # m = a

bge x11, x12, fim # if b >= m, go to the end

add x12, x10, x11

end:
sw x12, m # Save
halt

a: .word 6 # 
b: .word 15 # 
m: .word 0x0000



