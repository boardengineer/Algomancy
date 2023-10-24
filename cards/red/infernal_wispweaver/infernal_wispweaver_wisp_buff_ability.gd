extends Ability
class_name InfernalWispwaverWispBuffAbility

func _init(f_card, f_player_owner).(f_card, f_player_owner):
	card = f_card
	
	var effect_dict := {}
	effect_dict.source_id = network_id
	is_static = true

func can_trigger() -> bool:
	return false

func pay_cost() -> bool:
	return false

func apply_static_effect(_ability_index = -1):
	var power_bump = GameController.num_nontoken_spells_this_skrimish
	
	for battlefield in GameController.get_current_battlefields():
		for unit in battlefield:
			if unit.player_owner == player_owner and unit.card.card_id == "alpha_token_wisp":
				unit.update_power_toughness(unit.power + 2, unit.toughness + 1)
	
	if GameController.is_in_battle():
		for unit in GameController.get_active_formation().get_all_units():
			if unit.player_owner == player_owner and unit.card.card_id == "alpha_token_wisp":
				unit.update_power_toughness(unit.power + 2, unit.toughness + 1)

func maybe_prevent_sacrifice(unit_permanent, is_sacrificing, _ability_index = -1):
	if unit_permanent.card.card_id == "alpha_token_wisp":
		return false 
	return is_sacrificing
