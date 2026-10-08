// Exemplo básico em Groovy

// Declarando variáveis
def nome = "Mundo"
def linguagem = "Groovy"

// Mensagem simples com interpolação de texto
println "Olá, ${nome}! Bem-vindo ao ${linguagem}."

// Trabalhando com listas
def frutas = ["Maçã", "Banana", "Laranja"]

println "\nLista de frutas:"
frutas.each { fruta ->
    println "- ${fruta}"
}

// Função simples
def somar(a, b) {
    return a + b
}

println "\nResultado da soma (5 + 3): ${somar(5, 3)}"
