extends Card
class_name WindDrakeCard

func _init(f_network_id = -1).(f_network_id):
	threshold_requirement = [2,0,0,0,0]
	cost = 3
	
	types.push_back(CardType.UNIT)
	card_name = "wndrk"
	
	# 2 / 2
	# Flying
	
	power = 2
	toughness = 2
	
	card_id = "base_wind_drake"
	
	ability_scripts.push_back(UnitCardAbility)
