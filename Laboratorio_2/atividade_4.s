	addi x5, x0, 40  
    addi x11, x0, 42 
loop:
    lb x12, 0(x5)  
	beq x12, x0, fim 
    sb x12, 1024(x0)     
    addi x5, x5, 1  
	lb x10, 1025(x0)
	beq x10, x11, fim     
    jal x0, loop         

fim:
    halt                 

str1: .string "Hello World"
