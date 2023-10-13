extends Ability
class_name ResourceFromHandAbility

func _init(f_card, f_player_owner).(f_card, f_player_owner):
	card = f_card
	
	var effect_dict := {}
	
	effect_dict.card = card.serialize()
	
	effects.push_back(CardPermanentIntoPlayEffect.new(f_player_owner, effect_dict))

func pay_cost() -> bool:
	if player_owner.resource_plays_remaining < 1:
		return false
		
	player_owner.resource_plays_remaining -= 1
	player_owner.remove_from_hand(card)
	return true
