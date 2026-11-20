// Unidade de Controle Principal
// Decodifica o opcode de 7 bits (estagio ID) e gera os sinais de controle
// que serao propagados pelos registradores de pipeline.

`timescale 1ns / 1ps

module pl_control (
    input  logic [6:0] Opcode,
    output logic       ALUSrc,
    output logic [1:0] ALUSrcA,
    output logic       MemtoReg,
    output logic       RegWrite,
    output logic       MemRead,
    output logic       MemWrite,
    output logic       Branch,
    output logic       Jump,
    output logic       JumpReg,
    output logic [1:0] ALUOp
);

    localparam R_TYPE = 7'b0110011;
    localparam OP_IMM = 7'b0010011;
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
        JumpReg  = 1'b0;
        ALUOp    = 2'b00;

        case (Opcode)
            R_TYPE: begin
                ALUSrc   = 1'b0;
                MemtoReg = 1'b0;
                RegWrite = 1'b1;
                ALUOp    = 2'b10;
            end
            OP_IMM: begin
                ALUSrc   = 1'b1;
                MemtoReg = 1'b0;
                RegWrite = 1'b1;
                ALUOp    = 2'b11;
            end
            LOAD: begin
                ALUSrc   = 1'b1;
                MemtoReg = 1'b1;
                RegWrite = 1'b1;
                MemRead  = 1'b1;
                ALUOp    = 2'b00;
            end
            STORE: begin
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
                ALUOp    = 2'b00;
            end
            BRANCH: begin
                Branch   = 1'b1;
                ALUOp    = 2'b01;
            end
            LUI: begin                  // rd = 0 + imm
                ALUSrc   = 1'b1;
                ALUSrcA  = 2'b10;
                RegWrite = 1'b1;
                ALUOp    = 2'b00;
            end
            AUIPC: begin                // rd = PC + imm
                ALUSrc   = 1'b1;
                ALUSrcA  = 2'b01;
                RegWrite = 1'b1;
                ALUOp    = 2'b00;
            end
            JAL: begin                  // rd = PC + 4; PC = PC + imm
                RegWrite = 1'b1;
                Jump     = 1'b1;
            end
            JALR: begin                 // rd = PC + 4; PC = (rs1 + imm) & ~1
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                Jump     = 1'b1;
                JumpReg  = 1'b1;
                ALUOp    = 2'b00;
            end
            default: ; // sinais permanecem em zero (seguro)
        endcase
    end

endmodule
