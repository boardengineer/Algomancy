extends Card
class_name ConduitOfPain

func _init():
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "pain"
	card_id = "base_conduit_of_pain"
