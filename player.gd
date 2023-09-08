extends Node
class_name Player

signal draft_complete

var life_remaining
var main

var hand := []
var discard := []
var exile := []

var draft_pack := []
var battlefields := {}

var draft_selected_cards := []

func _init(game_main):
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
	draft_pack.append_array(hand)
	hand.clear()
	
	# This is where we yield and something will populated draft_selected_cards
	main.draft_container.display_draft_pack(draft_pack)
	
	yield(self, "draft_complete")
	
	for card in draft_selected_cards:
		draft_pack.erase(card)
		hand.push_back(card)

	draft_selected_cards.clear()

func do_mana_phase():
	pass
	
func declare_ti_attackers():
	pass

# false for pass
func take_action_or_pass() -> bool:
	return false
	
func _on_draft_selection_complete(selected_cards):
	print_debug(selected_cards)
	draft_selected_cards = selected_cards
	
	emit_signal("draft_complete")
