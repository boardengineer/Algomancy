extends UnitCard
class_name LuminaryScoutCard

func _init():
	threshold_requirement = [1,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "Scout"
	
	power = 3
	toughness = 1
	
	permanent_abilities.push_back(FlyingAbility.new())
