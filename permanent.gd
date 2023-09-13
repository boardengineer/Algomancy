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
var name_label

var power
var toughness
var damage 

var network_id

func _init(f_player_owner, f_network_id = -1):
	rect_min_size.x = 50
	rect_min_size.y = 70
	
	if f_network_id == -1:
		network_id = SteamController.get_next_network_id()
	else:
		network_id = f_network_id
	SteamController.network_items_by_id[network_id] = self
	
	player_owner = f_player_owner

func _ready():
	var _unused = connect("gui_input", self, "on_gui_input")
	_unused = connect("targeted", TargetHelper, "on_target_selected")
	
	name_label = Label.new()
	
	name_label.text = card.card_name

	name_label.rect_min_size.x = 50
	name_label.rect_min_size.y = 70
	
	name_label.add_color_override("font_color", Color(0,0,0))
	
	name_label.align = Label.ALIGN_CENTER
	name_label.valign = Label.ALIGN_CENTER
	
	call_deferred("add_child", name_label)

func on_gui_input(event):
	if event.is_pressed():
		print_debug("gui pressed")
		if not SteamController.has_priority:
			print_debug("gui pressed stop 1")
			return
			
		if player_owner.player_id != SteamController.self_peer_id:
			print_debug("gui pressed stop 2")
			return
		
		if GameController.is_targeting:
			print_debug("gui pressed stop 3")
			emit_signal("targeted", self)
		else:
			print_debug("gui pressed stop 4")
			if abilities.size() == 1:
				print_debug("gui pressed stop 5")
				abilities[0].activate()

func erase() -> void:
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
	# network id is set by the constructor
	
	var card_from_data = Card.new(permanent_data.card.network_id)
	card_from_data.load_data(permanent_data.card)
	card = card_from_data
	
	damage = permanent_data.damage
