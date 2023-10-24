extends Node
class_name Ability 

# export?
var effects = []
var card
var main
var network_id

var source
var player_owner

var is_static = false
var goes_on_stack = true

func _init(f_card, f_player_owner, f_network_id = -1):
	if SteamController.latest_network_id <= f_network_id:
		SteamController.latest_network_id = f_network_id + 1
	
	card = f_card
	player_owner = f_player_owner
	
	if f_network_id == -1:
		network_id = SteamController.get_next_network_id()
	else:
		network_id = f_network_id
	
	SteamController.network_items_by_id[str(network_id)] = self

func pay_cost() -> bool:
	return true

func can_activate() -> bool:
	return can_trigger()

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
		command_dict.type = "ability"
		command_dict.source = source.network_id
		command_dict.index = ability_index
	
		var targeted_effects = []
	
		for targeted_effect in effects:
			var effect_dict = {}
		
			var targets = []
			for target in targeted_effect.targets:
				targets.push_back(target.get_id())
		
			effect_dict.targets = targets
			targeted_effects.push_back(effect_dict)
		
		command_dict.effects = targeted_effects
		
		if can_trigger():
			SteamController.submit_ability_or_passed(command_dict)
	
#	GameController.emit_signal("activated_ability_or_passed", false)

func on_attack(_ability_index = -1):
	pass

func on_block(_ability_index = -1):
	pass

func on_end_of_combat(_ability_index = -1):
	pass

func on_unit_death(_unit_permanent, _ability_index = -1):
	pass

func apply_static_effect(_ability_index = -1):
	pass

func resolve():
	for effect in effects:
		effect.resolve()

func serialize() -> Dictionary:
	var result_dict := {}
	
	result_dict.network_id = network_id
	
	if card:
		result_dict.card = card.serialize()
	
	var serialized_effects = []
	
	for effect in effects:
		serialized_effects.push_back(effect.serialize())
	
	result_dict.effects = serialized_effects
	result_dict.player_owner_id = player_owner.player_id
	
	return result_dict
