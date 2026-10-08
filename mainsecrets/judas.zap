// Exemplo básico em Zap (.zap)

// Definição de uma estrutura de dados
struct Jogador {
    id: u32,
    nome: string,
    pontuacao: u64,
    ativo: bool,
}

// Definição de eventos/mensagens de rede
event MoverJogador {
    posicao_x: f32,
    posicao_y: f32,
}

event AtualizarPlacar {
    jogadores: []Jogador,
}
