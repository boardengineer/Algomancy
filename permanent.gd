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

func _init(f_player_owner):
	rect_min_size.x = 50
	rect_min_size.y = 70
	
	player_owner = f_player_owner

func _ready():
	var _unused = connect("gui_input", self, "on_card_input")
	_unused = connect("targeted", TargetHelper, "on_target_selected")
	
	var name_label = Label.new()
	
	name_label.text = card.card_name

	name_label.rect_min_size.x = 50
	name_label.rect_min_size.y = 70
	
	name_label.add_color_override("font_color", Color(0,0,0))
	
	name_label.align = Label.ALIGN_CENTER
	name_label.valign = Label.ALIGN_CENTER
	
	call_deferred("add_child", name_label)

func on_card_input(event):
	if event.is_pressed():
		if not SteamController.has_priority:
			return
			
		if player_owner.player_id != SteamController.self_peer_id:
			return
		
		if GameController.is_targeting:
			emit_signal("targeted", self)
		else:
			if abilities.size() == 1:
				abilities[0].activate()

func erase() -> void:
	logic_container.erase(self)
	tree_container.remove_child(self)
