extends Card
class_name AggressiveOne

func _init():
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "agro"
	card_id = "base_aggressive_one"