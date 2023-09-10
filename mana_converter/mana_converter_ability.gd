extends Ability
class_name ManaConverterAbility

func pay_cost() -> bool:
	source.erase()
	return true

func _init():
	pass
