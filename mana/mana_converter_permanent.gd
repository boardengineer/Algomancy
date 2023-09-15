extends Permanent
class_name ManaConverterPermanent

func _init(f_player_owner).(f_player_owner):
	var ability = ManaConverterAbility.new(null, f_player_owner)
	ability.source = self
	ability.main = f_player_owner.main
	card = ManaConverterCard.new()
	ability.card = card
	
	abilities.push_back(ability)
