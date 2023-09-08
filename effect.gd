extends Node
class_name Effect

func can_be_targeted(selected_targets:Array = []) -> bool:
	return true

func requires_more_targets(selected_targets:Array = []) -> bool:
	return false

func get_valid_targets(selected_targets:Array = []) -> Array:
	return []

func validate_targets(selected_targets:Array) -> bool:
	return true
	
func execute(selected_targets:Array) -> void:
	pass
