extends Node
class_name Player

var resource_plays_remaining 
var life_remaining = 30
var main

var player_id

var hand := []
var discard := []
var exile := []

var draft_pack := []
var battlefields := {}

var draft_selected_cards := []

func _init(game_main, assigned_player_id = -1):
	player_id = str(assigned_player_id)	
	main = game_main
	SteamController.network_players_by_id[str(player_id)] = self

func init_after_player_creation():
	for player in main.players:
		battlefields[player] = []

func draw(amount = 1):
	for _n in amount:
		if not main.deck.empty():
			hand.push_back(main.deck.pop_front())

func draft():
	draft_pack.append_array(hand)
	
	hand.clear()
	clear_hand_container()
	
	for card in draft_pack:
		SteamController.network_items_by_id[str(card.network_id)] = card

func do_mana_phase():
	pass
	
func declare_ti_attackers():
	pass

# false for pass
func take_action_or_pass() -> bool:
	return false

func add_to_hand(card) -> void:
	hand.push_back(card)
	if player_id == SteamController.self_peer_id:
		main.hand_container.add_child(HandCard.new(card, self))
	else:
		main.opponent_hand_container.add_child(HandCard.new(card, self))

func add_to_discard(card) -> void:
	discard.push_back(card)
	
	if player_id == SteamController.self_peer_id:
		main.player_discard_container.add_child(HandCard.new(card, self))
	else:
		main.opponent_discard_container.add_child(HandCard.new(card, self))

func clear_hand_container():
	main.clear_hand_container()

func serialize():
	var result_dict = {}
	
	result_dict.player_id = str(player_id)
	
	result_dict.hand = serialize_card_array(hand)
	result_dict.discard = serialize_card_array(discard)
	result_dict.exile = serialize_card_array(exile)
	result_dict.draft_pack = serialize_card_array(draft_pack)
	
	var serialized_battlefields = {}
	for other_player in battlefields:
		var serialized_field = []
		
		for permanent in battlefields[other_player]:
			serialized_field.push_back(permanent.serialize())
		
		serialized_battlefields[other_player.player_id] = serialized_field
	result_dict.battlefields = serialized_battlefields
	
	return result_dict

func load_data(player_dict) -> void:
	# player_id is populated on _init
	hand = deserialized_card_array_json(player_dict.hand)
	
#	main.opponent_hand_container.add_child(HandCard.new(card, self))
	var hand_container = main.opponent_hand_container
	if player_id == SteamController.self_peer_id:
		hand_container = main.hand_container
		
	for card in hand:
		hand_container.add_child(HandCard.new(card, self))
	
	discard = deserialized_card_array_json(player_dict.discard)
	exile = deserialized_card_array_json(player_dict.exile)
	
	draft_pack = deserialized_card_array_json(player_dict.draft_pack)
	for battlefield_player_id in player_dict.battlefields:
		var player
		for q_player in main.players:
			if q_player.player_id == battlefield_player_id:
				player = q_player
		for permanent_json in player_dict.battlefields[battlefield_player_id]:
			var permanent_to_add = CardLibrary.permanent_for_owner(self, permanent_json.network_id)
			permanent_to_add.player_owner = self
			permanent_to_add.load_data(permanent_json)
			
			add_permanent(permanent_to_add, battlefields[player])

static func serialize_card_array(card_array):
	var result = []
	for card in card_array:
		result.push_back(card.serialize())
	return result

static func deserialized_card_array_json(card_array_json):
	var result = []
	
	for card_json in card_array_json:
		var card_to_add = CardLibrary.card_script_by_id[card_json.card_id].new(card_json.network_id)
#		var card_to_add = Card.new(card_json.network_id)
#		card_to_add.load_data(card_json)
		result.push_back(card_to_add)
	
	return result

func add_starting_mana_converters():
	var mc_one = CardLibrary.get_mana_converter_permanent(self)
	mc_one.main = main
	add_permanent(mc_one, battlefields[self])
	
	var mc_two = CardLibrary.get_mana_converter_permanent(self)
	mc_two.main = main
	add_permanent(mc_two, battlefields[self])

# Default add case
func add_permanent(permanent_to_add, battlefield) -> void:
	battlefield.push_back(permanent_to_add)
	permanent_to_add.logic_container = battlefield
	
	var field
	
	if player_id == SteamController.self_peer_id:
		if battlefield == battlefields[self]:
			field = main.player_field
		else:
			# TODO, this is a placeholder for "away field"
			field = main.player_away_field
	else:
		field = main.opponent_field
	
	field.add_child(permanent_to_add)
	permanent_to_add.tree_container = field

func remove_from_hand(card) -> void:
	for hand_card in main.hand_container.get_children():
		if hand_card.card == card:
			main.hand_container.remove_child(hand_card)
	
	hand.erase(card)

func recycle_card_from_hand(card) -> void:
	remove_from_hand(card)
	main.recycle_card(card)

func get_available_mana() -> int:
	var untapped_mana = 0
	
	for permanent in battlefields[self]:
		if not permanent.tapped and permanent.card.types.has(Card.CardType.RESOURCE):
			untapped_mana += 1
	
	return untapped_mana

func pay_mana(cost) -> bool:
	var need_to_pay = cost
	
	for permanent in battlefields[self]:
		if need_to_pay == 0:
			break
		
		if not permanent.tapped and permanent.card.types.has(Card.CardType.RESOURCE):
			permanent.tap()
			need_to_pay -= 1
	
	return need_to_pay == 0

func get_threshold() -> Array:
	var result = [0,0,0,0,0]
	
	for permanent in battlefields[self]:
		if permanent.card:
			for i in result.size():
				result[i] += permanent.card.affinity_provided[i]
	
	return result

func meets_mana_cost(card) -> bool:
	return get_available_mana() >= card.cost and meets_card_threshold(card)

func meets_card_threshold(card) -> bool:
	var my_threshold = get_threshold()
	
	for n in card.threshold_requirement.size():
		if card.threshold_requirement[n] > my_threshold[n]:
			return false
	
	return true

func is_dummy() -> bool:
	return player_id == str(-1)

func get_id():
	return player_id
