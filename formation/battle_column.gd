 extends VBoxContainer

var units_in_formation = 0
var formation

func reset_formation():
	for child in get_children():
		remove_child(child)
	
	add_child(create_placeholder_permanent())

func get_available_positions() -> Array:
	if units_in_formation >= 2:
		return []
		
	return [get_child(get_child_count() - 1)]

func create_placeholder_permanent():
	var result = CardLibrary.permanent_for_owner(TargetHelper.get_player_for_id(SteamController.self_peer_id))
	
	result.tree_container = self
	result.is_formation_placeholder = true
	
	return result

func add_to_back_of_column(unit_permanent) -> void:
	unit_permanent.erase_no_trigger()
	unit_permanent.is_in_formation = true
	
	var should_add_column_after = units_in_formation == 0
	
	var last_child = get_child(get_child_count() - 1)
	remove_child(last_child)
	
	add_child(unit_permanent)
	
	unit_permanent.tree_container = self
#	unit_permanent.is_formation_placeholder = true
	
	units_in_formation += 1
	
	if units_in_formation < 2:
		add_child(create_placeholder_permanent())
	
	if should_add_column_after:
		formation.create_new_columns()

func remove_from_column(unit_permanent) -> void:
	var start_removing = false
	var nodes_to_erase = []
	
	for child in get_children():
		if child == unit_permanent:
			start_removing = true
		
		if start_removing and not child.is_formation_placeholder:
			nodes_to_erase.push_back(child)

	for child in nodes_to_erase:
		child.erase_no_trigger()
		var owner = child.player_owner
		
		# TODO: correct battlefield, not always "home" field
		owner.add_permanent(unit_permanent, owner.battlefields[owner])
		
		unit_permanent.is_in_formation = false
		
	units_in_formation -= nodes_to_erase.size()
	
	if units_in_formation == 0:
		formation.maybe_remove_column(self)

func get_units_to_return() -> Array:
	var all_units = []
	
	for child in get_children():
		if not child.is_formation_placeholder:
			all_units.push_back(child)
	
	return all_units
