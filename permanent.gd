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
var formation_placeholder

onready var name_label = $Label

func init(f_player_owner, f_network_id = -1):
	if f_network_id == -1:
		network_id = SteamController.get_next_network_id()
	else:
		network_id = f_network_id
	SteamController.network_items_by_id[network_id] = self
	
	player_owner = f_player_owner

func _ready():
	var _unused = connect("gui_input", self, "on_gui_input")
	_unused = connect("targeted", TargetHelper, "on_target_selected")
	
	update_name_label()

func on_gui_input(event):
	if event.is_pressed():
		if not SteamController.has_priority:
			return
			
		if player_owner.player_id != SteamController.self_peer_id:
			return
		
		if GameController.is_targeting:
			emit_signal("targeted", self)
		else:
			if GameController.interaction_phase:
				
				# TODO Check for normal abilities that can trigger
				
				pass
			else:
				if abilities.size() == 1 and abilities[0].can_trigger():
					abilities[0].activate()

func die() -> void:
	erase_no_trigger()
	
	# TODO on death triggers
	if(card):
		player_owner.add_to_discard(card)

func erase() -> void:
	erase_no_trigger()

# Used to remove the permanent from wherever it is.  This is the function to
# call if you want to move the permanent from one zone to another.
func erase_no_trigger() -> void:
	if logic_container:
		logic_container.erase(self)
	tree_container.remove_child(self)

func tap() -> void:
	tapped = true
	name_label.text = card.card_name + "(T)"
	
func untap() -> void:
	tapped = false
	name_label.text = card.card_name

func serialize() -> Dictionary:
	var result_dict = {}
	
	result_dict.network_id = network_id
	result_dict.card = card.serialize()
	
	result_dict.damage = damage
	
	return result_dict

func load_data(permanent_data) -> void:
	card = CardLibrary.card_script_by_id[permanent_data.card.card_id].new(permanent_data.card.network_id)
	
	for ability_script in card.permanent_ability_scripts:
		var ability_instance = ability_script.new(card, player_owner)
		ability_instance.source = self
		ability_instance.main = player_owner.main
		abilities.push_back(ability_instance)
	damage = permanent_data.damage

# stat fields should be effective stat fields
func update_name_label() -> void:
	if card:
		name_label.text = card.card_name
	
	if toughness:
		 name_label.text = card.card_name + str("\n", power, "/", toughness)
