extends Card
class_name AnimatedSparkCard

func _init(f_network_id = -1).(f_network_id):
	threshold_requirement = [1,0,0,0,0]
	cost = 1
	
	power = 0
	toughness = 1
	
	types.push_back(CardType.UNIT)
	card_name = "spark"
	card_id = "base_animated_spark"
	
	ability_scripts.push_back(UnitCardAbility)
	permanent_ability_scripts.push_back(AnimatedSparkAbility)
