# Arquitetura de Computadores
## Atividades da cadeira de Arquitetura de Computadores
<img width="236" height="290" alt="image" src="https://github.com/user-attachments/assets/b6bb4a0a-40fb-47de-bc6e-b58c45640c70" />
<img width="236" height="290" alt="image" src="https://github.com/user-attachments/assets/135839e8-fd25-4e10-b3a3-ce332c787ffc" />
<img width="236" height="290" alt="image" src="https://github.com/user-attachments/assets/ee14930d-2b7d-4849-bb1d-84a0d4bb375b" />
<img width="236" height="290" alt="image" src="https://github.com/user-attachments/assets/24bd9c76-54bd-4e71-a402-c9709593095c" />
<img width="236" height="290" alt="image" src="https://github.com/user-attachments/assets/d27632ec-0541-4f32-abc7-3567100d7394" />
<img width="236" height="290" alt="image" src="https://github.com/user-attachments/assets/85bd33bc-f03d-4a2f-af8c-87a6c5b64ee6" />
<img width="236" height="290" alt="Gohan sem entender" src="https://github.com/user-attachments/assets/39e45eb3-c125-4afa-add9-24d4e1420d0a" />
<img width="236" height="290" alt="Goku" src="https://github.com/user-attachments/assets/1beac881-d11f-408b-aa3e-4fcc88aaa861" />
<img width="236" height="290" alt="piccolo aura farm" src="https://github.com/user-attachments/assets/c77eabe3-b041-4d14-ae46-5a310528c707" />


## Grupo:
* Enzo Nogueira Sarafim (ens2)
* Gabriel Marins Zarour (gmz)
* Kayque Tavares Marcelino da Costa (ktmc)

# RV32I Pipelined Base Project

Processador RISC-V de 32 bits com pipeline de 5 estágios implementado em SystemVerilog, baseado nas seções 4.6 a 4.10 de *Computer Organization and Design: RISC-V Edition* (Patterson & Hennessy). O projeto tem como plataforma alvo a placa **DE2-115** (Intel Cyclone IV E) e é estruturado para servir de base para extensões do conjunto de instruções pelos alunos.

---

## Instruções suportadas

| #  | Instrução | Tipo | Opcode  | Origem  |
|----|-----------|------|---------|---------|
| 1  | `ADD`     | R    | 0110011 | Base    | 
| 2  | `SUB`     | R    | 0110011 | Base    |
| 3  | `OR`      | R    | 0110011 | Base    | 
| 4  | `AND`     | R    | 0110011 | Base    |
| 5  | `SLT`     | R    | 0110011 | Base    |
| 6  | `LW`      | I    | 0000011 | Base    |
| 7  | `SW`      | S    | 0100011 | Base    |
| 8  | `BEQ`     | B    | 1100011 | Base    |
| 9  | `XOR`     | R    | 0110011 | Etapa 1 |
| 10 | `SLL`     | R    | 0110011 | Etapa 1 |
| 11 | `SRL`     | R    | 0110011 | Etapa 1 |
| 12 | `SRA`     | R    | 0110011 | Etapa 1 |
| 13 | `SLTU`    | R    | 0110011 | Etapa 1 |
| 14 | `ADDI`    | I    | 0010011 | Etapa 2 |
| 15 | `ANDI`    | I    | 0010011 | Etapa 2 |
| 16 | `ORI`     | I    | 0010011 | Etapa 2 |
| 17 | `SLTI`    | I    | 0010011 | Etapa 2 |
| 18 | `SLLI`    | I    | 0010011 | Etapa 2 |
| 19 | `SRLI`    | I    | 0010011 | Etapa 2 |
| 20 | `SRAI`    | I    | 0010011 | Etapa 2 |
| 21 | `XORI`    | I    | 0010011 | Etapa 2 |
| 22 | `LUI`     | U    | 0110111 | Etapa 2 |
| 23 | `AUIPC`   | U    | 0010111 | Etapa 2 |
| 24 | `LB`      | I    | 0000011 | Etapa 3 |
| 25 | `LH`      | I    | 0000011 | Etapa 3 |
| 26 | `LBU`     | I    | 0000011 | Etapa 3 |
| 27 | `LHU`     | I    | 0000011 | Etapa 3 |
| 28 | `SB`      | S    | 0100011 | Etapa 3 |
| 29 | `SH`      | S    | 0100011 | Etapa 3 |
| 30 | `BNE`     | B    | 1100011 | Etapa 3 |
| 31 | `BLT`     | B    | 1100011 | Etapa 3 |
| 32 | `BGE`     | B    | 1100011 | Etapa 3 |
| 33 | `BLTU`    | B    | 1100011 | Etapa 3 |
| 34 | `BGEU`    | B    | 1100011 | Etapa 3 |
| 35 | `JAL`     | J    | 1101111 | Etapa 3 |
| 36 | `JALR`    | I    | 1100111 | Etapa 3 |
| 37 | `SLTIU`   | I    | 0010011 | Extra   |

`SLTIU` não consta da lista da Etapa 2, mas usa a mesma decodificação de `SLTU` e funciona sem hardware adicional.

---

### Cobertura do ISA RV32I

---

| Categoria          | Total ISA |
|--------------------|:---------:|
| R-type             | 10        |
| I-type aritmético  | 9         |
| I-type load        | 5         |
| S-type             | 3         |
| B-type             | 6         |
| U-type             | 2         |
| J-type (`JAL`, `JALR`) | 2     |
| **Total**          | **37**    |


---

## Arquitetura

### Pipeline de 5 estágios

```
+------+     +------+     +------+     +------+     +------+
|  IF  | --> |  ID  | --> |  EX  | --> | MEM  | --> |  WB  |
+------+     +------+     +------+     +------+     +------+
  Busca      Decode       Execução     Memória     Write-back
  instrução  Regs         ALU          dmem/MMIO   Regfile
             Sign-ext     Desvios/jumps
```

**Registradores de pipeline:** `IF/ID`, `ID/EX`, `EX/MEM`, `MEM/WB` (definidos em `pl_pipe_pkg.sv`).

### Tratamento de hazards

| Hazard | Mecanismo | Detalhe |
|--------|-----------|---------|
| RAW (dado) | Forwarding | EX/MEM → EX e MEM/WB → EX (`pl_forward.sv`) |
| Load-use | Stall | 1 bolha inserida em ID/EX (`pl_hazard.sv`) |
| Desvio tomado, `JAL`, `JALR` | Flush | 2 NOPs (IF e ID) na resolução em EX (`pl_datapath.sv`) |

**Resolução de desvios e jumps no estágio EX:** Quando um desvio é tomado, ou em qualquer `JAL`/`JALR`, o PC vai para o alvo e os dois estágios anteriores são esvaziados. O custo é de 2 ciclos por desvio tomado ou jump.

| Instrução | Condição (sobre `rs1` e `rs2` após forwarding) | Destino |
|-----------|-----------------------------------------------|---------|
| `BEQ` / `BNE` | igual / diferente | PC + imm |
| `BLT` / `BGE` | menor / maior ou igual, com sinal | PC + imm |
| `BLTU` / `BGEU` | menor / maior ou igual, sem sinal | PC + imm |
| `JAL` | sempre; `rd` = PC + 4 | PC + imm |
| `JALR` | sempre; `rd` = PC + 4 | (`rs1` + imm) com o bit 0 zerado |

A condição vem de um comparador próprio no estágio EX, ligado aos operandos já adiantados; a ALU não participa dos desvios.

**Banco de registradores com escrita em negedge:** A escrita ocorre na borda de descida do clock, garantindo que o estágio ID leia o valor atualizado no próximo posedge sem necessidade de forwarding WB → ID explícito.

**Load-use com campos que não são registradores:** `pl_hazard` compara `inst[19:15]` e `inst[24:20]` com o `rd` de um load sem olhar o formato da instrução.

### Operandos da ALU

| Sinal | Valor | Operando | Usado por |
|-------|-------|----------|-----------|
| `ALUSrcA` | `00` | `rs1` (após forwarding) | R-type, I-type, loads, stores, `JALR` |
| `ALUSrcA` | `01` | PC da instrução | `AUIPC` |
| `ALUSrcA` | `10` | zero | `LUI` |
| `ALUSrc` | `0` | `rs2` (após forwarding) | R-type |
| `ALUSrc` | `1` | Imediato | I-type, loads, stores, `LUI`, `AUIPC`, `JALR` |

O mux de `ALUSrcA` fica depois do forwarding: em `LUI` e `AUIPC`, o campo `rs1` é parte do imediato e não pode trazer o valor de um registrador recente.

### Mapa de memória

| Endereço (byte) | Tamanho | Acesso | Descrição |
|-----------------|---------|--------|-----------|
| `0x000 – 0x3FC` | 256 × 32 b | R/W | Memória de dados (`pl_dmem`) |
| `0x400` | 32 b | R | SW\[17:0\] — chaves deslizantes |
| `0x404` | 32 b | R | KEY\[3:0\] — botões push |
| `0x408` | 32 b | W | LEDR\[17:0\] — LEDs vermelhos |
| `0x40C` | 32 b | W | LEDG\[8:0\] — LEDs verdes |
| `0x410` | 32 b | R/W | UART RS-232 (8N1, 9600 baud) |
| `0x414` | 32 b | R | Contador de ciclos de clock (32 bits, reset em 0) |

Seleção: `alu_result[10] = 1` redireciona o acesso ao controlador MMIO (`pl_mmio`).

**Leitura da UART (`lw` em 0x410):** `{22'b0, tx_busy[9], rx_ready[8], rx_data[7:0]}`

**Loads e stores de byte e meia palavra:** A memória de dados é sempre lida e gravada por palavra. `LB`, `LH`, `LBU` e `LHU` escolhem o byte ou a meia palavra pelos 2 bits baixos do endereço e estendem com ou sem sinal no estágio MEM. `SB` e `SH` aproveitam a leitura assíncrona: no mesmo ciclo, leem a palavra atual, trocam só os bytes do store e gravam a palavra inteira. Os endereços precisam estar alinhados ao tamanho do acesso; acessos desalinhados não são suportados.

**Escrita na UART (`sw` em 0x410):** O hardware (`pl_mmio`) divide automaticamente a palavra de 32 bits em 4 bytes e os envia em sequência little-endian (byte 0 primeiro). `tx_busy` permanece alto até o último byte ser aceito pelo shift register. O software deve aguardar `tx_busy = 0` antes de escrever nova palavra.

### ALU — codificação de operação

| Operation | Instrução |
|-----------|-----------|
| `4'd01` ADD  | ADD, ADDI, loads, stores, LUI, AUIPC, JALR |
| `4'd02` SUB  | SUB |
| `4'd03` XOR  | XOR, XORI |
| `4'd04` OR   | OR, ORI |
| `4'd05` AND  | AND, ANDI |
| `4'd06` SLL  | SLL, SLLI |
| `4'd07` SRL  | SRL, SRLI |
| `4'd08` SRA  | SRA, SRAI |
| `4'd11` SLT  | SLT, SLTI |
| `4'd12` SLTU | SLTU, SLTIU |

`ALUOp` vale `00` para forçar ADD, `01` para desvios (resultado não usado), `10` para R-type e `11` para I-type aritmético. R-type e I-type têm valores separados porque, em I-type, `inst[30]` é parte do imediato: `ADDI` com imediato negativo não pode virar `SUB`. Os deslocamentos usam só `SrcB[4:0]`.

---

## Estrutura do repositório

```
rv32i_pipelined_base_project/
│
├── src/                        Código-fonte SystemVerilog
│   ├── pl_pipe_pkg.sv          Structs dos registradores de pipeline
│   ├── pl_top.sv               Top-level (PLL 50→10 MHz + CPU)
│   ├── pl_cpu.sv               Wrapper: Control + ALU_Ctrl + Datapath
│   ├── pl_control.sv           Unidade de controle (estágio ID)
│   ├── pl_alu_ctrl.sv          Controle da ALU (estágio EX)
│   ├── pl_alu.sv               ALU 32 bits
│   ├── pl_regfile.sv           Banco de registradores 32×32 b
│   ├── pl_sign_ext.sv          Geração de imediatos I/S/B/U/J
│   ├── pl_imem.sv              Memória de instruções 256×32 b (MIF)
│   ├── pl_dmem.sv              Memória de dados 256×32 b (MIF)
│   ├── pl_mmio.sv              Controlador MMIO (SW/KEY/LED/UART)
│   ├── pl_uart.sv              UART RS-232 8N1 (9600 baud, clock configurável)
│   ├── pl_hazard.sv            Detecção de hazard load-use
│   ├── pl_forward.sv           Unidade de forwarding
│   ├── pl_datapath.sv          Datapath 5 estágios
│   ├── pl_cpu_tb.sv            Testbench de verificação
│   └── pll_10mhz.v             PLL Altera (50 MHz → 10 MHz)
│
├── mifs/                       Arquivos de inicialização de memória
│   ├── board_test_program.mif  Teste da placa: SW→LEDR, KEY→LEDG, LEDG[8] pisca
│   ├── board_test_data.mif     Dados do teste da placa
│   ├── instruction_halt_serial.mif  Envia "HALT!" e pisca LEDG
│   ├── data_halt_serial.mif    Dados do programa acima
│   ├── mmio_test_program.mif   Programa de teste MMIO + UART
│   └── mmio_test_data.mif      Dados para o teste MMIO
│
├── assembler/
│   ├── assembler.py            Montador Python: assembly → .mif / dump
│   ├── hello.asm               Programa de entrada padrão
│   ├── hello_e1.asm            Teste das etapas 1 e 2
│   ├── hello_e2.asm            Teste da etapa 3
│   ├── instruction.mif         MIF gerado (saída do assembler)
│   ├── data.mif                MIF de dados gerado (modo --dump)
│   └── program.hex             Hex gerado (modo normal)
│
├── dump/
│   └── serial_dump.py          Captura e decodifica dump serial do FPGA
│
├── modelsim/                   Projeto ModelSim para simulação
│   ├── *.mpf                   Arquivo de projeto ModelSim
│   ├── program.hex             Imagem da instrução (.hex para $readmemh)
│   ├── data.hex                Imagem dos dados (.hex para $readmemh)
│   ├── golden.txt              Saída esperada pelo testbench
│   └── output.txt              Saída gerada na última simulação
│
└── quartus/                    Projeto Quartus Prime para síntese
    ├── *.qpf / *.qsf           Arquivos de projeto Quartus
    ├── pl_top.sdc              Restrições de timing
    ├── instruction.mif         MIF da instrução (cópia de trabalho)
    └── data.mif                MIF dos dados (cópia de trabalho)
```

---

## Como simular (ModelSim)

1. Abra o ModelSim e carregue o projeto `modelsim/rv32i_pipelined_base_project.mpf`.
2. Compile todos os arquivos em `src/` — compilar `pl_pipe_pkg.sv` primeiro.
3. Inicie a simulação com o top `pl_cpu_tb`.
4. Execute `run -all`.

**Programa de teste padrão (`modelsim/program.hex`):**

```
000: lw  x1,  0(x0)   x1 = 10
001: lw  x2,  4(x0)   x2 = 20
002: add x3, x1, x2   x3 = 30   -- forwarding MEM/WB→EX
003: and x4, x3, x1   x4 = 10   -- forwarding EX/MEM→EX
004: lw  x5,  0(x0)   x5 = 10   -- causa load-use stall
005: add x6, x5, x2   x6 = 30   -- executado após 1 ciclo de stall
006: sw  x3,  8(x0)   dmem[2] = 30
007: beq x1, x2, +8   NÃO tomado (10 ≠ 20)
008: add x7, x1, x2   x7 = 30
009: beq x1, x5, +8   TOMADO (10 = 10) → flush de 00A
00A: add x8, x0, x0   DESCARTADO
00B: add x8, x1, x4   x8 = 20
00C: beq x0, x0,  0   halt
```

Estado final esperado: `x1=10  x2=20  x3=30  x4=10  x5=10  x6=30  x7=30  x8=20  dmem[2]=30`

---

## Como sintetizar (Quartus)

1. Abra o Quartus Prime e carregue `quartus/rv32i_pipelined_base_project.qpf`.
2. Verifique que os arquivos `instruction.mif` e `data.mif` estão na pasta `quartus/`. Por padrão eles contêm o teste da placa (`mifs/board_test_*.mif`).
3. Execute **Processing → Start Compilation**.
4. Na DE2-115, ligue a placa, deixe a chave SW19 em **RUN** e conecte o cabo USB na porta **USB-Blaster**.
5. Abra **Tools → Programmer**, selecione o **USB-Blaster** em *Hardware Setup*, modo **JTAG**, adicione `quartus/output_files/rv32i_pipelined_base_project.sof`, marque **Program/Configure** e clique em **Start**.

Para trocar de programa, copie o par de `.mif` desejado para `quartus/` com os nomes `instruction.mif` e `data.mif` e recompile. Os dois arquivos entram no bitstream.

**Dispositivo alvo:** Intel Cyclone IV E — EP4CE115F29C7  
**Clock:** 50 MHz (entrada) → 10 MHz (saída da PLL, usado pelo CPU)  
**Reset:** KEY\[0\] ativo-baixo; liberado após a PLL travar.

---

## LEDs, chaves e botões na placa

O hardware só define **onde** cada periférico fica no mapa de memória. Quem decide o que um LED mostra é o programa carregado: sem um `sw` para `0x408` ou `0x40C`, os LEDs ficam apagados mesmo com a CPU funcionando. Da mesma forma, as chaves não têm efeito se o programa não usar o valor lido de `0x400`.

Níveis lógicos: chave para cima = 1; botão solto = 1 e pressionado = 0; LED aceso = 1.

### O que é fixo no hardware

| Componente | Função | Endereço |
|------------|--------|----------|
| KEY\[0\] | **Reset**: enquanto pressionado, apaga os LEDs e para a CPU; ao soltar, o programa recomeça do início | também legível em `0x404` |
| KEY\[3:1\] | Entrada livre para o programa | `0x404` |
| SW\[17:0\] | Entrada livre para o programa | `0x400` |
| LEDR\[17:0\] | Saída livre para o programa | `0x408` |
| LEDG\[8:0\] | Saída livre para o programa | `0x40C` |

O reset não restaura a memória de dados nem os registradores: para voltar ao conteúdo original do `.mif`, grave o bitstream de novo.

### O que cada programa mostra

| Programa (`mifs/`) | LEDR | LEDG | SW | KEY\[3:1\] | Serial |
|--------------------|------|------|----|------------|--------|
| `board_test_*` (padrão) | Acompanham SW\[17:0\] | \[8\] pisca (≈0,84 s aceso e ≈0,84 s apagado); \[3:1\] acendem com KEY\[3:1\] pressionado; \[7:4\] e \[0\] apagados | Controlam o LEDR de mesmo número | Controlam o LEDG de mesmo número | Não usa |
| `instruction_halt_serial` + `data_halt_serial` | Apagados | Alternam entre `0x55` e `0xAA` a cada ≈1 s; \[8\] apagado | Sem efeito | Sem efeito | Envia `HALT!` uma vez |
| `mmio_test_*` | Padrão fixo `0x2AAAA` (números ímpares acesos) | Padrão fixo `0x155` (números pares acesos) | Lidas uma vez após o reset, sem efeito visível | Lidos uma vez após o reset, sem efeito visível | Espera um espaço e responde `Ola, Mundo!` |
| Gerado com `assembler.py --dump` | Apagados | Todos acesos = dump serial concluído | Sem efeito | Sem efeito | Envia o dump |

A serial envia sempre 4 bytes por `sw`: em `HALT!` e `Ola, Mundo!`, cada caractere vem seguido de três bytes `0x00`.

### Como interpretar o teste da placa

- **LEDG\[8\] piscando:** clock, PLL e CPU estão executando o programa.
- **Tudo apagado:** verifique se o bitstream foi gravado e se KEY\[0\] não está pressionado. Com a compilação correta, o LEDG\[8\] nunca fica parado.
- **LEDR acompanhando as chaves:** leitura de `0x400` e escrita em `0x408` funcionando.

---

## Assembler

O script `assembler/assembler.py` converte assembly textual para o formato `.mif`.

### Uso

```bash
cd assembler

# modo normal — gera instruction.mif + program.hex
python3 assembler.py programa.asm

# sem argumento — usa instructions.txt como padrão
python3 assembler.py

# modo dump — gera instruction.mif + data.mif com dump serial embutido
python3 assembler.py --dump programa.asm
```

Todos os arquivos de saída são gerados na pasta `assembler/`.

### Modo normal

| Arquivo | Formato | Uso |
|---------|---------|-----|
| `instruction.mif` | Quartus MIF | Síntese (Quartus) e simulação (ModelSim via `ram_init_file`) |
| `program.hex` | Um word hex por linha | Simulação via `$readmemh` |

### Modo `--dump`

Anexa automaticamente o código de dump serial ao programa do usuário, sem que o usuário precise escrever nenhuma instrução extra.

| Arquivo | Conteúdo |
|---------|----------|
| `instruction.mif` | Código do usuário + `beq` de desvio + dump serial a partir de `0x080` |
| `data.mif` | Zeros + constantes de infraestrutura do dump em `0x080–0x086` |

**Layout da memória de instruções com `--dump`:**

```
0x000..N-1  Código do usuário (máx. 127 instruções)
0xN         beq x0,x0,→0x80   (desvio incondicional para o dump)
0xN+1..07F  NOP (addi x0,x0,0)
0x080..0x0AD  Dump serial — Parts 2–8 (46 instruções)
```

**Layout da memória de dados com `--dump`:**

```
0x000..0x01F  Área do usuário  (byte 0x000–0x07C) — transmitida no dump
0x078..0x07F  Saves de x1–x8  (byte 0x1E0–0x1FC) — escritos em runtime
0x080..0x086  Constantes de infraestrutura         — inicializadas no MIF
```

**O que o dump transmite via UART (164 bytes = 41 palavras):**

```
bytes  0–  3   Contador de ciclos (MMIO 0x414)
bytes  4– 35   Registradores x1–x8
bytes 36–163   dmem[0x000–0x07C] (32 palavras do usuário)
```

O programa do usuário pode ter no máximo **127 instruções**; o assembler valida e reporta erro se excedido.

Se o programa terminar com `beq x0,x0,0` (o halt usado na simulação), essa última linha é trocada pelo desvio para o dump, e o assembler avisa. Sem a troca, o programa ficaria preso no halt e o dump nunca seria enviado.

### Formato de entrada aceito

```
add x3,x1,x2
addi x12,x0,-16
slli x5,x10,2
lw x1,0(x0)
lbu x4,3(x0)
sw x3,8(x0)
sh x1,6(x0)
beq x1,x2,-4
bltu x2,x1,+8
lui x6,0x12345
auipc x7,1
jal x1,+16
jalr x0,x1,0
```

Uma instrução por linha, com um único espaço após o nome e nenhum espaço depois das vírgulas, sem rótulos e sem comentários. O argumento de arquivo é opcional — o padrão é `instructions.txt`.

| Campo | Faixa aceita |
|-------|--------------|
| Imediato I e S | -2048 a 2047, em decimal |
| Deslocamento de desvio (B) | -2048 a 2046, par, em decimal (`+8` também é aceito) |
| Deslocamento de `JAL` | -524288 a 524286, par, em decimal |
| Deslocamento (`SLLI`, `SRLI`, `SRAI`) | 0 a 31, em decimal |
| Imediato U (`LUI`, `AUIPC`) | -524288 a 1048575, em decimal ou `0x...` |

---

## Detalhes de implementação

### Banco de registradores — escrita em negedge

A escrita no banco de registradores ocorre na **borda de descida** do clock (`negedge clk`). Isso resolve o conflito de leitura/escrita simultânea que ocorre quando, após um load-use stall, o estágio WB escreve um registrador no mesmo ciclo em que o estágio ID o lê para captura no registrador ID/EX. Com a escrita em negedge, o valor é garantidamente visível antes do próximo posedge.

O banco usa `(* ramstyle = "logic" *)` para ser sintetizado em registradores. Sem isso, o Quartus o coloca em blocos M9K, cuja leitura é registrada na borda de subida e não enxerga a escrita feita na borda de descida, e o hardware passa a divergir da simulação.

### Detecção de halt no testbench

O halt é implementado como `beq x0, x0, 0`. Com resolução de branch no estágio EX, o PC oscila com período 3 (H, H+4, H+8, H, …). O testbench detecta halt quando `PC_atual == PC_de_3_ciclos_atrás` por 9 ciclos consecutivos (3 períodos completos).

### UART (9600 8N1)

Implementada em `pl_uart.sv`. O parâmetro `CLK_HZ` precisa ser igual ao clock real da CPU e é definido no top-level: `pl_top` usa 10 MHz (1041 clocks/bit, baud efetivo 9606) e `pl_top_no_pll` usa 50 MHz (5208 clocks/bit, baud efetivo 9601). Nos dois casos o erro é < 0,1%. O sequenciador de 4 bytes em `pl_mmio.sv` divide automaticamente cada `sw` em 0x410 em 4 transmissões consecutivas, liberando o software de enviar byte a byte.

### Dump serial

O script `dump/serial_dump.py` captura e decodifica o dump transmitido pelo FPGA. Pré-requisito: `pip install pyserial`.

```bash
python3 dump/serial_dump.py COM3            # Windows
python3 dump/serial_dump.py /dev/ttyUSB0   # Linux
python3 dump/serial_dump.py COM3 --out resultado.txt
```

Aguarda **164 bytes** (41 palavras × ~4 ms a 9600 baud) e exibe ciclos, x1–x8 e dmem[0x000–0x07C]. Para usar, compile com `python3 assembler.py --dump` e grave o bitstream no FPGA.

**Fluxo completo:**

```bash
cd assembler
python3 assembler.py --dump meu_programa.asm  # gera instruction.mif + data.mif
cp instruction.mif data.mif ../quartus/        # copia para o projeto Quartus
# compilar e gravar na FPGA via Quartus...
cd ../dump
python3 serial_dump.py COM3                    # captura o resultado
```

---

## Teste das etapas 1 e 2 (`hello_e1.asm`)

`assembler/hello_e1.asm` monta as próprias constantes com `addi` e grava cada resultado na memória de dados. Por isso, o `data.mif` gerado não precisa de nenhuma edição manual.

```bash
cd assembler
python assembler.py --dump hello_e1.asm
cp instruction.mif ../quartus/
cp data.mif ../quartus/
# compile e grave na FPGA pelo Quartus
cd ..
python dump/serial_dump.py COM3 --timeout 60   # troque COM3 pela porta do seu adaptador serial
# com o script aguardando, aperte e solte KEY[0]
```

Quando o dump termina, todos os LEDs verdes acendem. O relatório mostra a memória por endereço em bytes, e `dmem[N]` fica no endereço `N × 4`:

| `dmem` | Endereço | Instrução | Hex | Decimal (com sinal) |
|--------|----------|-----------|-----|---------------------|
| 0  | `0x000` | `addi x1,x0,42`   | `0x0000002A` | 42 |
| 1  | `0x004` | `andi x2,x10,12`  | `0x00000008` | 8 |
| 2  | `0x008` | `ori x3,x10,5`    | `0x0000000F` | 15 |
| 3  | `0x00C` | `slti x4,x12,0`   | `0x00000001` | 1 |
| 4  | `0x010` | `slli x5,x10,2`   | `0x00000028` | 40 |
| 5  | `0x014` | `srli x6,x12,4`   | `0x0FFFFFFF` | 268435455 |
| 6  | `0x018` | `srai x7,x12,2`   | `0xFFFFFFFC` | -4 |
| 7  | `0x01C` | `xor x1,x10,x13`  | `0x0000000C` | 12 |
| 8  | `0x020` | `sll x2,x10,x11`  | `0x00000050` | 80 |
| 9  | `0x024` | `srl x3,x12,x11`  | `0x1FFFFFFE` | 536870910 |
| 10 | `0x028` | `sra x4,x12,x11`  | `0xFFFFFFFE` | -2 |
| 11 | `0x02C` | `sltu x5,x10,x12` | `0x00000001` | 1 |

O restante da área `0x030–0x07C` fica em zero. O relatório também deve mostrar `cycles = 50` e, nos registradores, `x1=0x0000000C`, `x2=0x00000050`, `x3=0x1FFFFFFE`, `x4=0xFFFFFFFE`, `x5=0x00000001`, `x6=0x0FFFFFFF`, `x7=0xFFFFFFFC` e `x8=0x00000000`.

---

## Teste da etapa 3 (`hello_e2.asm`)

`assembler/hello_e2.asm` grava `-107` com `sb` e `sh`, lê de volta com os quatro loads novos e testa cada desvio e jump. Cada desvio pula um `addi` que zeraria a flag correspondente, então `1` significa que o desvio foi tomado como esperado. O fluxo é o mesmo da etapa anterior, trocando o nome do arquivo:

```bash
cd assembler
python assembler.py --dump hello_e2.asm
cp instruction.mif ../quartus/
cp data.mif ../quartus/
# compile e grave na FPGA pelo Quartus
cd ..
python dump/serial_dump.py COM3 --timeout 60   # troque COM3 pela porta do seu adaptador serial
# com o script aguardando, aperte e solte KEY[0]
```

O arquivo termina com `beq x0,x0,0`. No modo `--dump`, o assembler troca essa linha pelo desvio para o dump e mostra um aviso.

| `dmem` | Endereço | Instrução testada | Hex | Decimal (com sinal) |
|--------|----------|-------------------|-----|---------------------|
| 0  | `0x000` | `lb x3,0(x0)`      | `0xFFFFFF95` | -107 |
| 1  | `0x004` | `lbu x4,0(x0)`     | `0x00000095` | 149 |
| 2  | `0x008` | `lh x5,4(x0)`      | `0xFFFFFF95` | -107 |
| 3  | `0x00C` | `lhu x6,4(x0)`     | `0x0000FF95` | 65429 |
| 4  | `0x010` | `lui x7,3`         | `0x00003000` | 12288 |
| 5  | `0x014` | `auipc x8,0` (PC = 36) | `0x00000024` | 36 |
| 6  | `0x018` | `bne x1,x2,+8`     | `0x00000001` | 1 |
| 7  | `0x01C` | `blt x1,x2,+8`     | `0x00000001` | 1 |
| 8  | `0x020` | `bge x2,x1,+8`     | `0x00000001` | 1 |
| 9  | `0x024` | `bltu x2,x1,+8`    | `0x00000001` | 1 |
| 10 | `0x028` | `bgeu x1,x2,+8`    | `0x00000001` | 1 |
| 11 | `0x02C` | `jal x16,+8` (`x16` = 108) | `0x00000001` | 1 |
| 12 | `0x030` | `jalr x18,x16,20` (`x18` = 124) | `0x00000001` | 1 |

O restante da área `0x034–0x07C` fica em zero. O relatório também deve mostrar `cycles = 76` e, nos registradores, `x1=0xFFFFFF95`, `x2=0x00000032`, `x3=0xFFFFFF95`, `x4=0x00000095`, `x5=0xFFFFFF95`, `x6=0x0000FF95`, `x7=0x00003000` e `x8=0x00000024`.

---

## Recursos

- [Manual RISC-V ISA v2.2](https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf)
- [RISC-V ISA Reference (msyksphinz)](https://msyksphinz-self.github.io/riscv-isadoc/html/rvi.html)
- [RISC-V Interpreter — Cornell University](https://www.cs.cornell.edu/courses/cs3410/2019sp/riscv/interpreter/)
- Patterson & Hennessy, *Computer Organization and Design: RISC-V Edition*, seções 4.6 – 4.10
