extends Effect
class_name AggressiveOneEffect

const GENERIC_CREATURE_ID = "alpha_token_generic_unit"

func _init(f_player_owner, effect_dict = {}).(f_player_owner):
	effect_id = "alpha_aggressive_one_effect"

func can_trigger() -> bool:
	return true

func needs_more_targets(_current_targets = []) -> bool:
	return false

func get_valid_targets(_current_targets = []) -> Array:
	return []

func resolve() -> void:
	var unit_card = CardLibrary.card_script_by_id[GENERIC_CREATURE_ID].new()
	var num_attacking_units = GameController.get_active_formation().get_attacking_units().size()
	unit_card.power = num_attacking_units
	unit_card.toughness = num_attacking_units
	
	var permanent = CardLibrary.permanent_for_owner(player_owner, unit_card.network_id)
	
	permanent.abilities = []
	permanent.card = unit_card
	
	permanent.power = num_attacking_units
	permanent.toughness = num_attacking_units
	
	var battlefield = GameController.get_current_battlefield_for_player(player_owner)
	player_owner.add_permanent(permanent, battlefield)

func serialize():
	var result = .serialize()
	return result
