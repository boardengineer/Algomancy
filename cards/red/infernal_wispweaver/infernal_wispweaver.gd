extends Card
class_name InfernalWispwaverCard

func _init(f_network_id = -1).(f_network_id):
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	power = 2
	toughness = 1
	
	types.push_back(CardType.UNIT)
	card_name = "iwspv"
	card_id = "base_infernal_wispeaver"
	
	ability_scripts.push_back(UnitCardAbility)
	
	permanent_ability_scripts.push_back(InfernalWispwaverWispBuffAbility)
	permanent_ability_scripts.push_back(InfernalWispwaverEOTAbility)
