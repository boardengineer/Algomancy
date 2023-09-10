extends Node
class_name Ability 

# export?
var effects = []
var card
var main

var source

func pay_cost() -> bool:
	return true

func can_trigger() -> bool:
	var result = true
	
	for effect in effects:
		if effect.can_trigger():
			result = false
	
	return result

# Getting targets, putting this on the stack
func activate() -> bool:
	var cancelled = false
	
	for effect in effects:
		# Blocking call to get targets from the UI
		var targets = TargetHelper.get_targets_for_effect(effect)
		if targets:
			effect.targets = targets
		else:
			cancelled = true
			
	if not cancelled and pay_cost():
		main.stack.push_back(self)
		return true
	else:
		return false
	
func resolve():
	for effect in effects:
		effect.resolve()
