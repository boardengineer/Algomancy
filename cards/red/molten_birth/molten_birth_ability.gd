extends Ability
class_name MoltenBirthAbility

const WISP_ID = "alpha_token_wisp"

func _init(f_card, f_player_owner).(f_card, f_player_owner):
	card = f_card
	
	var effect_dict := {}
	effect_dict.source_id = network_id
	var wisp_card = CardLibrary.card_script_by_id[WISP_ID].new()
	
	# Set the id to -1 so a new id is assigned to each wisp
	wisp_card.network_id = str(-1)
	effect_dict.card = wisp_card.serialize()
	
	effects.push_back(CardPermanentIntoPlayEffect.new(f_player_owner, effect_dict))
	effects.push_back(CardPermanentIntoPlayEffect.new(f_player_owner, effect_dict))
	effects.push_back(CardPermanentIntoPlayEffect.new(f_player_owner, effect_dict))
	

func can_trigger() -> bool:
	if not GameController.is_in_main_phase():
		return false
	
	if not player_owner.meets_mana_cost(card):
		return false
	
	return true

func pay_cost() -> bool:
	player_owner.pay_mana(card.cost)
	player_owner.remove_from_hand(card)

	return true
