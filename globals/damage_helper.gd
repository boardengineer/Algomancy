extends Node

func deal_damage(target, _source, initial_damage, _modifiers = []) -> void:
	var modified_damage = initial_damage
	# damage modifications and shields would go here
	
	for maybe_damage_ability in GameController.get_all_triggerable_abilities():
		modified_damage = maybe_damage_ability.modify_damage(modified_damage)
	
	if target is Player:
		target.life_remaining -= modified_damage
	elif target is Permanent:
		target.damage += modified_damage
