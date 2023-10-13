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
	
	column.call_deferred("init")
	
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
		
	if column_index == 1 and battle_columns.get_child_count() == 2:
		battle_columns.remove_child(battle_columns.get_children()[0])

func return_all_attacking_units() -> void:
	var to_remove = []
	
	for column in battle_columns.get_children():
		for unit in column.get_player_units_to_return():
			to_remove.push_back(unit)
	
	for unit in to_remove:
		unit.erase()
		unit.is_in_formation = false
		unit.player_owner.add_permanent(unit, unit.player_owner.battlefields[unit.player_owner])
		
	init_empty_formation()

func return_all_player_units() -> void:
	var to_remove = []
	
	for column in battle_columns.get_children():
		for unit in column.get_player_units_to_return():
			to_remove.push_back(unit)
	
	for unit in to_remove:
		unit.erase()
		unit.is_in_formation = false
		unit.player_owner.add_permanent(unit, unit.player_owner.battlefields[unit.player_owner])

func return_all_opponent_units() -> void:
	var to_remove = []
	
	for column in battle_columns.get_children():
		for unit in column.get_opponent_units_to_return():
			to_remove.push_back(unit)
	
	for unit in to_remove:
		unit.erase()
		unit.is_in_formation = false
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
			var permanent = column_child.player_units.get_children()[permanent_index]
			column_array.push_back(permanent.network_id)
		
		formation_array.push_back(column_array)
	
	result.formation = formation_array
	return result

func apply_attack_formation_command(command_dict:Dictionary, my_attack:bool) -> void:
	if my_attack:
		return_all_player_units()
	else:
		return_all_opponent_units()
	
	for column_child in battle_columns.get_children():
		battle_columns.remove_child(column_child)
	
	var command_formation = command_dict.formation
	
	for column_array in command_formation:
		var column = create_column()
		battle_columns.add_child(column)
		for perm_id in column_array:
			var perm = SteamController.network_items_by_id[str(perm_id)]
			
			if my_attack:
				column.call_deferred("add_to_back_of_player_column", perm)
			else:
				column.call_deferred("add_to_back_of_opponent_column", perm)

#func apply_block_formation_command(command_dict)

func apply_block_formation_command(command_dict:Dictionary, my_block:bool) -> void:
	if my_block:
		return_all_player_units()
	else:
		return_all_opponent_units()
	
	var formation_dict = command_dict.formation
	for column_network_id in formation_dict:
		var column = SteamController.network_items_by_id[str(column_network_id)]
		for perm_id in command_dict.formation[column_network_id]:
			var perm = SteamController.network_items_by_id[str(perm_id)]
			if my_block:
				column.call_deferred("add_to_back_of_player_column", perm)
			else:
				column.call_deferred("add_to_back_of_opponent_column", perm)
	

func serialize() -> Array:
	var result_arr = []
	
	var populated_columns = Array(battle_columns.get_children())
	
	# Remove any empty columns on the edges
	while not populated_columns.empty() and populated_columns[0].units_in_formation == 0:
		populated_columns.pop_front()
		
	while not populated_columns.empty() and populated_columns[populated_columns.size() - 1].units_in_formation == 0:
		populated_columns.pop_back()
	
	for column in populated_columns:
		result_arr.push_back(column.serialize())
	
	return result_arr

func load_data(battle_column_dicts:Array) -> void:
	for column_child in battle_columns.get_children():
		battle_columns.remove_child(column_child)
	
	for column_dict in battle_column_dicts:
		var column = column_scene.instance()

		column.formation = self

		battle_columns.add_child(column)
		column.init()
		column.load_data(column_dict)

func get_all_units() -> Array:
	var result := []
	
	for column_child in battle_columns.get_children():
		result.append_array(column_child.get_all_units())
	
	return result
