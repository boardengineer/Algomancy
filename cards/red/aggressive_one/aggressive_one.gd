extends Card
class_name AggressiveOne

func _init(f_network_id = -1).(f_network_id):
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	power = 1
	toughness = 2
	
	types.push_back(CardType.UNIT)
	card_name = "agro"
	card_id = "base_aggressive_one"
	
	ability_scripts.push_back(UnitCardAbility)
	permanent_ability_scripts.push_back(AggressiveOneAbility)
