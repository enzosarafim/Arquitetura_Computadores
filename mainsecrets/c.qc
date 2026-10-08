/*
*  Exemplo básico de QuakeC (.qc)
*  Criando um item de saúde personalizado
*/

// Declaração de funções do motor do Quake (built-ins)
void() sound;

// Função chamada quando o jogador toca no item
void() item_health_touch =
{
    // Verifica se quem tocou é um jogador e se está vivo
    if (other.classname != "player" || other.health <= 0)
        return;

    // Recupera vida do jogador
    other.health = other.health + 25;
    if (other.health > 100)
        other.health = 100;

    // Toca o som de cura
    sound(self, CHAN_ITEM, "items/r_item1.wav", 1, ATTN_NORM);

    // Oculta o item e agenda o reaparecimento (respawn)
    self.model = string_null;
    self.solid = SOLID_NOT;
    self.nextthink = time + 20; // Reaparece em 20 segundos
    self.think = SUB_regen;
};

// Função principal da entidade (chamada ao carregar o mapa)
void() item_health_custom =
{
    precache_model("models/g_health.mdl");
    precache_sound("items/r_item1.wav");

    self.solid = SOLID_TRIGGER;
    self.movetype = MOVETYPE_NONE;
    
    setmodel(self, "models/g_health.mdl");
    setsize(self, '-16 -16 0', '16 16 56');

    self.touch = item_health_touch;
};
