extends Permanent
class_name ManaConverterPermanent

func init(f_player_owner, network_id = -1):
	.init(f_player_owner, network_id)
	
	var ability = ManaConverterAbility.new(null, f_player_owner)
	ability.source = self
	ability.main = f_player_owner.main
	card = ManaConverterCard.new()
	ability.card = card
	
	abilities.push_back(ability)
