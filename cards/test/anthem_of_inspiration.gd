extends Card
class_name AnthemOfInspirationCard

func _init(f_network_id = -1).(f_network_id):
	threshold_requirement = [2,0,0,0,0]
	cost = 3
	
	types.push_back(CardType.UNIT)
	card_name = "ainspr"
	
	# 3 / 3
	# Virus Timing
	# [Augment] Creatures you Control get +1 / +1
	card_id = "base_anthem_of_inspiration"
