extends Node

const RED_CARD_SCRIPTS = preload("res://cards/red/red_card_list.tres")
const TEST_CARD_SCRIPTS = preload("res://cards/lists/test_cards.tres")
const TOKEN_CARD_SCRIPTS = preload("res://cards/lists/token_cards.tres")

var permanent_scene = load("res://permanent.tscn")

var card_script_by_id = {}
var all_card_scripts = []

func _ready():
#	for card_script in RED_CARD_SCRIPTS.cards:
#		card_script_by_id[card_script.new().card_id] = card_script
#		all_card_scripts.push_back(card_script)
	
	while all_card_scripts.size() < 50:
		for card_script in RED_CARD_SCRIPTS.cards:
			card_script_by_id[card_script.new().card_id] = card_script
			all_card_scripts.push_back(card_script)
		
		for card_script in TEST_CARD_SCRIPTS.cards:
			card_script_by_id[card_script.new().card_id] = card_script
			all_card_scripts.push_back(card_script)
	
	for card_script in TOKEN_CARD_SCRIPTS.cards:
		card_script_by_id[card_script.new().card_id] = card_script
	
	card_script_by_id["base_mana_converter"] = ManaConverterCard
	card_script_by_id["base_fire"] = Fire
	card_script_by_id["base_wood"] = Wood

func get_mana_converter_permanent(player_owner) -> Permanent:
	var result = permanent_scene.instance()
	result.init(player_owner)
	
	var ability = ManaConverterAbility.new(null, player_owner)
	ability.source = result
	ability.main = player_owner.main
	result.card = ManaConverterCard.new()
	ability.card = result.card
	
	result.abilities.push_back(ability)
	
	return result

func permanent_for_owner(player_owner, network_id = -1) -> Permanent:
	var result = permanent_scene.instance()
	
	if SteamController.latest_network_id <= network_id:
		SteamController.latest_network_id = network_id + 1
	result.init(player_owner, network_id)
	
	return result
