extends Effect
class_name LuminousArcEffect

var damage_amount
var num_targets
var source

func _init(f_player_owner, effect_dict = {}).(f_player_owner):
	if not effect_dict.empty():
		source = SteamController.network_items_by_id[str(effect_dict.source_id)]
	effect_id = "alpha_luminous_arc_effect"

func needs_more_targets(current_targets = []) -> bool:
	return current_targets.empty()

func get_valid_targets(current_targets = []) -> Array:
	var valid_targets = []
	
	for battlefield in GameController.get_current_battlefields():
		valid_targets.append_array(battlefield)
	
	if GameController.is_in_battle():
		valid_targets.append_array(GameController.get_active_formation().get_all_units())
	
	for already_selected_target in current_targets:
		valid_targets.erase(already_selected_target)
	
	return valid_targets

func can_trigger() -> bool:
	return get_valid_targets().size() >= 1 

func resolve() -> void:
	var damage_amount = 6
	
	for target in targets:
		DamageHelper.deal_damage(target, source, damage_amount)

func serialize() -> Dictionary:
	var result_dict = .serialize()
	
	result_dict.source_id = source.network_id
	
	return result_dict

func load_data(effect_dict) -> void:
	.load_data(effect_dict)
	
	source = SteamController.network_items_by_id[str(effect_dict.source_id)]
