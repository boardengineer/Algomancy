extends Card
class_name GeneralSmofCard

func _init():
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "smof"
	card_id = "base_general_smof"
