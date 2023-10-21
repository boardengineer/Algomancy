extends Effect
class_name CardPermanentIntoPlayEffect

var card

func _init(f_player_owner, effect_dict = {}).(f_player_owner):
	effect_id = "card_permanent_into_play"
	if not effect_dict.empty():
		var card_json = effect_dict.card
		var card_network_id = -1
		if card_json.has("network_id"):
			card_network_id = int(card_json.network_id)
		card = CardLibrary.card_script_by_id[card_json.card_id].new(card_network_id)

func can_trigger() -> bool:
	return true

func needs_more_targets(_current_targets = []) -> bool:
	return false

func get_valid_targets(_current_targets = []) -> Array:
	return []

func resolve() -> void:
	print_debug("creating perm with id ", card.network_id)
	var permanent = CardLibrary.permanent_for_owner(player_owner, card.network_id)
	permanent.abilities = []
	
	permanent.card = card
	for script in card.permanent_ability_scripts:
		var perm_ability = script.new(card, player_owner)
		perm_ability.source = permanent
		permanent.abilities.push_back(perm_ability)
	
	if card.types.has(Card.CardType.UNIT):
		permanent.power = card.power
		permanent.toughness = card.toughness
	
	var battlefield = GameController.get_current_battlefield_for_player(player_owner)
	player_owner.add_permanent(permanent, battlefield)

func serialize():
	var result = .serialize()
	
	result.card = card.serialize()
	
	return result
