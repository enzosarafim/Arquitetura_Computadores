# =============================================================================
# etapa2.asm - Teste de I-type Aritmetico/Logico e U-type (Etapa 02)
# Instrucoes: ADDI, ANDI, ORI, XORI, SLTI, SLTIU, SLLI, SRLI, SRAI, LUI, AUIPC
# =============================================================================

# ADDI: constante imediata
addi x1, x0, 100        # x1 = 100 (0x64)

# ANDI: mascara de bits (100 & 15 = 4)
andi x2, x1, 15         # x2 = 4

# ORI: setar bits (4 | 2 = 6)
ori x3, x2, 2           # x3 = 6

# XORI: inverter bit (6 ^ 1 = 7)
xori x4, x3, 1          # x4 = 7

# SLTI e SLTIU: comparacao com imediato
slti x5, x1, 200        # x5 = (100 < 200) -> 1
slti x6, x1, 50         # x6 = (100 < 50) -> 0
sltiu x7, x1, 200       # x7 = (100 < 200 unsigned) -> 1

# SLLI e SRLI: shifts com imediato
slli x8, x1, 2          # x8 = 100 << 2 = 400 (0x190)
srli x9, x8, 2          # x9 = 400 >> 2 = 100 (0x64)

# SRAI vs SRLI: shift de numero negativo
addi x10, x0, -64       # x10 = -64 (0xFFFFFFC0)
srai x11, x10, 2        # x11 = (-64) >>> 2 = -16 (0xFFFFFFF0) [aritmetico]
srli x12, x10, 2        # x12 = (0xFFFFFFC0) >> 2 = 0x3FFFFFF0 [logico]

# LUI: carregar imediato de 20 bits nos bits [31:12]
lui x13, 1              # x13 = 1 << 12 = 4096 (0x00001000)
lui x14, 10             # x14 = 10 << 12 = 40960 (0x0000A000)

# AUIPC: somar PC atual com imediato [31:12]
auipc x15, 1            # x15 = PC + 4096 (PC = 0x38 -> x15 = 0x1038)

# Halt
beq x0, x0, 0

