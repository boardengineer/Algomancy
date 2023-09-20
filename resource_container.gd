extends Control

signal targeted

onready var text_label = $MarginContainer/CardImage/Label
onready var clickable_container = $MarginContainer/CardImage

var text = ""
var resource_card
var network_id

func _init():
	network_id = SteamController.get_next_network_id()
	SteamController.network_items_by_id[network_id] = self

# has to be called on load
func set_network_id(f_network_id):
	SteamController.network_items_by_id.erase(network_id)
	network_id = f_network_id
	SteamController.network_items_by_id[network_id] = self

func _ready():
	var _unused = clickable_container.connect("gui_input", self, "on_gui_input")
	_unused = connect("targeted", TargetHelper, "on_target_selected")
	
	var my_style = StyleBoxFlat.new()
	my_style.set_bg_color(Color(0,1,1,1))
	text_label.text = text
	set("custom_styles/normal", my_style)

func on_gui_input(event):
	if event.is_pressed():
		if not SteamController.has_priority:
			return
		
		if GameController.is_targeting:
			emit_signal("targeted", self)
