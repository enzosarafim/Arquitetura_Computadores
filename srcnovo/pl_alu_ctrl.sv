// Unidade de Controle da ALU -- RV32I pipelined (P&H secao 4.4)
//
// Entradas (do estagio EX -- registrador ID/EX):
//   ALUOp[1:0] : codigo do controlador principal
//     2'b00 : Load/Store/LUI/AUIPC -> forcar ADD
//     2'b01 : Desvios              -> forcar SUB (a condicao vem do comparador
//                                     do pl_datapath; o resultado nao e usado)
//     2'b10 : R-type               -> decodificar via Funct3/Funct7
//     2'b11 : I-type aritmetico    -> decodificar via Funct3/Funct7
//   Funct7[6:0], Funct3[2:0] : campos da instrucao
//
// R-type e I-type compartilham Funct3. A diferenca e que, em I-type, inst[31:25]
// faz parte do imediato: ADDI com imediato negativo tem Funct7[5] = 1 e nao pode
// virar SUB. Em SRLI/SRAI, Funct7[5] continua distinguindo a operacao.
//
// Saida Operation[3:0] -> pl_alu.sv:
//   4'd01 ADD  4'd02 SUB  4'd03 XOR  4'd04 OR   4'd05 AND
//   4'd06 SLL  4'd07 SRL  4'd08 SRA  4'd11 SLT  4'd12 SLTU

`timescale 1ns / 1ps

module pl_alu_ctrl (
    input  logic [1:0] ALUOp,
    input  logic [6:0] Funct7,
    input  logic [2:0] Funct3,
    output logic [3:0] Operation
);

    always_comb begin
        case (ALUOp)
            2'b00: Operation = 4'd01;   // Load / Store / LUI / AUIPC / JALR -> ADD

            2'b01: Operation = 4'd02;   // Desvios -> SUB

            2'b10, 2'b11: begin         // R-type e I-type: decodificar Funct
                case (Funct3)
                    3'h0: Operation = (ALUOp == 2'b10 && Funct7[5]) ? 4'd02 : 4'd01; // SUB ou ADD/ADDI
                    3'h1: Operation = 4'd06;  // SLL/SLLI
                    3'h2: Operation = 4'd11;  // SLT/SLTI
                    3'h3: Operation = 4'd12;  // SLTU/SLTIU
                    3'h4: Operation = 4'd03;  // XOR/XORI
                    3'h5: Operation = Funct7[5] ? 4'd08 : 4'd07; // SRA/SRAI ou SRL/SRLI
                    3'h6: Operation = 4'd04;  // OR/ORI
                    3'h7: Operation = 4'd05;  // AND/ANDI
                endcase
            end
        endcase
    end

endmodule
