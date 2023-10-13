extends Ability
class_name UnitCardAbility 

func _init(f_card, f_player_owner).(f_card, f_player_owner):
	var effect_dict := {}
	effect_dict.card = card.serialize()
	card = f_card
	print_debug("creating card 1?")
	effects.push_back(CardPermanentIntoPlayEffect.new(f_player_owner, effect_dict))

func can_trigger() -> bool:
	# Check for different timings
	if not GameController.is_in_main_phase():
		return false
	
	if not player_owner.meets_mana_cost(card):
		return false
	
	return true

func pay_cost() -> bool:
	player_owner.pay_mana(card.cost)
	
	player_owner.remove_from_hand(card)

	return true
