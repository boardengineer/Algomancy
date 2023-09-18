extends Effect
class_name CardPermanentIntoPlayEffect

var card

func _init(f_card, f_player_owner).(f_player_owner):
	card = f_card

func can_trigger() -> bool:
	return true

func needs_more_targets(_current_targets = []) -> bool:
	return false

func get_valid_targets(_current_targets = []) -> Array:
	return []

func resolve() -> void:
	var permanent = CardLibrary.permanent_for_owner(player_owner)
	var abilities = []
	
	permanent.card = card
	for script in card.permanent_ability_scripts:
		abilities.push_back(script.new(player_owner))
	
	if card.types.has(Card.CardType.UNIT):
		permanent.power = card.power
		permanent.toughness = card.toughness
	
	var battlefield = player_owner.battlefields[player_owner]
	player_owner.add_permanent(permanent, battlefield)
