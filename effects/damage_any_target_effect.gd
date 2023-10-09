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
	
	for battlefield in GameController.get_current_battlefield():
		valid_targets.append_array(battlefield)
	
	if GameController.is_in_battle():
		valid_targets.append_array(GameController.get_active_formation().get_all_units())
	
	return valid_targets

func can_trigger() -> bool:
	return not get_valid_targets().empty()

func resolve() -> void:
	DamageHelper.deal_damage(targets[0], source, damage_amount)
