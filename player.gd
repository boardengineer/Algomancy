extends Node
class_name Player

signal draft_complete

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
	
	yield(self, "draft_complete")
	
	for card in draft_selected_cards:
		draft_pack.erase(card)
		hand.push_back(card)
		main.hand_container.add_child(HandCard.new(card))

	draft_selected_cards.clear()

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
	draft_selected_cards = selected_cards
	
	emit_signal("draft_complete")
	
func clear_hand_container():
	for child in main.hand_container.get_children():
		main.hand_container.remove_child(child)

func serialize():
	return ""
