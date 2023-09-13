extends Card
class_name GromlinCard

func _init():
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "grlm"
	card_id = "base_gromlin"
