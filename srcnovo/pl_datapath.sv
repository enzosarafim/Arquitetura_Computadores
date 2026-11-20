// Datapath pipeline de 5 estagios

`timescale 1ns / 1ps

import pl_pipe_pkg::*;

module pl_datapath #(
    parameter int CLK_HZ = 10_000_000
) (
    input  logic        clk,
    input  logic        rst_n,

    // Sinais de controle vindos do estagio ID (pl_control)
    input  logic        ALUSrc,
    input  logic [1:0]  ALUSrcA,
    input  logic        MemtoReg,
    input  logic        RegWrite,
    input  logic        MemRead,
    input  logic        MemWrite,
    input  logic        Branch,
    input  logic        Jump,
    input  logic        JumpReg,
    input  logic [1:0]  ALUOp,

    // Codigo de operacao da ALU (pl_alu_ctrl, usa campos do estagio EX)
    input  logic [3:0]  ALU_CC,

    // Campos realimentados ao pl_cpu para controle e ALU ctrl
    output logic [6:0]  Opcode,       // opcode do estagio ID (para pl_control)
    output logic [2:0]  Funct3_EX,    // funct3 do estagio EX (para pl_alu_ctrl)
    output logic [6:0]  Funct7_EX,    // funct7 do estagio EX (para pl_alu_ctrl)
    output logic [1:0]  ALUOp_EX,     // ALUOp do estagio EX  (para pl_alu_ctrl)

    output logic [31:0] PC,           // PC atual (testbench / debug)

    // E/S Mapeada em Memoria -- DE2-115
    input  logic [17:0] SW,
    input  logic [3:0]  KEY,
    output logic [17:0] LEDR,
    output logic [8:0]  LEDG,
    output logic        UART_TXD,
    input  logic        UART_RXD,

    // Observabilidade para o testbench
    output logic        wb_reg_write,   // pulso quando WB escreve registrador
    output logic [4:0]  wb_reg_dst,     // registrador destino (WB)
    output logic [31:0] wb_reg_data,    // dado escrito (WB)
    output logic        mem_wr_en,      // escrita na dmem (nao MMIO)
    output logic [7:0]  mem_wr_addr,    // endereco de palavra da dmem (MEM)
    output logic [31:0] mem_wr_data     // palavra resultante na dmem (MEM)
);

    // Sinais internos

    // PC
    logic [31:0] pc_reg, pc_plus4;

    // Registradores de pipeline
    if_id_t  if_id;
    id_ex_t  id_ex;
    ex_mem_t ex_mem;
    mem_wb_t mem_wb;

    // Hazard / branch
    logic        stall;
    logic        pc_src;
    logic [31:0] branch_target;

    // ID
    logic [31:0] rd1, rd2, imm_ext;

    // EX -- forwarding
    logic [1:0]  fwd_a, fwd_b;
    logic [31:0] fwd_srca, fwd_srcb, alu_srca, alu_srcb;
    logic [31:0] alu_result, ex_result;
    logic        br_eq, br_lt, br_ltu, br_taken;

    // WB
    logic [31:0] wb_data;

    // MEM
    logic        mmio_sel;
    logic [31:0] dmem_rd, mmio_rd, mem_read_data;
    logic [3:0]  store_mask;
    logic [31:0] store_lanes, store_bits, store_word;
    logic [31:0] load_shifted, load_data;

    // IF -- Busca de instrucao
    logic [31:0] instr_if;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)      pc_reg <= 32'b0;
        else if (pc_src) pc_reg <= branch_target;   // branch tem prioridade
        else if (!stall) pc_reg <= pc_plus4;
        // else stall: PC mantido
    end

    assign PC       = pc_reg;
    assign pc_plus4 = pc_reg + 32'd4;

    pl_imem imem (
        .addr  (pc_reg[9:2]),
        .instr (instr_if)
    );

    // Registrador IF/ID
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin                    // reset assicrono (unico sinal na lista)
            if_id.pc    <= 32'b0;
            if_id.instr <= 32'b0;
        end else if (pc_src) begin           // flush sincrono: branch taken
            if_id.pc    <= 32'b0;
            if_id.instr <= 32'b0;
        end else if (!stall) begin           // avanco normal
            if_id.pc    <= pc_reg;
            if_id.instr <= instr_if;
        end
        // else stall: mantido
    end

    // ID -- Decodificacao, banco de registradores, imediato, hazard
    assign Opcode = if_id.instr[6:0];

    // Deteccao de hazard load-use
    pl_hazard hazard (
        .if_id_rs1      (if_id.instr[19:15]),
        .if_id_rs2      (if_id.instr[24:20]),
        .id_ex_rd       (id_ex.rd),
        .id_ex_mem_read (id_ex.mem_read),
        .stall          (stall)
    );

    // Dado de write-back (mux WB): usado tambem pelo forwarding MEM/WB->EX
    assign wb_data = mem_wb.mem_to_reg ? mem_wb.read_data : mem_wb.alu_result;

    pl_regfile regfile (
        .clk       (clk),
        .RegWrite  (mem_wb.reg_write),
        .rs1       (if_id.instr[19:15]),
        .rs2       (if_id.instr[24:20]),
        .rd        (mem_wb.rd),
        .WriteData (wb_data),
        .ReadData1 (rd1),
        .ReadData2 (rd2)
    );

    pl_sign_ext sign_ext (
        .Instr  (if_id.instr),
        .ImmExt (imm_ext)
    );

    // Saidas para o testbench (estagio WB)
    assign wb_reg_write = mem_wb.reg_write;
    assign wb_reg_dst   = mem_wb.rd;
    assign wb_reg_data  = wb_data;

    // Registrador ID/EX
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin                      // reset assicrono (unico sinal na lista)
            id_ex.alu_src    <= 1'b0;
            id_ex.alu_src_a  <= 2'b00;
            id_ex.mem_to_reg <= 1'b0;
            id_ex.reg_write  <= 1'b0;
            id_ex.mem_read   <= 1'b0;
            id_ex.mem_write  <= 1'b0;
            id_ex.alu_op     <= 2'b00;
            id_ex.branch     <= 1'b0;
            id_ex.jump       <= 1'b0;
            id_ex.jump_reg   <= 1'b0;
            id_ex.pc         <= 32'b0;
            id_ex.rd1        <= 32'b0;
            id_ex.rd2        <= 32'b0;
            id_ex.rs1        <= 5'b0;
            id_ex.rs2        <= 5'b0;
            id_ex.rd         <= 5'b0;
            id_ex.imm_ext    <= 32'b0;
            id_ex.funct3     <= 3'b0;
            id_ex.funct7     <= 7'b0;
        end else if (stall || pc_src) begin    // NOP sincrono: load-use, desvio ou jump
            id_ex.alu_src    <= 1'b0;
            id_ex.alu_src_a  <= 2'b00;
            id_ex.mem_to_reg <= 1'b0;
            id_ex.reg_write  <= 1'b0;
            id_ex.mem_read   <= 1'b0;
            id_ex.mem_write  <= 1'b0;
            id_ex.alu_op     <= 2'b00;
            id_ex.branch     <= 1'b0;
            id_ex.jump       <= 1'b0;
            id_ex.jump_reg   <= 1'b0;
            id_ex.pc         <= 32'b0;
            id_ex.rd1        <= 32'b0;
            id_ex.rd2        <= 32'b0;
            id_ex.rs1        <= 5'b0;
            id_ex.rs2        <= 5'b0;
            id_ex.rd         <= 5'b0;
            id_ex.imm_ext    <= 32'b0;
            id_ex.funct3     <= 3'b0;
            id_ex.funct7     <= 7'b0;
        end else begin
            id_ex.alu_src    <= ALUSrc;
            id_ex.alu_src_a  <= ALUSrcA;
            id_ex.mem_to_reg <= MemtoReg;
            id_ex.reg_write  <= RegWrite;
            id_ex.mem_read   <= MemRead;
            id_ex.mem_write  <= MemWrite;
            id_ex.alu_op     <= ALUOp;
            id_ex.branch     <= Branch;
            id_ex.jump       <= Jump;
            id_ex.jump_reg   <= JumpReg;
            id_ex.pc         <= if_id.pc;
            id_ex.rd1        <= rd1;
            id_ex.rd2        <= rd2;
            id_ex.rs1        <= if_id.instr[19:15];
            id_ex.rs2        <= if_id.instr[24:20];
            id_ex.rd         <= if_id.instr[11:7];
            id_ex.imm_ext    <= imm_ext;
            id_ex.funct3     <= if_id.instr[14:12];
            id_ex.funct7     <= if_id.instr[31:25];
        end
    end

    // Realimentacao para pl_alu_ctrl (usa campos do estagio EX)
    assign Funct3_EX = id_ex.funct3;
    assign Funct7_EX = id_ex.funct7;
    assign ALUOp_EX  = id_ex.alu_op;

    // EX -- Forwarding, ALU, resolucao de branch
    pl_forward forward (
        .id_ex_rs1        (id_ex.rs1),
        .id_ex_rs2        (id_ex.rs2),
        .ex_mem_rd        (ex_mem.rd),
        .mem_wb_rd        (mem_wb.rd),
        .ex_mem_reg_write (ex_mem.reg_write),
        .mem_wb_reg_write (mem_wb.reg_write),
        .forward_a        (fwd_a),
        .forward_b        (fwd_b)
    );

    // Mux de forwarding para SrcA
    always_comb begin
        case (fwd_a)
            2'b10:   fwd_srca = ex_mem.alu_result;
            2'b01:   fwd_srca = wb_data;
            default: fwd_srca = id_ex.rd1;
        endcase
    end

    // Mux de forwarding para SrcB (antes do mux ALUSrc)
    always_comb begin
        case (fwd_b)
            2'b10:   fwd_srcb = ex_mem.alu_result;
            2'b01:   fwd_srcb = wb_data;
            default: fwd_srcb = id_ex.rd2;
        endcase
    end

    // Mux ALUSrcA: rs1 (adiantado), PC (AUIPC) ou zero (LUI).
    // Fica depois do forwarding: em LUI/AUIPC o campo rs1 e parte do imediato,
    // e uma coincidencia com um rd recente nao pode alterar o resultado.
    always_comb begin
        case (id_ex.alu_src_a)
            2'b01:   alu_srca = id_ex.pc;
            2'b10:   alu_srca = 32'b0;
            default: alu_srca = fwd_srca;
        endcase
    end

    // Mux ALUSrc: imediato ou registrador
    assign alu_srcb = id_ex.alu_src ? id_ex.imm_ext : fwd_srcb;

    pl_alu alu (
        .SrcA      (alu_srca),
        .SrcB      (alu_srcb),
        .Operation (ALU_CC),
        .ALUResult (alu_result),
        .Zero      ()              // desvios usam o comparador abaixo
    );

    // Condicao dos desvios, sobre os operandos ja adiantados (rs1, rs2).
    assign br_eq  = (fwd_srca == fwd_srcb);
    assign br_lt  = ($signed(fwd_srca) < $signed(fwd_srcb));
    assign br_ltu = (fwd_srca < fwd_srcb);

    always_comb begin
        case (id_ex.funct3)
            3'b000:  br_taken = br_eq;     // BEQ
            3'b001:  br_taken = !br_eq;    // BNE
            3'b100:  br_taken = br_lt;     // BLT
            3'b101:  br_taken = !br_lt;    // BGE
            3'b110:  br_taken = br_ltu;    // BLTU
            3'b111:  br_taken = !br_ltu;   // BGEU
            default: br_taken = 1'b0;      // 010 e 011 nao existem em RV32I
        endcase
    end

    // Desvio/jump resolvido no estagio EX (flush de 2 instrucoes se tomado).
    // Destino: PC + imm (desvios e JAL) ou (rs1 + imm) & ~1 (JALR, soma feita na ALU).
    assign branch_target = id_ex.jump_reg ? {alu_result[31:1], 1'b0}
                                          : id_ex.pc + id_ex.imm_ext;
    assign pc_src        = id_ex.jump || (id_ex.branch && br_taken);

    // JAL/JALR escrevem o endereco de retorno (PC + 4) no lugar do resultado da ALU
    assign ex_result = id_ex.jump ? id_ex.pc + 32'd4 : alu_result;

    // Registrador EX/MEM
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ex_mem.mem_to_reg  <= 1'b0;
            ex_mem.reg_write   <= 1'b0;
            ex_mem.mem_read    <= 1'b0;
            ex_mem.mem_write   <= 1'b0;
            ex_mem.alu_result  <= 32'b0;
            ex_mem.write_data  <= 32'b0;
            ex_mem.rd          <= 5'b0;
            ex_mem.funct3      <= 3'b0;
        end else begin
            ex_mem.mem_to_reg  <= id_ex.mem_to_reg;
            ex_mem.reg_write   <= id_ex.reg_write;
            ex_mem.mem_read    <= id_ex.mem_read;
            ex_mem.mem_write   <= id_ex.mem_write;
            ex_mem.alu_result  <= ex_result;
            ex_mem.write_data  <= fwd_srcb;   // rs2 adiantado (para stores/MMIO)
            ex_mem.rd          <= id_ex.rd;
            ex_mem.funct3      <= id_ex.funct3;
        end
    end

    // MEM -- Memoria de dados + MMIO
    assign mmio_sel = ex_mem.alu_result[10];

    // Stores: bytes alterados pelo SB/SH/SW (funct3) e dado replicado nas faixas.
    always_comb begin
        case (ex_mem.funct3[1:0])
            2'b00: begin                                    // SB
                store_mask  = 4'b0001 << ex_mem.alu_result[1:0];
                store_lanes = {4{ex_mem.write_data[7:0]}};
            end
            2'b01: begin                                    // SH
                store_mask  = ex_mem.alu_result[1] ? 4'b1100 : 4'b0011;
                store_lanes = {2{ex_mem.write_data[15:0]}};
            end
            default: begin                                  // SW
                store_mask  = 4'b1111;
                store_lanes = ex_mem.write_data;
            end
        endcase
    end

    // Palavra nova = bytes do store onde a mascara vale 1, palavra atual no resto.
    assign store_bits = {{8{store_mask[3]}}, {8{store_mask[2]}},
                         {8{store_mask[1]}}, {8{store_mask[0]}}};
    assign store_word = (store_lanes & store_bits) | (dmem_rd & ~store_bits);

    pl_dmem dmem (
        .clk       (clk),
        .MemWrite  (ex_mem.mem_write & ~mmio_sel),
        .addr      (ex_mem.alu_result[9:2]),
        .WriteData (store_word),
        .ReadData  (dmem_rd)
    );

    pl_mmio #(
        .CLK_HZ    (CLK_HZ)
    ) mmio (
        .clk       (clk),
        .rst_n     (rst_n),
        .MemWrite  (ex_mem.mem_write &  mmio_sel),
        .MemRead   (ex_mem.mem_read  &  mmio_sel),
        .addr      (ex_mem.alu_result[4:2]),
        .WriteData (ex_mem.write_data),
        .SW        (SW),
        .KEY       (KEY),
        .ReadData  (mmio_rd),
        .LEDR      (LEDR),
        .LEDG      (LEDG),
        .UART_TXD  (UART_TXD),
        .UART_RXD  (UART_RXD)
    );

    assign mem_read_data = mmio_sel ? mmio_rd : dmem_rd;

    // Loads: seleciona o byte/meia palavra pelo endereco e estende (funct3).
    assign load_shifted = mem_read_data >> {ex_mem.alu_result[1:0], 3'b000};

    always_comb begin
        case (ex_mem.funct3)
            3'b000:  load_data = {{24{load_shifted[7]}},  load_shifted[7:0]};   // LB
            3'b001:  load_data = {{16{load_shifted[15]}}, load_shifted[15:0]};  // LH
            3'b100:  load_data = {24'b0, load_shifted[7:0]};                    // LBU
            3'b101:  load_data = {16'b0, load_shifted[15:0]};                   // LHU
            default: load_data = mem_read_data;                                 // LW
        endcase
    end

    // Saidas de observabilidade para o testbench
    assign mem_wr_en   = ex_mem.mem_write & ~mmio_sel;
    assign mem_wr_addr = ex_mem.alu_result[9:2];
    assign mem_wr_data = store_word;

    // Registrador MEM/WB
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_wb.mem_to_reg <= 1'b0;
            mem_wb.reg_write  <= 1'b0;
            mem_wb.alu_result <= 32'b0;
            mem_wb.read_data  <= 32'b0;
            mem_wb.rd         <= 5'b0;
        end else begin
            mem_wb.mem_to_reg <= ex_mem.mem_to_reg;
            mem_wb.reg_write  <= ex_mem.reg_write;
            mem_wb.alu_result <= ex_mem.alu_result;
            mem_wb.read_data  <= load_data;
            mem_wb.rd         <= ex_mem.rd;
        end
    end

    // WB: wb_data = mem_to_reg ? read_data : alu_result  (definido acima, no bloco ID)

endmodule
