#!/usr/bin/env python3
"""
test_all.py - Script de teste e verificacao automatica das etapas do processador RV32I.

Uso:
    python test_all.py          # Executa todas as etapas (Etapa 01, 02 e 03)
    python test_all.py etapa1   # Executa apenas a Etapa 01 (R-type)
    python test_all.py etapa2   # Executa apenas a Etapa 02 (I-type e U-type)
    python test_all.py etapa3   # Executa apenas a Etapa 03 (Memoria e Saltos)
"""

import subprocess
import os
import sys
import re

BASE_DIR = r"D:\Users\ens2\Documents\pissmog\rv32i_pipelined_base_project"
MODELSIM_DIR = os.path.join(BASE_DIR, "modelsim")
SRC_DIR = os.path.join(BASE_DIR, "src")
VLOG = r"C:\InstallModelSim\modelsim_ase\win32aloem\vlog.exe"
VSIM = r"C:\InstallModelSim\modelsim_ase\win32aloem\vsim.exe"

sys.path.insert(0, os.path.join(BASE_DIR, "assembler"))
import assembler

def run_test(name, asm_file_or_instructions, initial_dmem=None):
    print(f"\n=======================================================")
    print(f"RUNNING TEST: {name}")
    print(f"=======================================================")
    
    if isinstance(asm_file_or_instructions, str):
        # File path
        instructions = assembler.read_file(asm_file_or_instructions)
    else:
        instructions = list(asm_file_or_instructions)
        
    if not (instructions[-1].startswith("beq x0,x0,0") or instructions[-1].startswith("beq x0, x0, 0")):
        instructions.append("beq x0,x0,0")
        
    hex_lines = []
    for inst in instructions:
        inst_clean = re.sub(r'\s*,\s*', ',', inst.strip())
        inst_clean = re.sub(r'\s+', ' ', inst_clean)
        b = assembler.translate_instruction(inst_clean)
        if b is None:
            raise ValueError(f"Failed to assemble: {inst}")
        hex_word = f"{int(b, 2):08X}"
        hex_lines.append(hex_word)
        
    prog_path = os.path.join(MODELSIM_DIR, "program.hex")
    with open(prog_path, "w") as f:
        for hw in hex_lines:
            f.write(hw + "\n")
            
    data_path = os.path.join(MODELSIM_DIR, "data.hex")
    with open(data_path, "w") as f:
        if initial_dmem:
            for val in initial_dmem:
                f.write(f"{val:08X}\n")
        else:
            f.write("00000000\n")
            
    # Executa ModelSim em batch
    cmd = f'& "{VSIM}" -c -do "run -all; quit" pl_cpu_tb'
    res = subprocess.run(["powershell", "-Command", f"Set-Location '{MODELSIM_DIR}'; {cmd}"],
                         capture_output=True, text=True)
    
    out_txt_path = os.path.join(MODELSIM_DIR, "output.txt")
    regs = {}
    dmem = {}
    with open(out_txt_path, "r") as f:
        for line in f:
            m_reg = re.match(r"^FINAL REG\s+(\d+)\s*=\s*0x([0-9a-fA-F]+)", line)
            if m_reg:
                regs[int(m_reg.group(1))] = int(m_reg.group(2), 16)
            m_mem = re.match(r"^FINAL MEM\[\s*(\d+)\]\s*=\s*0x([0-9a-fA-F]+)", line)
            if m_mem:
                dmem[int(m_mem.group(1))] = int(m_mem.group(2), 16)
                
    return regs, dmem, res.stdout

def test_etapa1():
    asm_path = os.path.join(BASE_DIR, "assembler", "etapa1.asm")
    regs, dmem, out = run_test("Etapa 01: R-type (XOR, SLL, SRL, SRA, SLTU)", asm_path)
    assert regs.get(1) == 165
    assert regs.get(2) == 90
    assert regs.get(3) == 0xFF, f"x3={hex(regs.get(3,0))}"
    assert regs.get(6) == 16, f"x6={hex(regs.get(6,0))}"
    assert regs.get(7) == 1, f"x7={hex(regs.get(7,0))}"
    assert regs.get(9) == 0xFFFFFFFF, f"x9={hex(regs.get(9,0))}"
    assert regs.get(10) == 0x0FFFFFFF, f"x10={hex(regs.get(10,0))}"
    assert regs.get(13) == 1, f"x13={regs.get(13,0)}"
    assert regs.get(14, 0) == 0, f"x14={regs.get(14,0)}"
    assert regs.get(15) == 1, f"x15={regs.get(15,0)}"
    print(">>> PASS: Etapa 01 (R-type: XOR, SLL, SRL, SRA, SLTU) APROVADO! <<<")

def test_etapa2():
    asm_path = os.path.join(BASE_DIR, "assembler", "etapa2.asm")
    regs, dmem, out = run_test("Etapa 02: I-type & U-type (ADDI, ANDI, ORI, XORI, SLTI, SLTIU, SLLI, SRLI, SRAI, LUI, AUIPC)", asm_path)
    assert regs.get(1) == 100
    assert regs.get(2) == 4
    assert regs.get(3) == 6
    assert regs.get(4) == 7
    assert regs.get(5) == 1
    assert regs.get(6, 0) == 0
    assert regs.get(7) == 1
    assert regs.get(8) == 400
    assert regs.get(9) == 100
    assert regs.get(11) == 0xFFFFFFF0
    assert regs.get(12) == 0x3FFFFFF0
    assert regs.get(13) == 0x1000
    assert regs.get(14) == 0xA000
    assert regs.get(15) == 0x1038, f"x15={hex(regs.get(15,0))}"
    print(">>> PASS: Etapa 02 (I-type & U-type) APROVADO! <<<")

def test_etapa3():
    asm_path = os.path.join(BASE_DIR, "assembler", "etapa3.asm")
    regs, dmem, out = run_test("Etapa 03: Memoria & Saltos (LB, LH, LBU, LHU, SB, SH, BNE, BLT, BGE, BLTU, BGEU, JAL, JALR)", asm_path)
    assert regs.get(6) == 0xDDCCBBAA, f"x6={hex(regs.get(6,0))}"
    assert regs.get(7) == 0xFFFFFFAA, f"x7={hex(regs.get(7,0))}"
    assert regs.get(8) == 0x000000AA, f"x8={hex(regs.get(8,0))}"
    assert regs.get(11) == 0x1FFFFFFF, f"x11={hex(regs.get(11,0))}"
    assert regs.get(12) == 0xFFFFFFFF, f"x12={hex(regs.get(12,0))}"
    assert regs.get(13) == 0x0000FFFF, f"x13={hex(regs.get(13,0))}"
    assert regs.get(17) == 1, f"x17={regs.get(17,0)}"
    assert regs.get(18) == 1, f"x18={regs.get(18,0)}"
    assert regs.get(19) == 1, f"x19={regs.get(19,0)}"
    assert regs.get(20) == 1, f"x20={regs.get(20,0)}"
    assert regs.get(21) == 1, f"x21={regs.get(21,0)}"
    assert regs.get(23) == 1, f"x23={regs.get(23,0)}"
    assert regs.get(26) == 1, f"x26={regs.get(26,0)}"
    assert dmem.get(1) == 0xDDCCBBAA, f"dmem[1]={hex(dmem.get(1,0))}"
    assert dmem.get(2) == 0x1FFFFFFF, f"dmem[2]={hex(dmem.get(2,0))}"
    print(">>> PASS: Etapa 03 (Memoria & Saltos) APROVADO! <<<")

def restore_default_golden():
    # Restaura hex para o teste padrao
    subprocess.run(["git", "checkout", "modelsim/program.hex", "modelsim/data.hex"],
                   cwd=BASE_DIR, capture_output=True)

if __name__ == "__main__":
    target = sys.argv[1].lower() if len(sys.argv) > 1 else "all"
    try:
        if target in ["etapa1", "1"]:
            test_etapa1()
        elif target in ["etapa2", "2"]:
            test_etapa2()
        elif target in ["etapa3", "3"]:
            test_etapa3()
        else:
            test_etapa1()
            test_etapa2()
            test_etapa3()
            print("\n=======================================================")
            print(">>> TODAS AS ETAPAS FORAM VERIFICADAS COM SUCESSO! <<<")
            print("=======================================================")
    finally:
        restore_default_golden()
