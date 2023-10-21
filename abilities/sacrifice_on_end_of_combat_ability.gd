extends Ability
class_name SacrificeOnEndOfCombatAbility

func _init(f_card, f_player_owner).(f_card, f_player_owner):
	card = f_card
	var effect_dict = {}
	effect_dict.source_id = f_card.network_id
	effects.push_back(SacrificeSelfEffect.new(f_player_owner, effect_dict))

func can_activate() -> bool:
	return false

func on_end_of_combat(ability_index = -1):
	print_debug("found sacrifice?")
	activate(ability_index)
