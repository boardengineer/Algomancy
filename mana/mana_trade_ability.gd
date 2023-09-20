extends Ability
class_name ManaTradeAbility

func _init(f_card, f_player_owner).(f_card, f_player_owner):
	goes_on_stack = false
	effects.push_back(BasicResourceIntoHandEffect.new(f_player_owner))

func pay_cost() -> bool:
	player_owner.recycle_card_from_hand(source)
	return true
