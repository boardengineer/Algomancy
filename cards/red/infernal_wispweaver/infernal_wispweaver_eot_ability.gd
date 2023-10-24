extends Ability
class_name InfernalWispwaverEOTAbility

const WISP_ID = "alpha_token_wisp"

func _init(f_card, f_player_owner).(f_card, f_player_owner):
	var effect_dict := {}
	
	var wisp_card = CardLibrary.card_script_by_id[WISP_ID].new()
	
	# Set the id to -1 so a new id is assigned to each wisp
	wisp_card.network_id = str(-1)
	effect_dict.card = wisp_card.serialize()
	
	effects.push_back(CardPermanentIntoPlayEffect.new(f_player_owner, effect_dict))

func can_activate() -> bool:
	return false

func on_end_of_turn(ability_index = -1):
	activate(ability_index)
