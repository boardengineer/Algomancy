extends Card
class_name Fire

func _init(f_network_id = -1).(f_network_id):
	affinity_provided = [1,0,0,0,0]
	types.push_back(CardType.RESOURCE)
	card_name = "Fire"
	card_id = "base_fire"
