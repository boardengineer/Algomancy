extends Ability
class_name ManaConverterAbility

func _init(f_player_owner).(f_player_owner):
	effects.push_back(BasicResourceIntoPlayEffect.new(f_player_owner))

func pay_cost() -> bool:
	source.erase()
	return true

