extends Node
class_name Effect

var targets = []
var player_owner

func _init(f_player_owner):
	player_owner = f_player_owner

func needs_more_targets(_current_targets = []) -> bool:
	return false

func get_valid_targets(_current_targets = []) -> Array:
	return []
	
func resolve() -> void:
	pass
