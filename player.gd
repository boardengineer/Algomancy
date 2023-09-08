extends Node
class_name Player

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

func draw(amount = 1):
	for _n in amount:
		if not main.deck.empty():
			hand.push_back(main.deck.pop_front())
			
func draft():
	draft_pack.append_array(hand)
	hand.clear()
	
	# This is where we yield and something will populated draft_selected_cards
	
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
