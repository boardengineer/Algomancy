extends Card
class_name EmberflameEnlightenerCard

func _init(f_network_id = -1).(f_network_id):
	threshold_requirement = [3,0,0,0,0]
	cost = 4
	
	types.push_back(CardType.UNIT)
	
	power = 0
	toughness = 5
	
	card_name = "enli"
	card_id = "base_emberflame_enlightener"
	
	ability_scripts.push_back(UnitCardAbility)
	permanent_ability_scripts.push_back(EmberflameEnlightenerAbility)
