extends ColorRect
class_name StackAbilityContainer

signal targeted


var logic_container
var tree_container

# null for tokens
var ability

func _init(for_ability):
	rect_min_size.x = 50
	rect_min_size.y = 70
	
	ability = for_ability

func _ready():
	var _unused = connect("gui_input", self, "on_input")
	_unused = connect("targeted", TargetHelper, "on_target_selected")
	
	var name_label = Label.new()
	
	if ability.card:
		name_label.text = ability.card.card_name

	name_label.rect_min_size.x = 50
	name_label.rect_min_size.y = 70
	
	name_label.add_color_override("font_color", Color(0,0,0))
	
	name_label.align = Label.ALIGN_CENTER
	name_label.valign = Label.ALIGN_CENTER
	
	call_deferred("add_child", name_label)

func on_input(event):
	if event.is_pressed():
		if not SteamController.has_priority:
			return
		
		if GameController.is_targeting:
			emit_signal("targeted", self)

func erase() -> void:
	logic_container.erase(self)
	tree_container.remove_child(self)
