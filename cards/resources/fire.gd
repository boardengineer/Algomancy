extends Card
class_name Fire

func _init():
	affinity_provided = [1,0,0,0,0]
	types.push_back(CardType.RESOURCE)
	card_name = "Fire"
