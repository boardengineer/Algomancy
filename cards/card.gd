extends Node
class_name Card

var cost = 0
var card_name = ""
var card_id

var types = []
enum CardType {UNIT, SPELL, RESOURCE}

var affinity_provided = [0,0,0,0,0]
var threshold_requirement = [0,0,0,0,0]

# Given to the unit that is created by this card
var permanent_ability_scripts = []

# Triggered when the card is played
var ability_scripts = []

var power = -1
var toughness = -1

var network_id
var is_token = false

func _init(f_network_id = -1):
	if f_network_id == -1:
		network_id = SteamController.get_next_network_id()
	else:
		network_id = f_network_id
	
	var network_key = str(network_id)
	
	# Don't override the network ID if there's already a hand card etc since
	# that's the interactable version of this card.
	if not SteamController.network_items_by_id.has(network_key):
		SteamController.network_items_by_id[str(network_id)] = self

func activate(for_player) -> void:
	for ability_script in ability_scripts:
		ability_script.new(self, for_player).activate()
	
func can_activate(for_player) -> bool:
	if not for_player.meets_mana_cost(self):
		return false
	
	for ability_script in ability_scripts:
		if not ability_script.new(self, for_player).can_trigger():
			return false
	
	return true

func activation_abilities(_for_player) -> Array:
	return []

func serialize():
	var result_dict = {}
	
	result_dict.network_id = network_id
	result_dict.card_id = card_id
	
	if toughness > 0:
		result_dict.power = power
		result_dict.toughness = toughness
	
	# TODO might not be needed in a future where this is looked up from ID
	result_dict.card_name = card_name
	
	return result_dict

func load_data(data) -> void:
	card_id = data.card_id
	card_name = data.card_name
	
	if data.has("toughness"):
		power = data.power
		toughness = data.toughness
