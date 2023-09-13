extends Card
class_name Wood

func _init(f_network_id = -1).(f_network_id):
	affinity_provided = [0,1,0,0,0]
	types.push_back(CardType.RESOURCE)
	card_name = "Wood"
	card_id = "base_wood"
