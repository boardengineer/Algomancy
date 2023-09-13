extends Card
class_name ManaConverterCard

func _init(f_network_id = -1).(f_network_id):
	card_name = "MC"
	
	card_id = "base_mana_converter"
	permanent_ability_scripts.push_back(ManaConverterAbility)
