extends Node
class_name Card

var cost = 0
var card_name = ""

var types = []
enum CardType {UNIT, SPELL, RESOURCE}

var affinity_provided = [0,0,0,0,0]
var threshold_requirement = [0,0,0,0,0]

var permanent_abilities = []

var power = -1
var toughness = -1

func activate(for_player) -> void:
	for ability in activation_abilities(for_player):
		ability.activate()
	
func can_activate(for_player) -> bool:
	if not for_player.meets_mana_cost(self):
		return false
	
	for ability in activation_abilities(for_player):
		if not ability.can_trigger():
			return false
	
	return true

func activation_abilities(for_player) -> Array:
	return []
