extends Card
class_name LightningBoltCard

func _init(f_network_id = -1).(f_network_id):
	threshold_requirement = [1,0,0,0,0]
	cost = 1
	
	types.push_back(CardType.UNIT)
	card_name = "bolt"
	card_id = "test_lightning_bolt"
