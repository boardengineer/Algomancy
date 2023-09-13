extends Card
class_name MischeviousReclaimerCard

func _init():
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "mish"
	card_id = "base_mischevious_reclaimer"
