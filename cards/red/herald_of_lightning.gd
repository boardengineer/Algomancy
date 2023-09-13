extends Card
class_name HeraldOfLightningCard

func _init():
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "hlig"
	card_id = "base_herald_of_lightning"
