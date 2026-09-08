module multiplier_control (
    input  logic clk,
    input  logic rst_n,

    // Interface com o usuário
    input  logic start,
    output logic done,

    // Interface com o datapath
    input  logic multiplier_lsb, // Bit 0 do registrador multiplier

    output logic load,           // Carrega operandos iniciais
    output logic product_wr,     // Escreve resultado da ALU em product_reg
    output logic shift_en        // Habilita deslocamentos
);
    typedef enum logic [4:0] {
        IDLE        = 5'b00001,
        LOAD        = 5'b00010,
        ADD_OR_SKIP = 5'b00100, // Passo 1+2: testar e somar condicionalmente
        SHIFT       = 5'b01000, // Passos 3+4+5: deslocar e verificar termino
        DONE        = 5'b10000
    } state_t;

    state_t state, next_state;

    // Contador de iteracoes (0 a 31 → 32 iteracoes para 32 bits)
    logic [5:0] count;
    logic       count_en;
    logic       count_rst;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)         count <= '0;
        else if (count_rst) count <= '0;
        else if (count_en)  count <= count + 6'd1;
    end

    // Registrador de estado
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= IDLE;
        else        state <= next_state;
    end

    // Logica de proximo estado
    always_comb begin
        next_state = state;
        case (state)
            IDLE:        if (start)           next_state = LOAD;
            LOAD:                             next_state = ADD_OR_SKIP;
            ADD_OR_SKIP:                      next_state = SHIFT;
            SHIFT:       if (count == 6'd31)  next_state = DONE;
                         else                 next_state = ADD_OR_SKIP;
            DONE:        if (!start)          next_state = IDLE;
            default:                          next_state = IDLE;
        endcase
    end

    // Logica de saida
    always_comb begin
        // Valores padrao
        load       = 1'b0;
        product_wr = 1'b0;
        shift_en   = 1'b0;
        done       = 1'b0;
        count_en   = 1'b0;
        count_rst  = 1'b0;

        case (state)
            IDLE: begin
                count_rst = 1'b1; // Mantem o contador em 0 enquanto ocioso
            end

            LOAD: begin
                load      = 1'b1; // Carrega operandos no datapath
                count_rst = 1'b1; // Reseta o contador
            end

            ADD_OR_SKIP: begin
                // Passo 1 (Figura 3.4): testar Multiplier0
                // Passo 2 (Figura 3.4): se Multiplier0==1, Product = Product + Multiplicand
                product_wr = multiplier_lsb;
            end

            SHIFT: begin
                // Passo 3 (Figura 3.4): shift Multiplicand left
                // Passo 4 (Figura 3.4): shift Multiplier right
                shift_en = 1'b1;
                count_en = 1'b1;
            end

            DONE: begin
                done = 1'b1;
            end

            default: ;
        endcase
    end

endmodule