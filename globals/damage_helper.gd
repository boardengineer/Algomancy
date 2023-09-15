extends Node

func deal_damage(target, source, initial_damage, modifiers = []) -> void:
	var modified_damage = initial_damage
	# damage modifications and shields would go here
	
	if target is Player:
		target.life_remaining -= modified_damage
	elif target is Permanent:
		target.damage += modified_damage
