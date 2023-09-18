extends Node

func deal_damage(target, _source, initial_damage, _modifiers = []) -> void:
	var modified_damage = initial_damage
	# damage modifications and shields would go here
	
	if target is Player:
		target.life_remaining -= modified_damage
	elif target is Permanent:
		target.damage += modified_damage
