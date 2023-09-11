extends Node
class_name Ability 

# export?
var effects = []
var card
var main

var source
var player_owner

var is_static = false

func _init(f_player_owner):
	player_owner = f_player_owner

func pay_cost() -> bool:
	return true

func can_trigger() -> bool:
	if is_static:
		return false
	
	var result = true
	
	for effect in effects:
		if not effect.can_trigger():
			result = false
	
	return result

# Getting targets, putting this on the stack
func activate() -> bool:
	if not can_trigger():
		return false
	
	var cancelled = false
	
	for effect in effects:
		# Blocking call to get targets from the UI
		TargetHelper.get_targets_for_effect(effect)
		if GameController.is_targeting:
			yield(TargetHelper, "targeting_complete")
		var targets = TargetHelper.selected_targets
		if not effect.needs_more_targets([]) or targets:
			effect.targets = targets
		else:
			cancelled = true
	
	var result
	if not cancelled and pay_cost():
		main.add_to_ability_stack(self)
		result = true
	else:
		result = false
	
	GameController.emit_signal("activated_ability_or_passed", false)
	return result
	
func resolve():
	for effect in effects:
		effect.resolve()
