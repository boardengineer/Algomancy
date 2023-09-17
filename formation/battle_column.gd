extends VBoxContainer

var units_in_formation = 0
var formation

func _ready():
	for child in get_children():
		remove_child(child)
	
	add_child(create_placeholder_permanent())

func get_available_positions() -> Array:
	if units_in_formation >= 2:
		return []
		
	return [get_child(get_child_count() - 1)]

func create_placeholder_permanent():
	var result = CardLibrary.permanent_for_owner(SteamController.self_peer_id)
	
	result.tree_container = self
	result.formation_placeholder = true
	
	return result

func add_to_back_of_column(unit_permanent) -> void:
	var should_add_column_after = units_in_formation == 0
	
	var last_child = get_child(get_child_count() - 1)
	remove_child(last_child)
	
	add_child(unit_permanent)
	units_in_formation += 1
	
	if should_add_column_after:
		formation.create_new_columns()
