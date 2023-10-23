extends Card
class_name GenericUnitCard

func _init(f_network_id = -1).(f_network_id):
	threshold_requirement = [0,0,0,0,0]
	cost = 0
	
	power = 0
	toughness = 1
	
	types.push_back(CardType.UNIT)
	card_name = "GUnit"
	is_token = true
	
	card_id = "alpha_token_generic_unit"
