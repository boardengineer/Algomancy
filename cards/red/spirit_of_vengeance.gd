extends Card
class_name SpiritOfVengeanceCard

func _init():
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "veng"
	card_id = "base_spirit_of_vengeance"
