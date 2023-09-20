extends Ability
class_name ManaConverterAbility

func _init(f_card, f_player_owner).(f_card, f_player_owner):
	goes_on_stack = false
	effects.push_back(BasicResourceIntoPlayEffect.new(f_player_owner))

func pay_cost() -> bool:
	source.erase()
	return true
