extends Effect
class_name BasicResourceIntoPlayEffect

func _init(f_player_owner).(f_player_owner):
	pass

func can_trigger() -> bool:
	return GameController.is_in_mana_phase()

func needs_more_targets(current_targets = []) -> bool:
	return current_targets.empty()

func get_valid_targets(_current_targets = []) -> Array:
	return TargetHelper.get_all_resource_targets()
	
func resolve() -> void:
	var resource_container = targets[0]
	
	var resource_card = resource_container.resource_card.duplicate()
	var permanent = Permanent.new(player_owner)
	permanent.card = resource_card
	
	var battlefield = player_owner.battlefields[player_owner]
	player_owner.add_permanent(permanent, battlefield)
