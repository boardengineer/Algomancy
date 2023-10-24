extends Ability
class_name EmberflameEnlightenerAbility

func _init(f_card, f_player_owner).(f_card, f_player_owner):
	card = f_card
	
	var effect_dict := {}
	effect_dict.source_id = network_id
	is_static = true

func can_trigger() -> bool:
	return false

func pay_cost() -> bool:
	return false

func modify_damage(damage_before, _ability_index = -1):
	return damage_before * 2
