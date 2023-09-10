extends ColorRect
class_name Permanent

signal targeted

var abilities = []

var tapped = false

# null for tokens
var card

func _ready():
	var _unused = connect("gui_input", self, "on_card_input")
	_unused = connect("targeted", TargetHelper, "on_target_selected")

func on_card_input(event):
	if event.is_pressed():
		if not SteamController.has_priority:
			return
		
		if GameController.is_tageting:
			emit_signal("targeted", self)
		else:
			if abilities.size() == 1:
				abilities[0].activate()
