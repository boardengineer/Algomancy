extends Card
class_name SacrificialBurstCard

func _init():
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "smol"
	card_id = "base_sacrificial_burst"
