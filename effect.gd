extends Node
class_name Effect

var targets = []

func needs_more_targets(current_targets = []) -> bool:
	return false

func get_valid_targets(current_targets = []) -> bool:
	return false
	
func resolve() -> void:
	pass
