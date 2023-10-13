extends Effect
class_name CardPermanentIntoPlayEffect

var card

func _init(f_player_owner, effect_dict = {}).(f_player_owner):
	effect_id = "card_permanent_into_play"
	if not effect_dict.empty():
		var card_json = effect_dict.card
		card = CardLibrary.card_script_by_id[card_json.card_id].new(card_json.network_id)

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

func serialize():
	var result = .serialize()
	
	result.card = card.serialize()
	
	return result
