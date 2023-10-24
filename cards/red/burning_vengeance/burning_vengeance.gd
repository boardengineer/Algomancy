extends Card
class_name BurningVengeanceCard

func _init(f_network_id = -1).(f_network_id):
	threshold_requirement = [1,0,0,0,0]
	cost = 1
	
	types.push_back(CardType.SPELL)
	
	card_name = "burn"
	card_id = "base_burning_vengeance"
	
	ability_scripts.push_back(BurningVengeanceAbility)
