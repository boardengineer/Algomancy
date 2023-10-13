 extends VBoxContainer

var units_in_formation = 0
var formation
var network_id

var should_spam = false

onready var player_units = $PlayerUnits
onready var opponent_units = $OpponentUnits

func _process(_delta):
	if should_spam:
		print_debug(opponent_units.get_child_count())

func init(f_network_id = -1):
	if SteamController.latest_network_id <= f_network_id:
		SteamController.latest_network_id = f_network_id + 1
	
	if f_network_id == -1:
		network_id = SteamController.get_next_network_id()
	else:
		network_id = f_network_id
	
	SteamController.network_items_by_id[str(network_id)] = self
	
	for child in player_units.get_children():
		player_units.remove_child(child)
	
	for child in opponent_units.get_children():
		opponent_units.remove_child(child)
		
	player_units.add_child(create_placeholder_permanent())
	

func get_available_positions() -> Array:
	if units_in_formation >= 2:
		return []
		
	return [player_units.get_child(player_units.get_child_count() - 1)]

func create_placeholder_permanent():
	var result = CardLibrary.permanent_for_owner(TargetHelper.get_player_for_id(SteamController.self_peer_id))
	
	result.tree_container = self
	result.is_formation_placeholder = true
	
	return result

func add_to_back_of_player_column(unit_permanent, is_command = false) -> void:
	unit_permanent.erase_no_trigger()
	unit_permanent.is_in_formation = true
	
	var should_add_column_after = units_in_formation == 0
	
	var last_child = player_units.get_child(player_units.get_child_count() - 1)
#	print_debug(last_child.network_id)
	player_units.remove_child(last_child)
	
	player_units.add_child(unit_permanent)
	
	unit_permanent.tree_container = player_units
#	unit_permanent.is_formation_placeholder = true
	
	units_in_formation += 1
	
	if not is_command and not GameController.interaction_phase:
		if units_in_formation < 2:
			player_units.add_child(create_placeholder_permanent())
	
		if should_add_column_after:
			formation.create_new_columns()

func add_to_back_of_opponent_column(unit_permanent) -> void:
	unit_permanent.erase_no_trigger()
	unit_permanent.is_in_formation = true
	
	opponent_units.add_child(unit_permanent)
	unit_permanent.tree_container = opponent_units
	
	units_in_formation += 1

func remove_from_column(unit_permanent) -> void:
	var start_removing = false
	var nodes_to_erase = []
	
	for child in player_units.get_children():
		if child == unit_permanent:
			start_removing = true
		
		if start_removing and not child.is_formation_placeholder:
			nodes_to_erase.push_back(child)

	for child in nodes_to_erase:
		child.erase_no_trigger()
		var owner = child.player_owner
		
		# TODO: correct battlefield, not always "home" field
		owner.add_permanent(child, owner.battlefields[owner])
		
		child.is_in_formation = false
		
	units_in_formation -= nodes_to_erase.size()
	
	if units_in_formation == 0:
		formation.maybe_remove_column(self)
	else:
		add_child(create_placeholder_permanent())

func get_player_units_to_return() -> Array:
	var all_units = []
	
	for child in player_units.get_children():
		if not child.is_formation_placeholder:
			all_units.push_back(child)
	
	return all_units

func get_opponent_units_to_return() -> Array:
	var all_units = []
	
	for child in opponent_units.get_children():
		if not child.is_formation_placeholder:
			all_units.push_back(child)
	
	return all_units


func serialize() -> Dictionary:
	var result_dict = {}
	
	result_dict.network_id = network_id
	
	var player_units_dict := []
	for perm_child in player_units.get_children():
		if not perm_child.is_formation_placeholder:
			player_units_dict.push_back(perm_child.serialize())
	result_dict[str(SteamController.self_peer_id)] = player_units_dict
	
	var opp_units_dict := []
	for perm_child in opponent_units.get_children():
		if not perm_child.is_formation_placeholder:
			opp_units_dict.push_back(perm_child.serialize())
	var other_player_id = GameController.get_opponent_player().player_id
	result_dict[str(other_player_id)] = opp_units_dict
	
	
	
	# TODO other side
#	var opponent_player_dict = {}
#	opponent_player_dict.player_id = 
		
		
#	result_dict.
	
	return result_dict

func load_data(column_dict:Dictionary) -> void:
	var desrialized_network_id = column_dict.network_id
	init(desrialized_network_id)
	
	var other_player = GameController.get_opponent_player()
	var my_player = GameController.get_self_player()
	
	for perm_dict in column_dict[my_player.player_id]:
		var permanent_to_add = CardLibrary.permanent_for_owner(my_player, perm_dict.network_id)
		permanent_to_add.player_owner = my_player
		permanent_to_add.load_data(perm_dict)
		
		add_to_back_of_player_column(permanent_to_add)
	
	for perm_dict in column_dict[other_player.player_id]:
		var permanent_to_add = CardLibrary.permanent_for_owner(other_player, perm_dict.network_id)
		permanent_to_add.player_owner = other_player
		permanent_to_add.load_data(perm_dict)
		
		add_to_back_of_opponent_column(permanent_to_add)

func get_all_units() -> Array:
	var result := []
	
	for unit in player_units.get_children():
		if not unit.is_formation_placeholder:
			result.push_back(unit)
	
	for unit in opponent_units.get_children():
		if not unit.is_formation_placeholder:
			result.push_back(unit)
	
	return result
