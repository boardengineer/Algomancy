extends Node
class_name Player

signal draft_complete
signal took_action_or_passed

var life_remaining
var main

var player_id

var hand := []
var discard := []
var exile := []

var draft_pack := []
var battlefields := {}

var draft_selected_cards := []

func _init(game_main, assigned_player_id = -1):
	player_id = assigned_player_id
	main = game_main

func _ready():
	for player in main.players:
		battlefields[player] = []
		
	# connect the signal but only for the host we'll deal with client players
	# layer
	if player_id == SteamController.self_peer_id:
		main.draft_container.connect("draft_selection_complete", self, "_on_draft_selection_complete")
	

func draw(amount = 1):
	for _n in amount:
		if not main.deck.empty():
			hand.push_back(main.deck.pop_front())

func draft():
	if player_id != SteamController.self_peer_id:
		dummy_draft()
		return
	
	draft_pack.append_array(hand)
	hand.clear()
	clear_hand_container()
	
	# This is where we yield and something will populated draft_selected_cards
	main.draft_container.display_draft_pack(draft_pack)

# Intended to simulate "other player" doing stuff
func dummy_draft():
	draft_pack.append_array(hand)
	hand.clear()
	
	while draft_pack.size() > 10:
		hand.push_back(draft_pack.pop_front())

func do_mana_phase():
	pass
	
func declare_ti_attackers():
	pass

# false for pass
func take_action_or_pass() -> bool:
	return false
	
func _on_draft_selection_complete(selected_cards):
	for card in selected_cards:
		draft_pack.erase(card)
		add_to_hand(card) 
	
	emit_signal("draft_complete")
	
func add_to_hand(card) -> void:
	print_debug("adding card ", card.card_name)
	hand.push_back(card)
	main.hand_container.add_child(HandCard.new(card, self))
	
func clear_hand_container():
	for child in main.hand_container.get_children():
		main.hand_container.remove_child(child)

func serialize():
	return ""

func add_starting_mana_converters():
	var mc_one = ManaConverterPermanent.new(self)
	mc_one.main = main
	add_permanent(mc_one)
	
	var mc_two = ManaConverterPermanent.new(self)
	mc_two.main = main
	add_permanent(mc_two)

# Default add case
func add_permanent(permanent_to_add) -> void:
	battlefields[self].push_back(permanent_to_add)
	permanent_to_add.logic_container = battlefields[self]
	
	var field
	
	if player_id == SteamController.self_peer_id:
		field = main.player_field
	else:
		field = main.opponent_field
	
	field.add_child(permanent_to_add)
	permanent_to_add.tree_container = main.player_field

func remove_from_hand(card) -> void:
	print_debug("removing card ", card.card_name)
	for hand_card in main.hand_container.get_children():
		print_debug("looking for match? ", hand_card.card.card_name)
		if hand_card.card == card:
			print_debug("found match?")
			main.hand_container.remove_child(hand_card)
	
	hand.erase(card)

func recycle_card_from_hand(card) -> void:
	remove_from_hand(card)
	main.recycle_card(card)
