extends Node

signal targeting_complete
signal target_added

var valid_targets = []
var selected_targets = []

var main = null

func get_targets_for_effect(effect) -> Array:
	selected_targets = []
	
	while selected_targets != null and effect.needs_more_targets(selected_targets):
		valid_targets = effect.get_valid_targets(selected_targets)
		
		for resource in get_all_resource_targets():
			main.basic_resource_dialog.show()
		
		yield(self, "target_added")
	
	return selected_targets

func on_target_selected(target) -> void:
	if GameController.is_targeting and valid_targets.has(target):
		selected_targets.push_back(target)
		emit_signal("target_added")

func on_cancelled() -> void:
	if GameController.targeting:
		selected_targets = null
		emit_signal("target_added")

func set_up_references(main_game) -> void:
	main = main_game

func get_all_resource_targets() -> Array:
	var result = []
	
	result.push_back(get_basic_wood_target())
	result.push_back(get_basic_fire_target())
	
	return result

func get_basic_wood_target():
	return main.basic_resource_container.get_node("Wood")
	
func get_basic_fire_target():
	return main.basic_resource_container.get_node("Fire")
