extends VBoxContainer

signal draft_selection_complete(selected_cards)

onready var card_container = $CardContainer
onready var accept_button = $AcceptButton

func display_draft_pack(draft_pack) -> void:
	remove_all_cards()
	
	for card in draft_pack:
		var draft_card := DraftCard.new(card)
		
		var _unused = draft_card.connect("toggled", self, "on_card_toggled")
		
		card_container.add_child(draft_card)
	
	check_accept_button()
	
	show()

func remove_all_cards() -> void:
	for child in card_container.get_children():
		card_container.remove_child(child)

func _on_AcceptButton_pressed():
	var selected = []
	
	for draft_card in card_container.get_children():
		if draft_card.selected:
			selected.push_back(draft_card.card)
	
	emit_signal("draft_selection_complete", selected)

func on_card_toggled():
	check_accept_button()

func check_accept_button():
	var num_not_selected = 0
	
	for draft_card in card_container.get_children():
		if not draft_card.selected:
			num_not_selected += 1
	
	if num_not_selected == 10:
		accept_button.disabled = false
	else:
		accept_button.disabled = true
		
