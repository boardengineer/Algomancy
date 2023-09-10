extends Permanent
class_name ManaConverterPermanent

func _init(f_player_owner).(f_player_owner.main):
	var ability = ManaConverterAbility.new(f_player_owner)
	ability.source = self
	ability.main = f_player_owner.main
	card = ManaConverterCard.new()
	ability.card = card
	
	abilities.push_back(ability)
