extends Card
class_name FlameShieldCard

func _init():
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "fshld"
	card_id = "base_flame_shield"
