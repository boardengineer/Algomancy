extends Ability
class_name AggressiveOneAbility

func _init(f_card, f_player_owner).(f_card, f_player_owner):
	var effect_dict := {}
	
	effects.push_back(AggressiveOneEffect.new(f_player_owner, effect_dict))

func can_activate() -> bool:
	return false

func on_end_of_combat(ability_index = -1):
	activate(ability_index)
