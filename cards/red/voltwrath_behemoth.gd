extends Card
class_name VoltwrathBehemothCard

func _init():
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "Volt"
	card_id = "base_voltwrath_behemoth"
