extends ColorRect
class_name HandCard

var card
var selected = false

var player_owner
var resource_from_hand_ability = load("res://mana/resource_from_hand_ability.gd")

var network_id

func _init(source_card, f_player_owner, f_network_id = -1):
	if f_network_id == -1:
		network_id = SteamController.get_next_network_id()
	else:
		network_id = f_network_id
	
	SteamController.network_items_by_id[network_id] = self
	
	rect_min_size.x = 50
	rect_min_size.y = 70
	
	card = source_card
	player_owner = f_player_owner
	
func _ready():
	var _unused = connect("gui_input", self, "on_card_input")
	
	var name_label = Label.new()
	
	name_label.text = card.card_name

	name_label.rect_size.x = 50
	name_label.rect_size.y = 70
	
	name_label.add_color_override("font_color", Color(0,0,0))
	
	name_label.align = Label.ALIGN_CENTER
	name_label.valign = Label.ALIGN_CENTER
	
	size_flags_horizontal = 0
	size_flags_vertical = 0
	
	call_deferred("add_child", name_label)

func on_card_input(event):
	if event.is_pressed():
		if not SteamController.has_priority:
			return
			
		var is_resource = false
		for type in card.types:
			if type == Card.CardType.RESOURCE:
				is_resource = true
		
		if is_resource:
			if GameController.is_in_mana_phase():
				var ability = resource_from_hand_ability.new(card, player_owner)
				if ability.can_trigger():
					ability.source = self
					ability.main = player_owner.main
					ability.card = card
					if ability.can_trigger():
						ability.activate()
		else:
			var possible_abilities = []
			if not GameController.is_targeting:
				if GameController.is_in_mana_phase():
					var ability = ManaTradeAbility.new(null, player_owner)
					ability.source = card
					ability.main = player_owner.main
					ability.card = card
					if ability.can_trigger():
						possible_abilities.push_back(ability)
				
				if card.ability_scripts.size() == 1:
					var ability = card.ability_scripts[0].new(card, player_owner)
					
					if ability.can_trigger():
						possible_abilities.push_back(ability)
				
				if possible_abilities.size() == 1:
					var to_activate = possible_abilities[0]
					to_activate.source = self
					var _on_stack = to_activate.activate()
				

func activate_ability(ability_index:int, serialized_effects:Array) -> void:
	var possible_abilities = []
	
	var is_resource = false
	for type in card.types:
		if type == Card.CardType.RESOURCE:
			is_resource = true
	
	if is_resource:
			if GameController.is_in_mana_phase():
				var ability = resource_from_hand_ability.new(card, player_owner)
				ability.source = self
				ability.main = player_owner.main
				if ability.pay_cost():
					ability.resolve()
				return
	
	if not GameController.is_targeting:
		if GameController.is_in_mana_phase():
			var ability = ManaTradeAbility.new(null, player_owner)
			ability.source = card
			ability.main = player_owner.main
			ability.card = card
			if ability.can_trigger():
				possible_abilities.push_back(ability)
			
		if card.ability_scripts.size() == 1:
			var ability = card.ability_scripts[0].new(card, player_owner)
			possible_abilities.push_back(ability)
	
	if possible_abilities.size() > ability_index:
		var to_activate = possible_abilities[ability_index]
		
		for effect_index in serialized_effects.size():
			var ability_effect = to_activate.effects[effect_index]
			var effect_dict = serialized_effects[effect_index]
			
			var deserialized_targets = []
			for serialized_target in effect_dict.targets:
				deserialized_targets.push_back(SteamController.network_items_by_id[serialized_target])
				
			ability_effect.targets = deserialized_targets
		
		if to_activate.pay_cost():
			if to_activate.goes_on_stack:
				player_owner.main.add_to_ability_stack(to_activate)
			else:
				to_activate.resolve()
