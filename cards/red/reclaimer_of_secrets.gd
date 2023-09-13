extends Card
class_name ReclaimerOfSecrets

func _init():
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "recl"
	card_id = "base_reclaimer_of_secrets"
