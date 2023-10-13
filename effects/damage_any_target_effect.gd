extends Effect
class_name DamageAnyTargetEffect

var damage_amount
var source

func _init(f_player_owner, effect_dict = {}).(f_player_owner):
	if not effect_dict.empty():
		damage_amount = effect_dict.damage_amount
		source = SteamController.network_items_by_id[str(effect_dict.source_id)]
	effect_id = "damage_any_target"

func needs_more_targets(current_targets = []) -> bool:
	return current_targets.empty()

func get_valid_targets(_current_targets = []) -> Array:
	var valid_targets = []
	
	valid_targets.append_array(TargetHelper.get_targetable_players())
	
	for battlefield in GameController.get_current_battlefield():
		valid_targets.append_array(battlefield)
	
	if GameController.is_in_battle():
		valid_targets.append_array(GameController.get_active_formation().get_all_units())
	
	return valid_targets

func can_trigger() -> bool:
	return not get_valid_targets().empty()

func resolve() -> void:
	print_debug("resolving damage?")
	DamageHelper.deal_damage(targets[0], source, damage_amount)

func serialize() -> Dictionary:
	var result_dict = .serialize()
	
	result_dict.damage_amount = damage_amount
	result_dict.source_id = source.network_id
	
	return result_dict

func load_data(effect_dict) -> void:
	.load_data(effect_dict)
	
	damage_amount = effect_dict.damage_amount
	source = SteamController.network_items_by_id[str(effect_dict.source_id)]
