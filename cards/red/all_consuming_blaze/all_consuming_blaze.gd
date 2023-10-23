extends Card
class_name AllConsumingBlazeCard

# [1] Deal damage to any target equal to [red affinity]

func _init(f_network_id = -1).(f_network_id):
	threshold_requirement = [1,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "blaz"
	card_id = "base_all_consuming_blaze"

	ability_scripts.push_back(AllConsumingBlazeAbility)
