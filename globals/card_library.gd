extends Node

const RED_CARD_SCRIPTS = preload("res://cards/lists/red_cards.tres")

var card_script_by_id = {}
var all_card_scripts = []

func _ready():
	for card_script in RED_CARD_SCRIPTS.cards:
		card_script_by_id[card_script.new().card_id] = card_script
		all_card_scripts.push_back(card_script)
	
	card_script_by_id["base_mana_converter"] = ManaConverterCard
	card_script_by_id["base_fire"] = Fire
	card_script_by_id["base_wood"] = Wood
