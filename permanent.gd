extends ColorRect
class_name Permanent

signal targeted

var abilities = []

var tapped = false

var logic_container
var tree_container

# null for tokens
var card
var main

var player_owner

var power
var toughness
var damage = 0

var network_id

# TODO for now formation placeholder are permanents
var is_formation_placeholder = false
var is_in_formation = false

onready var name_label = $Label

func init(f_player_owner, f_network_id = -1):
	if SteamController.latest_network_id <= f_network_id:
		SteamController.latest_network_id = f_network_id + 1
	
	if f_network_id == -1:
		network_id = SteamController.get_next_network_id()
	else:
		network_id = f_network_id
	
	SteamController.network_items_by_id[str(network_id)] = self
	
	player_owner = f_player_owner
	is_in_formation = false

func _ready():
	var _unused = connect("gui_input", self, "on_gui_input")
	_unused = connect("targeted", TargetHelper, "on_target_selected")
	
	update_name_label()

func on_gui_input(event):
	if event.is_pressed():
		if GameController.is_targeting:
			emit_signal("targeted", self)
		else:
			if player_owner != GameController.priority_player:
				return
			
			if not player_owner:
				return
				
			if toughness and GameController.is_declaring_attackers():
				if is_in_formation:
					get_parent().get_parent().remove_from_column(self)
				else:
					TargetHelper.get_targets_for_attack(self)
				return
			
			if player_owner.player_id != SteamController.self_peer_id:
				return
				
			if abilities.size() == 1 and abilities[0].can_trigger():
				abilities[0].activate()

func process_activation_signal() -> void:
	pass

func activate_ability(ability_index:int, serialized_effects:Array) -> void:
	var possible_abilities = []
	
	# TODO check for invalid timings and indeces
	if abilities.size() == 1 and abilities[0].can_trigger():
		possible_abilities.push_back(abilities[0])
	
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

func sacrifice() -> void:
	# TODO sacrifice triggers go here
	
	die()

func die() -> void:
	erase_no_trigger()
	
	# TODO on death triggers
	if card:
		player_owner.add_to_discard(card)

func erase() -> void:
	erase_no_trigger()

# Used to remove the permanent from wherever it is.  This is the function to
# call if you want to move the permanent from one zone to another.
func erase_no_trigger() -> void:
	if logic_container:
		logic_container.erase(self)
	if tree_container:
		tree_container.remove_child(self)

func tap() -> void:
	tapped = true
	update_name_label()
	
func untap() -> void:
	tapped = false
	update_name_label()

func serialize() -> Dictionary:
	var result_dict = {}
	
	result_dict.network_id = network_id
	result_dict.card = card.serialize()
	
	result_dict.damage = damage
	result_dict.toughness = toughness
	result_dict.power = power
	result_dict.tapped = tapped
	
	return result_dict

func load_data(permanent_data) -> void:
	card = CardLibrary.card_script_by_id[permanent_data.card.card_id].new(permanent_data.card.network_id)
	
	for ability_script in card.permanent_ability_scripts:
		var ability_instance = ability_script.new(card, player_owner)
		ability_instance.source = self
		ability_instance.main = player_owner.main
		abilities.push_back(ability_instance)
	
	damage = permanent_data.damage
	toughness = permanent_data.toughness
	power = permanent_data.power
	
	tapped = permanent_data.tapped

# stat fields should be effective stat fields
func update_name_label() -> void:
	if card:
		name_label.text = card.card_name
	
	if toughness:
		 name_label.text = card.card_name + str("\n", power, "/", toughness)
		
	if tapped:
		name_label.text += "\n(T)"

func get_id():
	return network_id
