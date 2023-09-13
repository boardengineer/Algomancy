extends Card
class_name RecurrentSpiritCard

func _init():
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "recu"
	card_id = "base_recurrent_spirit"
