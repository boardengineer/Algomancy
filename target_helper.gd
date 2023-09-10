extends Node

signal targeting_complete
signal target_added

var valid_targets = []
var selected_targets = []

func get_targets_for_effect(effect) -> Array:
	selected_targets = []
	
	while selected_targets != null and effect.needs_more_targets(selected_targets):
		valid_targets = effect.get_valid_targets(selected_targets)
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
