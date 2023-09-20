extends Node
class_name Ability 

# export?
var effects = []
var card
var main

var source
var player_owner

var is_static = false
var goes_on_stack = true

func _init(f_card, f_player_owner):
	card = f_card
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
func activate(ability_index = 0) -> void:
	if not can_trigger():
		return
	
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
			cancelled =  true
	
	cancelled = false
	
	if not cancelled:
		var command_dict = {}
		command_dict.source = source.network_id
		command_dict.index = ability_index
	
		var targeted_effects = []
	
		for targeted_effect in effects:
			var effect_dict = {}
		
			var targets = []
			for target in targeted_effect.targets:
				targets.push_back(target.network_id)
		
				effect_dict.targets = targets
				targeted_effects.push_back(effect_dict)
		
		command_dict.effects = targeted_effects
		
		if can_trigger():
			SteamController.submit_ability_or_passed(command_dict)
	
#	GameController.emit_signal("activated_ability_or_passed", false)
	
func resolve():
	for effect in effects:
		effect.resolve()
