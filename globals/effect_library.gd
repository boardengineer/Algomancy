extends Node

var effect_script_by_id = {}

func _ready():
	# TODO better than this, its just a placeholder
	effect_script_by_id["card_permanent_into_play"] = CardPermanentIntoPlayEffect
	effect_script_by_id["damage_any_n_targets"] = DamageAnyNTargetsEffect

func load_effect(effect_dict):
	var player_owner = GameController.get_player_for_id(effect_dict.player_owner_id)
	var effect_script = effect_script_by_id[effect_dict.effect_id]
	var result = effect_script.new(player_owner, effect_dict)
	
	result.load_data(effect_dict)
	
	return result

func load_ability(ability_dict):
	var player_owner = GameController.get_player_for_id(ability_dict.player_owner_id)
	var card = null
	if ability_dict.has("card"):
		var card_json = ability_dict.card
		card = CardLibrary.card_script_by_id[card_json.card_id].new(card_json.network_id)
	var network_id = ability_dict.network_id
	
	var result = Ability.new(card, player_owner, network_id)
	
	for effect_dict in ability_dict.effects:
		result.effects.push_back(load_effect(effect_dict))
	
	return result
