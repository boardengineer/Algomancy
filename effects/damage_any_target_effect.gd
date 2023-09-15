extends Effect
class_name DamageAnyTargetEffect

var damage_amount
var source

func _init(f_damage_amount, f_source, f_player_owner).(f_player_owner):
	damage_amount = f_damage_amount
	source = f_source

func needs_more_targets(current_targets = []) -> bool:
	return current_targets.empty()

func get_valid_targets(_current_targets = []) -> Array:
	var valid_targets = []
	
	valid_targets.append_array(TargetHelper.get_targetable_players())
	
	for battlefield in TargetHelper.get_current_battlefields():
		valid_targets.append_array(battlefield)
	
	return valid_targets

func can_trigger() -> bool:
	return not get_valid_targets().empty()

func resolve() -> void:
	DamageHelper.deal_damage(targets[0], source, damage_amount)
