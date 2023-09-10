extends Ability
class_name ManaTradeAbility

func _init(f_player_owner).(f_player_owner):
	effects.push_back(BasicResourceIntoHandEffect.new(f_player_owner))

func pay_cost() -> bool:
	player_owner.recycle_card_from_hand(source)
	return true
