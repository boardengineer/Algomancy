extends Card
class_name EmberflameEnlightenerCard

func _init():
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "enli"
	card_id = "base_emberflame_enlightener"
