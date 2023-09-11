extends Card
class_name LuminaryScoutCard

func _init():
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.UNIT)
	card_name = "Scout"

func activate(for_player) -> void:
	var creature_ability = LuminaryScoutAbility.new(for_player)
	creature_ability.activate()

func can_activate(for_player) -> bool:
	var creature_ability = LuminaryScoutAbility.new(for_player)
	return creature_ability.can_trigger()
