	lw x5, i    
loop:
    lb x10, 0(x5)
    beq x10, x0, fim
    sb x10, 1024(x0)
    addi x5, x5, 1
    jal x1, loop
fim:
    halt
str1: .string "Hello World"
i: .word 28

