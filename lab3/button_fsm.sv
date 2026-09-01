module button_fsm (
    input  logic       clk,    // Clock de 50 MHz
    input  logic       rst_n,  // Reset assincrono, ativo baixo (KEY[0])
    input  logic [3:0] btn,    // Botao de avanco, ativo baixo  (KEY[3:1] + Key)
    output logic [3:0] leds    // LEDs indicadores de estado
    output logic       unlock
);

localparam logic [3:0] BTN_AZUL    = 4'b0001;  // Botao 1
localparam logic [3:0] BTN_AMARELO = 4'b0010;  // Botao 2
localparam logic [3:0] BTN_VERDE   = 4'b0100;  // Botao 3
localparam logic [3:0] BTN_VERMELHO= 4'b1000;  // Botao 4

typedef enum logic [4:0] {
    S0 = 4'b0000,   // Estado inicial 
    S1 = 4'b0001,   // Azul
    S2 = 4'b0010,   // Amarelo
    S3 = 4'b0100,   // Amarelo
    S4 = 4'b1000    // Vermelho
} state_t;

state_t state, next_state;

logic [3:0] btn_active;  // Botao em logica positiva (1 = pressionado)
logic [3:0] btn_prev;    // Valor do botao no ciclo anterior
logic [3:0] btn_rise;    // Pulso de 1 ciclo na borda de subida

assign btn_active = ~btn;
assign btn_rise   = btn_active & ~btn_prev;  // Borda de subida

// Registra o estado anterior do botao (FF simples)
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) btn_prev <= 4'b0;
    else        btn_prev <= btn_active;
end

// [3] PROCESSO SEQUENCIAL -- Registro de estado

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) state <= S0;
    else        state <= next_state;
end

// [4] PROCESSO COMBINACIONAL
always_comb begin
    next_state = state;  // Default: mantem estado se nao houver borda

    unique case (state)
        S0: begin if (btn_rise == BTN_AZUL) next_state = S1; else if (|btn_rise) next_state = S0; end
        S1: begin if (btn_rise == BTN_AMARELO) next_state = S2; else if (|btn_rise) next_state = S0; end
        S2: begin if (btn_rise == BTN_AMARELO) next_state = S3; else if (|btn_rise) next_state = S0; end
        S3: begin if (btn_rise == BTN_VERMELHO) next_state = S4; else if (|btn_rise) next_state = S0; end
        // Desbloqueado
        S4: begin next_state = S4; end
        default: next_state = S0;
    endcase
end

// unlock ( # o cofre abre somente se a sequência [Azul, Amarelo, Amarelo, Vermelho] for digitada.)
// -----------------------------------------------------------------------------
// [5] SAIDA -- Logica de Moore
//
//   Maquina de Moore: saida depende APENAS do estado atual (nao das entradas).
//   Isso torna a saida estavel entre transicoes.
//
//   Com one-hot, cada LED corresponde diretamente a 1 bit do estado.
//   Nao precisamos de nenhuma logica de decodificacao -- a saida
//   e simplesmente o proprio vetor de estado!
//
//     state = 4'b0001 (S0) -> leds = 4'b0001 -> apenas LEDR[0] aceso
//     state = 4'b0010 (S1) -> leds = 4'b0010 -> apenas LEDR[1] aceso
//     ...
// -----------------------------------------------------------------------------
assign leds = state;

endmodule
