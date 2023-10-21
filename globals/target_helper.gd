extends Node

signal targeting_complete
signal target_added

var valid_targets = []
var selected_targets = []

var main = null

func get_targets_for_effect(effect) -> void:
	GameController.is_targeting = true
	main.target_image.show()
	selected_targets = effect.targets
	while selected_targets != null and effect.needs_more_targets(selected_targets):
		valid_targets = effect.get_valid_targets(selected_targets)
		
		for resource in get_all_resource_targets():
			if valid_targets.has(resource):
				main.basic_resource_dialog.show()
		
		yield(self, "target_added")
		
		main.basic_resource_dialog.hide()
	
	GameController.is_targeting = false
	main.target_image.hide()
	emit_signal("targeting_complete")

func get_targets_for_attack(permanent) -> void:
	GameController.is_targeting = true
	
	valid_targets = main.player_attack_formation.get_possible_positions_for_unit(permanent)
	main.target_image.show()
	selected_targets.clear()
	yield(self, "target_added")
	
	GameController.is_targeting = false
	var formation_position = selected_targets[0]
	
	if formation_position.is_formation_placeholder:
		formation_position.get_parent().get_parent().add_to_back_of_player_column(permanent)
	
	main.target_image.hide()
	emit_signal("targeting_complete")

func on_target_selected(target) -> void:
	if GameController.is_targeting and valid_targets.has(target):
		selected_targets.push_back(target)
		emit_signal("target_added")

func get_player_self():
	for player in main.players:
		if player.id == SteamController.self_peer_id:
			return player

func on_cancelled() -> void:
	if GameController.targeting:
		selected_targets = null
		emit_signal("target_added")

func set_up_references(main_game) -> void:
	main = main_game

func get_all_resource_targets() -> Array:
	var result = []
	
	result.push_back(get_basic_wood_target())
	result.push_back(get_basic_fire_target())
	
	return result

func get_basic_wood_target():
	return main.basic_resource_container.get_node("Wood")
	
func get_basic_fire_target():
	return main.basic_resource_container.get_node("Fire")
	
func get_all_targets() -> Array:
	var all_targets := []
	
	for player in main.players:
		all_targets.push_back(player)
		
	for battlefield in GameController.get_current_battlefields():
		for unit in battlefield:
			if unit.toughness:    
				all_targets.push_back(unit)
	
	if GameController.is_in_battle():
		all_targets.append_array(GameController.get_active_formation().get_all_units())
	
	return all_targets

func get_targetable_players() -> Array:
	# TODO proper targetable logic
	var res_players = []
	for player in main.players:
		res_players.push_back(player)
	
	return res_players

func get_player_for_id(query_id):
	for player in main.players:
		if player.player_id == query_id:
			return player
	
	return null
