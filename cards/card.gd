extends Node
class_name Card

var cost = 0
var card_name = ""

var types = []
enum CardType {UNIT, SPELL, RESOURCE}

var affinity_provided = [0,0,0,0,0]
var threshold_requirement = [0,0,0,0,0]

var permanent_abilities = []

func activate(for_player) -> void:
	pass
	
func can_activate(for_player) -> bool:
	return true
