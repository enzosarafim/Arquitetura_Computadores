# =============================================================================
# etapa3.asm - Teste de Acesso a Memoria (Loads/Stores) e Saltos (Branches/Jumps)
# Instrucoes: LB, LH, LBU, LHU, SB, SH, BNE, BLT, BGE, BLTU, BGEU, JAL, JALR
# =============================================================================

# Parte 1: Stores e Loads (SB, SH, SW, LB, LH, LBU, LHU, LW)
addi x1, x0, 0          # base endereco = 0

# Escreve 4 bytes individuais usando SB na palavra dmem[1] (endereco 4)
addi x2, x0, 170        # 0xAA (170)
addi x3, x0, 187        # 0xBB (187)
addi x4, x0, 204        # 0xCC (204)
addi x5, x0, 221        # 0xDD (221)
sb x2, 4(x1)            # byte 0 = 0xAA
sb x3, 5(x1)            # byte 1 = 0xBB
sb x4, 6(x1)            # byte 2 = 0xCC
sb x5, 7(x1)            # byte 3 = 0xDD
# Le a palavra inteira: deve ser 0xDDCCBBAA
lw x6, 4(x1)

# LB (com sinal) vs LBU (sem sinal) no byte 0 (0xAA)
lb x7, 4(x1)            # x7 = 0xFFFFFFAA (com sinal)
lbu x8, 4(x1)           # x8 = 0x000000AA (sem sinal)

# SH (Store Halfword) em dmem[2] (endereco 8)
addi x9, x0, -1         # 0xFFFFFFFF (lower 16 bits = 0xFFFF)
lui x10, 2
addi x10, x10, -1       # 0x00001FFF (lower 16 bits = 0x1FFF)
sh x9, 8(x1)            # halfword 0 = 0xFFFF
sh x10, 10(x1)          # halfword 1 = 0x1FFF
# Le a palavra inteira: deve ser 0x1FFFFFFF
lw x11, 8(x1)

# LH (com sinal) vs LHU (sem sinal) na halfword 0 (0xFFFF)
lh x12, 8(x1)           # x12 = 0xFFFFFFFF (com sinal)
lhu x13, 8(x1)          # x13 = 0x0000FFFF (sem sinal)

# Parte 2: Desvios Condicionais (B-type)
addi x14, x0, 10
addi x15, x0, 20
addi x16, x0, -10

# BNE: 10 != 20 -> tomado (+8 pula instrucao seguinte)
bne x14, x15, 8
addi x17, x0, 99        # DESCARTADO
addi x17, x0, 1         # x17 = 1

# BLT (com sinal): -10 < 10 -> tomado
blt x16, x14, 8
addi x18, x0, 99        # DESCARTADO
addi x18, x0, 1         # x18 = 1

# BGE (com sinal): 20 >= 10 -> tomado
bge x15, x14, 8
addi x19, x0, 99        # DESCARTADO
addi x19, x0, 1         # x19 = 1

# BLTU (sem sinal): 10 < unsigned(-10) -> tomado
bltu x14, x16, 8
addi x20, x0, 99        # DESCARTADO
addi x20, x0, 1         # x20 = 1

# BGEU (sem sinal): unsigned(-10) >= 10 -> tomado
bgeu x16, x14, 8
addi x21, x0, 99        # DESCARTADO
addi x21, x0, 1         # x21 = 1

# Parte 3: Jumps (JAL e JALR)
# JAL: salta para frente (+8) e salva PC+4 no registrador de link (x22)
jal x22, 8
addi x23, x0, 99        # DESCARTADO
addi x23, x0, 1         # x23 = 1

# JALR: salta para endereco calculado em registrador (x24 + 16) e salva PC+4 em x25
auipc x24, 0            # x24 = PC atual
addi x24, x24, 16       # x24 = alvo
jalr x25, x24, 0        # salta para x24, salva PC+4 em x25
addi x26, x0, 99        # DESCARTADO
addi x26, x0, 99        # DESCARTADO
addi x26, x0, 99        # DESCARTADO
addi x26, x0, 1         # x26 = 1

# Halt
beq x0, x0, 0

