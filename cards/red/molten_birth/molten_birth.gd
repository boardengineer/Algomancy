extends Card
class_name MoltenbirthCard

func _init(f_network_id = -1).(f_network_id):
	threshold_requirement = [2,0,0,0,0]
	cost = 2
	
	types.push_back(CardType.SPELL)
	
	card_name = "mbirt"
	card_id = "base_molten_birth"
	
	ability_scripts.push_back(MoltenBirthAbility)
