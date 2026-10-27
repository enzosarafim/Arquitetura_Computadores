// =============================================================================
// pl_hazard.sv
// Unidade de Deteccao de Hazard -- RV32I pipelined
//
// Detecta hazard load-use: instrucao de Load em EX seguida imediatamente por
// instrucao em ID que le o registrador destino do Load (rs1 ou rs2).
//
// Acao ao detectar stall:
//   - PC mantido (nao avanca)
//   - IF/ID mantido (instrucao dependente fica em ID mais um ciclo)
//   - ID/EX zerado (NOP/bolha injetada no pipeline)
// =============================================================================

`timescale 1ns / 1ps

module pl_hazard (
    input  logic [4:0] if_id_rs1,       // rs1 da instrucao em ID
    input  logic [4:0] if_id_rs2,       // rs2 da instrucao em ID
    input  logic       if_id_uses_rs1,  // instrucao em ID le rs1?
    input  logic       if_id_uses_rs2,  // instrucao em ID le rs2?
    input  logic [4:0] id_ex_rd,        // rd da instrucao em EX
    input  logic       id_ex_mem_read,  // instrucao em EX e Load?
    output logic       stall            // 1 = inserir bolha
);

    assign stall = id_ex_mem_read && (id_ex_rd != 5'b0) &&
                   ((if_id_uses_rs1 && (id_ex_rd == if_id_rs1)) ||
                    (if_id_uses_rs2 && (id_ex_rd == if_id_rs2)));

endmodule
