extends Node
class_name Card

var cost = 0
var card_name = ""
var card_id

var types = []
enum CardType {UNIT, SPELL, RESOURCE}

var affinity_provided = [0,0,0,0,0]
var threshold_requirement = [0,0,0,0,0]

var permanent_ability_scripts = []

var power = -1
var toughness = -1

var network_id

func _init(f_network_id = -1):
	if f_network_id == -1:
		network_id = SteamController.get_next_network_id()
	else:
		network_id = f_network_id
	SteamController.network_items_by_id[network_id] = self

func activate(for_player) -> void:
	for ability_script in permanent_ability_scripts:
		ability_script.new(for_player).activate()
	
func can_activate(for_player) -> bool:
	if not for_player.meets_mana_cost(self):
		return false
	
	for ability_script in permanent_ability_scripts:
		if not ability_script.new(for_player).can_trigger():
			return false
	
	return true

func activation_abilities(for_player) -> Array:
	return []

func serialize():
	var result_dict = {}
	
	result_dict.network_id = network_id
	result_dict.card_id = card_id
	
	# TODO might not be needed in a future where this is looked up from ID
	result_dict.card_name = card_name
	
	return result_dict

func load_data(data) -> void:
	card_id = data.card_id
	card_name = data.card_name
