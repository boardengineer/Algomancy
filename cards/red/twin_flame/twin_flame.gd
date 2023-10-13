extends Card
class_name TwinFlameCard

func _init(f_network_id = -1).(f_network_id):
	threshold_requirement = [2,0,0,0,0]
	cost = 3
	
	types.push_back(CardType.UNIT)
	card_name = "TFLM"
	card_id = "base_twin_flame"
	
	ability_scripts.push_back(TwinFlameAbility)
