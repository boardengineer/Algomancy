extends Card
class_name BurningVengeanceCard

func _init():
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "burn"
	card_id = "base_burning_vengeance"
