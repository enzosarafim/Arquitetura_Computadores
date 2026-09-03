`timescale 1ns/1ps

module button_fsm_tb;

    logic       clk;
    logic       rst;
    logic       rst_n;
    logic [3:0] btn;
    
    logic [3:0] leds;
    logic       unlock;

    button_fsm dut (
        .clk    (clk),
        .rst    (rst),
        .rst_n  (rst_n),
        .btn    (btn),
        .leds   (leds),
        .unlock (unlock)
    );

    localparam logic [3:0] BTN_AZUL     = 4'b0001;
    localparam logic [3:0] BTN_AMARELO  = 4'b0010;
    localparam logic [3:0] BTN_VERDE    = 4'b0100;
    localparam logic [3:0] BTN_VERMELHO = 4'b1000;

    
    initial clk = 0;
    always #10 clk = ~clk;

    task press_button(input logic [3:0] btn_mask, input int hold_cycles);
        @(negedge clk);
        btn = ~btn_mask;               // Aplica ativo baixo (ex: Azul 0001 -> 1110)
        repeat (hold_cycles) @(posedge clk);
        @(negedge clk);
        btn = 4'b1111;                 // Solta todos (todos os bits 1)
        repeat (3) @(posedge clk);     // Aguarda estabilizar
    endtask

   
    task check_state(input logic [3:0] expected_leds, input logic expected_unlock, input string msg);
        @(negedge clk);
        if (leds === expected_leds && unlock === expected_unlock)
            $display("[PASS] %s | leds = 4'b%04b | unlock = %b", msg, leds, unlock);
        else
            $display("[FAIL] %s | ESPERADO: leds=4'b%04b unlock=%b | OBTIDO: leds=4'b%04b unlock=%b",
                     msg, expected_leds, expected_unlock, leds, unlock);
    endtask

    
    initial begin
        // Dump de formas de onda para visualizacao no GTKWave
        $dumpfile("button_fsm.vcd");
        $dumpvars(0, button_fsm_tb);

      
        rst_n = 1'b1;
        rst   = 1'b0;
        btn   = 4'b1111;  // Todos botoes soltos (ativo baixo)

       
        $display("\n=== Teste 1: Reset Assincrono ===");
        rst_n = 1'b0;
        repeat (3) @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);
        
        check_state(4'b0000, 1'b0, "Apos reset_n -> S0");

        
        $display("\n=== Teste 2: Sequencia de Destravamento Correta ===");
        
        press_button(BTN_AZUL, 2);
        check_state(4'b0001, 1'b0, "Apertou AZUL    -> S1");
        
        press_button(BTN_AMARELO, 2);
        check_state(4'b0010, 1'b0, "Apertou AMARELO -> S2");
        
        press_button(BTN_AMARELO, 2);
        check_state(4'b0100, 1'b0, "Apertou AMARELO -> S3");
        
        press_button(BTN_VERMELHO, 2);
        check_state(4'b1000, 1'b1, "Apertou VERMELHO -> S4 (COFRE ABERTO!)");

        
        $display("\n=== Teste 3: Travar o Cofre (Reset Sincrono) ===");
        @(negedge clk);
        rst = 1'b1; // Aciona travamento
        repeat (2) @(posedge clk);
        rst = 1'b0; // Solta
        check_state(4'b0000, 1'b0, "Apos rst = 1 -> Volta para S0 (COFRE FECHADO)");

        
        $display("\n=== Teste 4: Tentativa com Erro (Azul -> Verde -> Amarelo) ===");
        
        press_button(BTN_AZUL, 2);
        check_state(4'b0001, 1'b0, "Apertou AZUL -> S1");
        
        press_button(BTN_VERDE, 2); // Botao ERRADO!
        check_state(4'b0000, 1'b0, "Apertou VERDE (Errado) -> Volta para S0");

       
        $display("\n=== Teste 5: Segurar botao nao avanca estado extra ===");
        
        press_button(BTN_AZUL, 20); // Segura azul por 20 ciclos de clock
        check_state(4'b0001, 1'b0, "Segurou AZUL 20 ciclos -> Estabiliza em S1");

        $display("\n=== Simulacao concluida ===\n");
        $finish;
    end

endmodule
