-- Exemplo básico em Lua

-- Declarando variáveis locais
local nome = "Mundo"
local linguagem = "Lua"

-- Mensagem simples com interpolação de strings
print("Olá, " .. nome .. "! Bem-vindo ao " .. linguagem .. ".")

-- Tabelas (a principal estrutura de dados em Lua, com índice inicial em 1)
local frutas = {"Maçã", "Banana", "Laranja"}

print("\nLista de frutas:")
for indice, fruta in ipairs(frutas) do
    print(indice .. " - " .. fruta)
end

-- Função simples
local function somar(a, b)
    return a + b
end

print("\nResultado da soma (5 + 3): " .. somar(5, 3))
