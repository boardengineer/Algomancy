extends Node
class_name Effect

var targets = []
var player_owner
var effect_id

func _init(f_player_owner):
	player_owner = f_player_owner

func needs_more_targets(_current_targets = []) -> bool:
	return false

func get_valid_targets(_current_targets = []) -> Array:
	return []
	
func resolve() -> void:
	pass

func can_trigger() -> bool:
	return true

func serialize() -> Dictionary:
	var result_dict := {}
	
	var target_ids = []
	for target in targets:
		target_ids.push_back(target.get_id())
	
	result_dict.targets = target_ids
	result_dict.effect_id = effect_id
	result_dict.player_owner_id = player_owner.player_id
	
	return result_dict

func load_data(effect_dict:Dictionary) -> void:
	targets = []
	
	for target_id in effect_dict.targets:
		print_debug("loading target: ", SteamController.network_items_by_id[str(target_id)])
		targets.push_back(SteamController.network_items_by_id[str(target_id)])
