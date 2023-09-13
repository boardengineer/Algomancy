extends Card
class_name InfernalCultivatorCard

func _init():
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "icult"
	card_id = "base_infernal_cultivator"
