extends Card
class_name DelverOfMysteries

func _init():
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "dlvr"
	card_id = "base_delver_of_mysteries"
