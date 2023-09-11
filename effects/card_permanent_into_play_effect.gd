extends Effect
class_name CardPermanentIntoPlayEffect

var card

func _init(f_card, f_player_owner).(f_player_owner):
	card = f_card

func can_trigger() -> bool:
	return GameController.is_in_mana_phase()

func needs_more_targets(current_targets = []) -> bool:
	return false

func get_valid_targets(_current_targets = []) -> Array:
	return []

func resolve() -> void:
	var permanent = Permanent.new(player_owner)
	
	permanent.abilities = card.permanent_abilities.duplicate()
	
	permanent.card = card
	player_owner.add_permanent(permanent)
