extends Ability
class_name LightningBoltAbility

var LIGHTNING_BOLT_DAMAGE = 3

func _init(f_card, f_player_owner).(f_card, f_player_owner):
	card = f_card
	effects.push_back(DamageAnyTargetEffect.new(LIGHTNING_BOLT_DAMAGE, self, f_player_owner))

func can_trigger() -> bool:
	if not GameController.is_in_battle_interactions():
		return false
	
	if not player_owner.meets_mana_cost(card):
		return false
	
	return true

func pay_cost() -> bool:
	player_owner.pay_mana(card.cost)
	
	player_owner.remove_from_hand(card)

	return true
