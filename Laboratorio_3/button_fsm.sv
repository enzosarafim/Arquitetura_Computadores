module button_fsm (
    input  logic        clk,    // Clock
    input  logic        rst,
    input  logic        rst_n,  // Reset assincrono, ativo baixo 
    input  logic [3:0] btn,    // Botao de avanco, ativo baixo  
    output logic [3:0] leds,   // LEDs indicadores de estado
    output logic        unlock 
);

localparam logic [3:0] BTN_AZUL    = 4'b0001;  // Botao 1
localparam logic [3:0] BTN_AMARELO = 4'b0010;  // Botao 2
localparam logic [3:0] BTN_VERDE   = 4'b0100;  // Botao 3
localparam logic [3:0] BTN_VERMELHO= 4'b1000;  // Botao 4

typedef enum logic [3:0] {
    S0 = 4'b0000,   // Estado inicial 
    S1 = 4'b0001,   // Azul
    S2 = 4'b0010,   // Amarelo
    S3 = 4'b0100,   // Amarelo
    S4 = 4'b1000    // Vermelho
} state_t;

state_t state, next_state;

logic [3:0] btn_active;  
logic [3:0] btn_prev;    
logic [3:0] btn_rise;    

assign btn_active = ~btn;
assign btn_rise   = btn_active & ~btn_prev;  


always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) btn_prev <= 4'b0;
    else        btn_prev <= btn_active;
end


always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) state <= S0;
    else        state <= next_state;
end


always_comb begin
    next_state = state;  
    unlock     = 1'b0;   

    unique case (state)
        S0: begin 
            if (btn_rise == BTN_AZUL) next_state = S1; 
            else if (|btn_rise) next_state = S0; 
        end
        S1: begin 
            if (btn_rise == BTN_AMARELO) next_state = S2; 
            else if (|btn_rise) next_state = S0; 
        end
        S2: begin 
            if (btn_rise == BTN_AMARELO) next_state = S3; 
            else if (|btn_rise) next_state = S0; 
        end
        S3: begin 
            if (btn_rise == BTN_VERMELHO) next_state = S4; 
            else if (|btn_rise) next_state = S0; 
        end
        S4: begin 
            if (rst == 1'b0) begin
                next_state = S4;
                unlock     = 1'b1;
            end else begin
                next_state = S0;
                unlock     = 1'b0;
            end
        end
        default: begin
            next_state = S0;
            unlock     = 1'b0;
        end
    endcase
end


assign leds = state;

endmodule
