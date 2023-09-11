extends Card
class_name Wood

func _init():
	affinity_provided = [0,1,0,0,0]
	types.push_back(CardType.RESOURCE)
	card_name = "Wood"
