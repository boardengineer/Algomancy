extends Card
class_name UnitCard

# Superclass for unit class with a handful of useful bindings
func activate(for_player) -> void:
	var unit_ability = UnitCardAbility.new(self, for_player)
	unit_ability.activate()

func can_activate(for_player) -> bool:
	var unit_ability = UnitCardAbility.new(self, for_player)
	return unit_ability.can_trigger()
