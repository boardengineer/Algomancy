extends Control

signal targeted

onready var text_label = $MarginContainer/CardImage/Label

var text = ""
var resource_card

func _ready():
	var _unused = connect("gui_input", self, "on_gui_input")
	_unused = connect("targeted", TargetHelper, "on_target_selected")
	
	var my_style = StyleBoxFlat.new()
	my_style.set_bg_color(Color(0,1,1,1))
	text_label.text = text
	set("custom_styles/normal", my_style)

func on_gui_input(event):
	if event.is_pressed():
		if not SteamController.has_priority:
			return
		
		if GameController.is_tageting:
			emit_signal("targeted", self)
