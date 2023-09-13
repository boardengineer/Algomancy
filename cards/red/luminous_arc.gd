extends Card
class_name LuminousArc

func _init():
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "lumi"
	card_id = "base_luminous_arc"
