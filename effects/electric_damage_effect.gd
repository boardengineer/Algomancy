extends Effect
class_name ElectricDamageEffect

var damage_amount

func _init(f_player_owner).(f_player_owner):
	pass

func needs_more_targets(current_targets = []) -> bool:
	return current_targets.empty()

func get_valid_targets(_current_targets = []) -> Array:
	return TargetHelper.get_all_targets()
	
func resolve() -> void:
	if targets[0] is Player:
		targets[0].life_remaining -= damage_amount
	else:
		targets[0].damage += damage_amount 

func can_trigger() -> bool:
	return true
