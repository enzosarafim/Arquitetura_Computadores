// =============================================================================
// pl_control.sv
// Unidade de Controle Principal -- RV32I pipelined (P&H secao 4.4)
//
// Decodifica o opcode de 7 bits (estagio ID) e gera os sinais de controle
// que serao propagados pelos registradores de pipeline.
//
// Instrucoes suportadas (ISA RV32I):
//   R-type  (0110011): add, sub, sll, slt, sltu, xor, srl, sra, or, and
//   I-type  (0010011): addi, slti, sltiu, xori, ori, andi, slli, srli, srai
//   Load    (0000011): lb, lh, lw, lbu, lhu
//   Store   (0100011): sb, sh, sw
//   Branch  (1100011): beq, bne, blt, bge, bltu, bgeu
//   LUI     (0110111): lui
//   AUIPC   (0010111): auipc
//   JAL     (1101111): jal
//   JALR    (1100111): jalr
// =============================================================================

`timescale 1ns / 1ps

module pl_control (
    input  logic [6:0] Opcode,
    output logic       ALUSrc,
    output logic [1:0] ALUSrcA,    // 00=rd1, 01=PC (AUIPC), 10=0 (LUI)
    output logic       MemtoReg,
    output logic       RegWrite,
    output logic       MemRead,
    output logic       MemWrite,
    output logic       Branch,
    output logic       Jump,
    output logic       Jalr,
    output logic [1:0] ALUOp,
    output logic       UsesRs1,
    output logic       UsesRs2
);

    localparam R_TYPE = 7'b0110011;
    localparam I_TYPE = 7'b0010011;
    localparam LOAD   = 7'b0000011;
    localparam STORE  = 7'b0100011;
    localparam BRANCH = 7'b1100011;
    localparam LUI    = 7'b0110111;
    localparam AUIPC  = 7'b0010111;
    localparam JAL    = 7'b1101111;
    localparam JALR   = 7'b1100111;

    always_comb begin
        ALUSrc   = 1'b0;
        ALUSrcA  = 2'b00;
        MemtoReg = 1'b0;
        RegWrite = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        Branch   = 1'b0;
        Jump     = 1'b0;
        Jalr     = 1'b0;
        ALUOp    = 2'b00;
        UsesRs1  = 1'b0;
        UsesRs2  = 1'b0;

        case (Opcode)
            R_TYPE: begin
                ALUSrc   = 1'b0;
                ALUSrcA  = 2'b00;
                MemtoReg = 1'b0;
                RegWrite = 1'b1;
                ALUOp    = 2'b10;
                UsesRs1  = 1'b1;
                UsesRs2  = 1'b1;
            end

            I_TYPE: begin
                ALUSrc   = 1'b1;
                ALUSrcA  = 2'b00;
                MemtoReg = 1'b0;
                RegWrite = 1'b1;
                ALUOp    = 2'b11;
                UsesRs1  = 1'b1;
                UsesRs2  = 1'b0;
            end

            LOAD: begin
                ALUSrc   = 1'b1;
                ALUSrcA  = 2'b00;
                MemtoReg = 1'b1;
                RegWrite = 1'b1;
                MemRead  = 1'b1;
                ALUOp    = 2'b00;
                UsesRs1  = 1'b1;
                UsesRs2  = 1'b0;
            end

            STORE: begin
                ALUSrc   = 1'b1;
                ALUSrcA  = 2'b00;
                MemWrite = 1'b1;
                ALUOp    = 2'b00;
                UsesRs1  = 1'b1;
                UsesRs2  = 1'b1;
            end

            BRANCH: begin
                ALUSrc   = 1'b0;
                ALUSrcA  = 2'b00;
                Branch   = 1'b1;
                ALUOp    = 2'b01;
                UsesRs1  = 1'b1;
                UsesRs2  = 1'b1;
            end

            LUI: begin
                ALUSrc   = 1'b1;
                ALUSrcA  = 2'b10;   // 0
                RegWrite = 1'b1;
                ALUOp    = 2'b00;   // 0 + imm
                UsesRs1  = 1'b0;
                UsesRs2  = 1'b0;
            end

            AUIPC: begin
                ALUSrc   = 1'b1;
                ALUSrcA  = 2'b01;   // PC
                RegWrite = 1'b1;
                ALUOp    = 2'b00;   // PC + imm
                UsesRs1  = 1'b0;
                UsesRs2  = 1'b0;
            end

            JAL: begin
                ALUSrc   = 1'b0;
                ALUSrcA  = 2'b00;
                RegWrite = 1'b1;
                Jump     = 1'b1;
                Jalr     = 1'b0;
                ALUOp    = 2'b00;
                UsesRs1  = 1'b0;
                UsesRs2  = 1'b0;
            end

            JALR: begin
                ALUSrc   = 1'b1;
                ALUSrcA  = 2'b00;
                RegWrite = 1'b1;
                Jump     = 1'b1;
                Jalr     = 1'b1;
                ALUOp    = 2'b00;
                UsesRs1  = 1'b1;
                UsesRs2  = 1'b0;
            end

            default: ; // todos os sinais permanecem em zero (seguro)
        endcase
    end

endmodule
