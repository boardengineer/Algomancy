extends Node2D

# There will always be an empty column to the left and the right of the current
# Formation
onready var battle_columns = $Columns

var column_scene = load("res://battle_column.tscn")

func init_empty_formation() -> void:
	for column_child in battle_columns.get_children():
		battle_columns.remove_child(column_child)
		
	battle_columns.add_child(create_column())

func get_possible_positions_for_unit(unit_to_place):
	var result = []
	
	for column in battle_columns.get_children():
		result.append_array(column.get_available_positions())
		
	return result

func create_column():
	var column = column_scene.instance()
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
