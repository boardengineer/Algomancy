extends Card
class_name HoobaLinCard

func _init():
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "hlin"
	card_id = "base_hooba_lin"
