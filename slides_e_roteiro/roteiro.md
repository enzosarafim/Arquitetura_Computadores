# Roteiro Expandido: Multiprocessadores e Redes (Sessões 6.7 e 6.8)
*Baseado no livro Computer Organization and Design RISC-V Edition com insights adicionais da indústria.*

---

## Slide 1: Introdução (Capa)
* **Tempo sugerido:** 1 minuto
* **Resumo do Livro:** Apresentação do tema que estende o paralelismo de um único chip para milhares de máquinas conectadas.
* **Ponto Extra (Além do Livro):** A arquitetura RISC-V, tema do livro, está sendo cada vez mais adotada na criação de aceleradores customizados em datacenters (como os chips do Google e Meta), conectando perfeitamente os conceitos da ISA com a infraestrutura em larga escala.
* **O que falar:** 
  * "Olá a todos. Nossa equipe, composta por Enzo, Gabriel e Kayque, apresentará hoje as sessões 6.7 e 6.8 do livro de Patterson e Hennessy."
  * "O objetivo aqui é sair do escopo de apenas um processador e entender a arquitetura na sua escala máxima: Multiprocessadores, Clusters, gigantescos Datacenters (WSCs) e as intrincadas Redes que permitem que milhares de CPUs conversem entre si."

---

## Slide 2: Divisor - Sessão 6.7
* **Tempo sugerido:** 30 segundos
* **O que falar:** "Vamos começar pela sessão 6.7, que foca na construção de sistemas através do agrupamento de computadores independentes."

---

## Slide 3: Clusters
* **Tempo sugerido:** 2 minutos
* **Resumo do Livro:** Clusters são coleções de computadores independentes (nós) conectados por uma rede local usando hardware de prateleira (COTS - Commercial Off-The-Shelf). A comunicação se dá por passagem de mensagens.
* **Ponto Extra (Além do Livro):** Diferente do modelo SMP (Symmetric Multiprocessing) onde todas as CPUs compartilham a mesma RAM física, os clusters usam arquitetura "Shared-Nothing". Isso força os desenvolvedores a usarem bibliotecas complexas como o MPI (Message Passing Interface) ou frameworks como o Apache Spark.
* **O que falar:** 
  * "Um Cluster nasce de uma premissa econômica: é mais barato comprar 100 servidores comuns (COTS) do que um único supercomputador customizado equivalente."
  * "Cada nó nesse cluster tem seu próprio sistema operacional, sua própria CPU e, o mais importante, sua própria Memória RAM."
  * "Como eles não dividem a mesma memória, a programação precisa ser feita via *Message Passing* (troca de mensagens pela rede). O pioneiro nisso foi o projeto Beowulf nos anos 90."

---

## Slide 3.5: Virtual Machines (VMs) em Produção
* **Tempo sugerido:** 2 minutos
* **Resumo do Livro:** O uso de hypervisors para criar múltiplas máquinas virtuais isoladas sobre um mesmo hardware físico, permitindo consolidação de servidores e segurança.
* **Ponto Extra (Além do Livro):** Na indústria, WSCs usam *Hypervisors Type 1 (Bare-metal)*, como o KVM, que rodam direto no hardware, sem um SO hospedeiro tradicional por baixo, garantindo quase 100% da performance nativa. Hoje, esse conceito evoluiu também para os *Containers* (Docker/Kubernetes).
* **O que falar:**
  * "Antigamente, colocava-se um software por servidor. Isso gerava desperdício. Hoje, usamos o Hypervisor."
  * "Essa camada de software abstrae o hardware. Com isso, ganhamos isolamento (se uma VM travar, a outra continua) e o *Resource Pooling* (fatiamento de recursos), que é a base da Nuvem (AWS, Azure)."
  * "A grande vantagem arquitetural é a *Live Migration*: podemos pegar a memória RAM de uma VM e copiá-la pela rede para outro servidor físico. O usuário que está assistindo Netflix, por exemplo, nem percebe que o servidor físico por trás foi desligado para manutenção."

---

## Slide 4: Warehouse-Scale Computers (WSC)
* **Tempo sugerido:** 1.5 minutos
* **Resumo do Livro:** A evolução dos clusters para "computadores em escala de armazém", onde dezenas de milhares de servidores atuam como uma única entidade de computação orquestrada por software.
* **Ponto Extra (Além do Livro):** Esses prédios chegam a consumir 100 Megawatts, energia suficiente para abastecer uma cidade inteira de médio porte. Para gerenciar tudo, usam-se conceitos de SDN (Redes Definidas por Software) para evitar caos no roteamento.
* **O que falar:**
  * "Aqui a escala muda. Um WSC não é apenas um prédio cheio de computadores; o prédio inteiro *é* o computador."
  * "Empresas como Google e Meta constroem esses datacenters com centenas de milhares de servidores."
  * "A orquestração não é manual. O software de gerenciamento de cluster decide sozinho onde colocar cada aplicação baseando-se no calor, energia e espaço disponível."

---

## Slide 4.5: Hierarquia de Storage em WSCs
* **Tempo sugerido:** 2 minutos
* **Resumo do Livro:** O livro destaca que o armazenamento não fica em uma única máquina, dependendo pesadamente de redundância e do sistema de arquivos distribuído.
* **Ponto Extra (Além do Livro):** Antigamente (como no Google File System original), a redundância era feita copiando o dado 3 vezes (Replicação). Hoje, por questão de custo, usam-se códigos matemáticos chamados *Erasure Coding* (como Reed-Solomon), que garantem a mesma segurança gastando 50% menos espaço de disco físico.
* **O que falar:**
  * "Como se guarda dados nessa escala? Nós temos o DAS (Direct Attached Storage), que são discos muito rápidos ligados na própria placa-mãe para acesso imediato e cache."
  * "Temos as SANs/NAS para bancos de dados especializados. Mas a verdadeira revolução são os Distributed File Systems."
  * "Softwares como o HDFS quebram arquivos gigantes (de Terabytes) em bloquinhos de 64MB e espalham isso por milhares de discos baratos. Se um rack queimar, o sistema constrói o dado perdido a partir dos fragmentos em outros racks."

---

## Slide 5: Desafios Operacionais em WSCs
* **Tempo sugerido:** 2.5 minutos
* **Resumo do Livro:** Custos dominados por refrigeração (PUE) e o fato de que falhas de hardware são uma certeza diária, exigindo tolerância a falhas via software.
* **Ponto Extra (Além do Livro):** A latência de cauda (*Tail Latency*). Se você tem uma tarefa rodando em 1.000 nós, a chance de UM nó estar lerdo (por um disco defeituoso, o *straggler*) é de quase 99%. WSCs usam técnicas para lançar tarefas duplicadas e aceitar a resposta do nó que terminar primeiro.
* **O que falar:**
  * "Gerenciar tudo isso traz desafios bizarros. Primeiro: Energia e Refrigeração. Usamos a métrica PUE. A física diz que cada Watt que o servidor consome vira calor. Datacenters no Alasca ou Finlândia usam 'Free Cooling' (ar gelado de fora) para manter o PUE perto de 1.0."
  * "Segundo desafio: Confiabilidade (Reliability). Se você tem 100.000 discos, a matemática pura diz que dezenas deles vão pifar toda semana. É inevitável."
  * "Por isso, a arquitetura moderna baseia-se em *Software Fault Tolerance*. O desenvolvedor do software tem que prever a queda da máquina. O hardware parou de tentar ser perfeito, o software assumiu essa responsabilidade."

---

## Slide 5.5: Perspectiva Financeira: TCO em WSCs
* **Tempo sugerido:** 1.5 minutos
* **Resumo do Livro:** TCO (Total Cost of Ownership). Análise de custos de capital vs. custos operacionais de longo prazo.
* **Ponto Extra (Além do Livro):** O ciclo de depreciação. Servidores em WSCs são trocados a cada 3 a 5 anos, enquanto o prédio e a infraestrutura elétrica (CAPEX) devem durar de 10 a 15 anos. Por isso o design elétrico é tão crítico.
* **O que falar:**
  * "Falando de dinheiro: o Custo Total de Propriedade (TCO) não é só quanto custou comprar os servidores, o CAPEX."
  * "O calcanhar de aquiles é o OPEX (Despesas Operacionais). Um servidor custa 5.000 dólares, mas pode gastar outros 6.000 em energia elétrica ao longo de 4 anos."
  * "Por isso o Google gasta milhões otimizando algoritmos em RISC-V para economizar energia, porque diminuir o OPEX de refrigeração significa um aumento direto no lucro líquido da companhia."

---

## Slide 6: Divisor - Sessão 6.8
* **Tempo sugerido:** 30 segundos
* **O que falar:** "Agora que vimos como agrupamos computadores, vamos para a sessão 6.8 entender como conectamos eles: as Topologias de Rede."

---

## Slide 7: Métricas Fundamentais de Rede
* **Tempo sugerido:** 1.5 minutos
* **Resumo do Livro:** Como comparar redes diferentes avaliando Bandwidth, Latency e Bisection Bandwidth (que avalia o pior caso de gargalo).
* **Ponto Extra (Além do Livro):** Existe a diferença entre *Bandwidth* teórica (capacidade bruta do cabo) e *Goodput* (a quantidade de dados úteis que realmente chega ao usuário após descontar os cabeçalhos de rede TCP/IP e controle de erros).
* **O que falar:**
  * "Em arquitetura, avaliamos três coisas em uma rede. Primeiro, *Bandwidth*: a largura de banda, os Gigabytes por segundo que o cabo suporta."
  * "Segundo, *Latency*: o tempo de resposta, medido em microssegundos. É a velocidade da luz misturada com a velocidade do processamento do switch."
  * "Terceiro, *Bisection Bandwidth*: imagine pegar nosso cluster e cortar a rede bem no meio. Quantos gigabytes passam por esse corte de um lado pro outro? É vital para evitar gargalos em operações de Big Data."

---

## Slide 8: Ring & Mesh
* **Tempo sugerido:** 1.5 minutos
* **Resumo do Livro:** Topologias básicas. O anel tem custo linear, enquanto a malha 2D (Mesh) melhora a bisection bandwidth mas ainda pode ter altas latências de ponta a ponta.
* **Ponto Extra (Além do Livro):** O roteamento em Mesh exige o algoritmo "Dimension-Order Routing" (ex: roteia primeiro no eixo X, depois no eixo Y) para evitar "Deadlocks", situações onde pacotes ficam travados num cruzamento para sempre.
* **O que falar:**
  * "As topologias simples estão dentro dos nossos próprios computadores."
  * "O *Anel (Ring)* foi muito usado dentro de processadores antigos da Intel para conectar os núcleos, mas ele não escala bem. A latência é enorme se você quiser falar com o nó do lado oposto."
  * "A *Mesh (Malha)* forma uma grade bidimensional, facilitando o mapeamento físico em um chip de silício. É a arquitetura base para chips modernos de Inteligência Artificial, como a TPU do Google."

---

## Slide 9: Alta Escalabilidade (Torus e Hypercube)
* **Tempo sugerido:** 2 minutos
* **Resumo do Livro:** Reduzindo o diâmetro da rede (número máximo de saltos) através de laços cruzados (Torus) e dimensões lógicas altas (Hypercube).
* **Ponto Extra (Além do Livro):** Os cabos que ligam as pontas do Torus (*wraparound links*) costumam ser os mais longos fisicamente no laboratório. Para evitar cabos gigantes no mundo físico, os arquitetos de rede embaralham as máquinas no rack em um formato chamado *Folded Torus*.
* **O que falar:**
  * "Para escalar para um supercomputador de verdade, precisamos de complexidade. O *Torus* nada mais é que um Mesh, mas onde as extremidades se conectam formando um formato de anel de fumaça (donut). O maior supercomputador japonês, o Fugaku, usa isso para evitar latências longas nas bordas."
  * "O *Hypercube* vai além. Ele adiciona dimensões conforme crescemos a rede de log(N). Uma rede 3D forma um cubo, a 4D um hipercubo. A largura de banda no meio da rede (Bisection) é colossal, mas cabear isso num datacenter sem criar um ninho de ratos de fibra óptica é quase impossível."

---

## Slide 9.5: Crossbar & Multistage Networks
* **Tempo sugerido:** 2 minutos
* **Resumo do Livro:** Crossbars permitem comunicação de todos para todos (non-blocking). Multistage utiliza camadas menores de chaves interconectadas para manter desempenho parecido com custo reduzido.
* **Ponto Extra (Além do Livro):** Em uma Crossbar antiga, sofria-se com *Head-of-Line (HOL) blocking*: se o primeiro pacote da fila estava bloqueado, atrasava os de trás. Arquiteturas modernas usam *Virtual Output Queuing (VOQ)*, que organiza os pacotes em filas separadas baseadas no destino para resolver isso.
* **O que falar:**
  * "O cenário ideal em arquitetura de rede é o *Crossbar*. É uma matriz onde há um caminho livre entre qualquer origem e qualquer destino, sem colisões."
  * "Porém, fisicamente, uma matriz crossbar exige $N \times N$ transistores de cruzamento. É irreal."
  * "A solução genial da engenharia foi o *Multistage*. Troca-se a matriz gigante por várias camadas de switches minúsculos de 2x2 portas, conectados num formato de borboleta (Omega Network). Dá resultados quase idênticos ao crossbar."

---

## Slide 9.5-cost: O Custo Oculto da Topologia
* **Tempo sugerido:** 1.5 minutos
* **Resumo do Livro:** O custo de crescimento do Crossbar ($O(N^2)$) vs Multistage ($O(N \log N)$).
* **Ponto Extra (Além do Livro):** Em WSCs, os links rápidos não são cabos de cobre simples, são *Transceivers Ópticos (AOCs)* que convertem elétron para fóton. Eles custam centenas de dólares CADA. Multiplicar isso por complexidade $O(N^2)$ quebra a empresa.
* **O que falar:**
  * "Aqui entra a visão do mundo corporativo. Como vimos na fórmula, se a rede escala de forma quadrática ($O(N^2)$), o custo do projeto deforma."
  * "Com o Multistage caindo para ($O(N \log N)$), economizamos milhões de dólares em cabos e chaves de roteamento."
  * "Hoje, num grande WSC, até 15% do valor total da instalação é apenas de cabeamento óptico e conectores. Topologia eficiente é sinônimo de lucro."

---

## Slide 10: Fat-Tree Topology
* **Tempo sugerido:** 2 minutos
* **Resumo do Livro:** O uso da árvore para escalabilidade, onde os gargalos na raiz da árvore são contornados aumentando-se a banda e número de links conforme se aproxima do topo (Fat-Tree).
* **Ponto Extra (Além do Livro):** Esta estrutura se chama formalmente *Clos Network* (inventada por Charles Clos em 1952 para redes telefônicas) e foi adaptada para computadores. Hoje em dia, Datacenters modernos evitam ter um super switch no topo e, em vez disso, usam centenas de switches menores no topo do rack agrupados (chamado arquitetura *Spine-Leaf*), que é o padrão atual da indústria.
* **O que falar:**
  * "O padrão de ouro dos grandes datacenters modernos é a *Fat-Tree* (Árvore Gorda)."
  * "Pensem numa árvore genealógica tradicional: se todos tentarem conversar com o tronco principal ao mesmo tempo, gera um gargalo."
  * "A Fat-Tree resolve isso 'engrossando' os cabos, as raízes ganham capacidades massivas de 400 ou 800 Gigabits por segundo à medida que subimos na hierarquia. Isso garante que a *Bisection Bandwidth* seja uniforme e nunca gere bloqueios."

---

## Slide 11: Dúvidas / Encerramento
* **Tempo sugerido:** 1 minuto
* **O que falar:**
  * "Com isso, entendemos desde a lógica interna de isolamento de uma VM, até como amarrar tudo numa rede Fat-Tree para treinar as IAs e serviços de nuvem de hoje."
  * "Agradecemos muito pela atenção de todos. Estamos abertos agora a dúvidas e perguntas!"
