extends ColorRect
class_name HandCard

var card
var selected = false

var player_owner

func _init(source_card, f_player_owner):
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
#			TODO play the resource here
			pass
		else:
#			TODO check phases, this is only mana
			var ability = ManaTradeAbility.new(player_owner)
			ability.source = card
			ability.main = player_owner.main
			ability.card = card
			if ability.can_trigger():
				ability.activate()
