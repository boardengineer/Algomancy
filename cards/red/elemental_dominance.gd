extends Card
class_name ElementalDominanceCard

func _init():
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "edom"
	card_id = "base_elemental_dominance"
