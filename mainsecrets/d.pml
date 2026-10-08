/*
*  Exemplo básico em Promela (.pml)
*  Comunicação entre dois processos (Produtor e Consumidor)
*/

// Canal de comunicação síncrono (tamanho 0) que transmite inteiros
chan canal = [0] of { int };

// Processo Produtor
proctype Produtor() {
    int i = 1;
    
    // Loop de envio de 1 até 3
    do
    :: i <= 3 ->
        printf("Produtor: Enviando valor %d\n", i);
        canal ! i; // Envia o valor 'i' pelo canal
        i++;
    :: i > 3 -> 
        break;     // Sai do loop
    od;
    
    printf("Produtor: Finalizado.\n");
}

// Processo Consumidor
proctype Consumidor() {
    int valor_recebido;
    int contador = 0;

    do
    :: contador < 3 ->
        canal ? valor_recebido; // Recebe a mensagem do canal
        printf("Consumidor: Recebeu o valor %d\n", valor_recebido);
        contador++;
    :: contador == 3 ->
        break;
    od;

    printf("Consumidor: Finalizado.\n");
}

// Processo inicial (entry point)
init {
    // Inicializa ambos os processos em paralelo
    run Produtor();
    run Consumidor();
}
