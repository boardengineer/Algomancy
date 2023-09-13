extends Card
class_name OracleOfTheFlameCard

func _init(f_network_id = -1).(f_network_id):
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "ootf"
	card_id = "base_oracle_of_the_flame"
