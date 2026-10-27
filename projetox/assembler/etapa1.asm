# =============================================================================
# etapa1.asm - Teste das instrucoes R-type (Etapa 01)
# Instrucoes: XOR, SLL, SRL, SRA, SLTU (+ ADD, SUB, AND, OR, SLT)
# =============================================================================

# Inicializacao de registradores
addi x1, x0, 165        # x1 = 0xA5 (165)
addi x2, x0, 90         # x2 = 0x5A (90)

# XOR: 0xA5 ^ 0x5A = 0xFF (255)
xor x3, x1, x2          # x3 = 0xFF (255)

# SLL: 1 << 4 = 16 (0x10)
addi x4, x0, 1          # x4 = 1
addi x5, x0, 4          # x5 = 4 (shift amount)
sll x6, x4, x5          # x6 = 16 (0x10)

# SRL: 16 >> 4 = 1
srl x7, x6, x5          # x7 = 1

# SRA vs SRL com numero negativo: -16 = 0xFFFFFFF0
addi x8, x0, -16        # x8 = -16 (0xFFFFFFF0)
sra x9, x8, x5          # x9 = (-16) >>> 4 = -1 (0xFFFFFFFF)
srl x10, x8, x5         # x10 = (0xFFFFFFF0) >> 4 = 0x0FFFFFFF

# SLT (signed) vs SLTU (unsigned)
addi x11, x0, -10       # x11 = -10 (0xFFFFFFF6)
addi x12, x0, 10        # x12 = 10  (0x0000000A)
slt x13, x11, x12       # x13 = (-10 < 10) com sinal -> 1
sltu x14, x11, x12      # x14 = (unsigned(-10) < 10) sem sinal -> 0
sltu x15, x12, x11      # x15 = (10 < unsigned(-10)) sem sinal -> 1

# Fim / Halt
beq x0, x0, 0

