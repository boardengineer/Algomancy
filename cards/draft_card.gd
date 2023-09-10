extends ColorRect
class_name DraftCard

var card
var selected = false

signal toggled

func _init(source_card):
	rect_min_size.x = 50
	rect_min_size.y = 70
	
	card = source_card
	
func _ready():
	var _unused = connect("gui_input", self, "on_card_input")
	
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
		selected = not selected
		
		if selected:
			color = Color(0, 1, 0, 1)
		else:
			color = Color(1, 1, 1, 1)
			
		emit_signal("toggled")
