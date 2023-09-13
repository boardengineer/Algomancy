extends Card
class_name IgnisSpriteCard

func _init():
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "igns"
	card_id = "base_ignis_sprite"
