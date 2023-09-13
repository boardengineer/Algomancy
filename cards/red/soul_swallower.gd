extends Card
class_name SoulSwallowerCard

func _init():
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "soul"
	card_id = "base_soul_swallower"
