extends Card
class_name RuneChannelerCard

func _init():
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "rune"
	card_id = "base_rune_channeler"