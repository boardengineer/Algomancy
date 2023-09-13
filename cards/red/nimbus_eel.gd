extends Card
class_name NimbusEelCard

func _init():
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "neel"
	card_id = "base_nimbus_eel"
