module multiplier_datapath (
    input  logic        clk,
    input  logic        rst_n,

    // Entradas de dados
    input  logic [31:0] multiplicand_in,
    input  logic [31:0] multiplier_in,

    // Sinais de controle vindos da FSM
    input  logic        load,        // Carrega operandos iniciais
    input  logic        product_wr,  // Escreve soma da ALU em product_reg
    input  logic        shift_en,    // Shift left em multiplicand, shift right em multiplier

    // Saidas de status para a FSM
    output logic        multiplier_lsb, // Bit 0 do registrador multiplier (testa Multiplier0)

    // Saída do resultado
    output logic [63:0] product
);
    // Registradores internos (Figura 3.4)
    logic [64:0] product_reg; // DICA 2
    logic [31:0] multiplicand_reg;

    // ALU de 32 bits com Carry-Out (33 bits de saída)
    logic [32:0] alu_sum;

    alu_32 alu (
        .a   (product_reg[63:32]),
        .b   (multiplicand_reg),
        .sum (alu_sum)
    );

    // Saídas combinacionais
    assign multiplier_lsb = product_reg[0];
    assign product        = product_reg[63:0]; // Resultado final nos 64 bits inferiores

    // Atualizacao dos registradores
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            multiplicand_reg <= '0;
            product_reg      <= '0;

        end else if (load) begin
            // Inicializacao conforme Figura 3.4:
            // Multiplicand -> bits [31:0], bits [63:32] = 0
            multiplicand_reg <= multiplicand_in;
            product_reg      <= {33'b0, multiplier_in};

        end else begin
            // Passo 1 (Figura 3.4): Product = Product + Multiplicand (se habilitado)
            if (product_wr) begin
                product_reg[64:32] <= alu_sum;
            end
            // Passos 2 e 3 (Figura 3.4): deslocamentos
            if (shift_en) begin
                product_reg   <= {1'b0, product_reg[64:1]};   // shift right (lógico)
            end
        end
    end

endmodule
