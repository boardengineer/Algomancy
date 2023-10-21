extends Effect
class_name SacrificeSelfEffect

var source

func _init(f_player_owner, effect_dict = {}).(f_player_owner):
	effect_id = "sacrifice_self"
	if not effect_dict.empty():
		source = SteamController.network_items_by_id[str(effect_dict.source_id)]

func resolve() -> void:
	source.sacrifice()

func serialize():
	var result = .serialize()
	
	result.source_id = source.network_id
	
	return result
