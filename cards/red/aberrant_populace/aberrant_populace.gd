extends Card
class_name AberrantPopulaceCard

# When I Attack, Block, or die, [1] Create two wisps

func _init(f_network_id = -1).(f_network_id):
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	power = 1
	toughness = 1
	
	types.push_back(CardType.UNIT)
	card_name = "popl"
	card_id = "base_aberrant_populace"
	
	ability_scripts.push_back(UnitCardAbility)
	permanent_ability_scripts.push_back(AberrantPopulaceAbility)
