extends Node2D

# There will always be an empty column to the left and the right of the current
# Formation
onready var battle_columns = $Columns

var column_scene = load("res://formation/battle_column.tscn")

func init_empty_formation() -> void:
	for column_child in battle_columns.get_children():
		battle_columns.remove_child(column_child)
		
	battle_columns.add_child(create_column())

func get_possible_positions_for_unit(_unit_to_place):
	var result = []
	
	for column in battle_columns.get_children():
		result.append_array(column.get_available_positions())
		
	return result

func create_column():
	var column = column_scene.instance()
	
	column.reset_formation()
	column.formation = self
	
	return column

func create_new_columns():
	var should_add_front = battle_columns.get_child(0).units_in_formation > 0
	var should_add_back  = battle_columns.get_child(battle_columns.get_child_count() - 1).units_in_formation > 0
	
	if should_add_front:
		var new_column = create_column()
		battle_columns.add_child(new_column)
		battle_columns.move_child(new_column, 0)
		
	if should_add_back:
		var new_column = create_column()
		battle_columns.add_child(new_column)
		
func is_formation_valid() -> bool:
	return true

func show() -> void:
	get_parent().show()
	
func hide():
	get_parent().hide()

func maybe_remove_column(column_to_remove) -> void:
	var column_index = -1
	
	for column_child_index in battle_columns.get_child_count():
		var column_child = battle_columns.get_children()[column_child_index]
		if column_child == column_to_remove:
			column_index = column_child_index
	
	if column_index > 0 and column_index < battle_columns.get_child_count() - 1:
		battle_columns.remove_child(column_to_remove)

func return_all_units() -> void:
	var to_remove = []
	
	for column in battle_columns.get_children():
		for unit in column.get_units_to_return():
			to_remove.push_back(unit)
	
	for unit in to_remove:
		unit.erase()
		unit.player_owner.add_permanent(unit, unit.player_owner.battlefields[unit.player_owner])

func get_formation_command_dict() -> Dictionary:
	var result := {}
		
	var formation_array := []
	for column_child in battle_columns.get_children():
		var column_array := []
		
		var num_units = column_child.units_in_formation
		if num_units < 1:
			continue
			
		for permanent_index in num_units:
			var permanent = column_child.get_children()[permanent_index]
			column_array.push_back(permanent.network_id)
		
		formation_array.push_back(column_array)
	
	result.formation = formation_array
	return result

