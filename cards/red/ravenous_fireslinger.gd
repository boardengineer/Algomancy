extends Card
class_name RavenousFireslinger

func _init(f_network_id = -1).(f_network_id):
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "slin"
	card_id = "base_ravenous_fireslinger"
