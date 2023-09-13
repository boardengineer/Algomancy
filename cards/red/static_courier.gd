extends Card
class_name StaticCourierCard

func _init():
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "stat"
	card_id = "base_static_courier"
