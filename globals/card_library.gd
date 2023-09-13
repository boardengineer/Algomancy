extends Node

var card_script_by_id = {}

func _ready():
	card_script_by_id["base_mana_converter"] = ManaConverterCard
