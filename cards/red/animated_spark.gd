extends Card
class_name AnimatedSparkCard

func _init():
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "spark"
	card_id = "base_animated_spark"
