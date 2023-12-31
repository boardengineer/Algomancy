extends Node

# All yields should also yield to this to allow the game to be properly disconnected
signal cancel

var is_targeting = false
var main
var action_cancelled = false

var current_battlefields = []

var initiative_player
var game_over = false

# The player the game is waiting on unless both players are drafting
var priority_player

var num_nontoken_spells_this_skrimish
var num_units_died_this_skrimish

var interaction_phase = false
var phase = GamePhase.UNTAP
enum GamePhase {
	UNTAP,
	DRAW,
	DRAFT,
	MANA_TI,
	MANA_NTI,
	ATTACK_TI,
	BLOCK_TI,
	DAMAGE_TI,
	POST_COMBAT_TI,
	ATTACK_NTI,
	BLOCK_NTI,
	DAMAGE_NTI,
	POST_COMBAT_NTI,
	REGROUP,
	MAIN_TI,
	MAIN_NTI
	}

var initiative_battle_phases = [GamePhase.ATTACK_TI, GamePhase.BLOCK_TI, GamePhase.DAMAGE_TI, GamePhase.POST_COMBAT_TI]
var non_init_battle_phases = [GamePhase.ATTACK_NTI, GamePhase.BLOCK_NTI, GamePhase.DAMAGE_NTI, GamePhase.POST_COMBAT_NTI]

var yielding_phases := [GamePhase.DRAFT, GamePhase.MANA_TI, GamePhase.ATTACK_TI, GamePhase.BLOCK_TI, GamePhase.MAIN_TI, GamePhase.POST_COMBAT_TI]

func should_yield_for_phase(the_phase) -> bool:
	return yielding_phases.has(the_phase)

func should_yield_for_current_phase() -> bool:
	return should_yield_for_phase(phase)

func get_current_battlefield_for_player(player):
	if initiative_battle_phases.has(phase):
		return player.battlefields[get_nti_player()]
			
	if non_init_battle_phases.has(phase):
		return player.battlefields[get_ti_player()]
	
	return player.battlefields[player]

func get_current_battlefields() -> Array:
	if phase == GamePhase.MAIN_TI:
		var current_player = get_ti_player()
		return [current_player.battlefields[current_player]]
	
	if phase == GamePhase.MAIN_NTI:
		var current_player = get_nti_player()
		return [current_player.battlefields[current_player]]
	
	if initiative_battle_phases.has(phase):
		var home_player = get_nti_player()
		var other_player = get_ti_player()
		var results = []
		results.push_back(home_player.battlefields[home_player])
		results.push_back(other_player.battlefields[home_player])
		return results
	
	if non_init_battle_phases.has(phase):
		var home_player = get_ti_player()
		var other_player = get_nti_player()
		var results = []
		results.push_back(home_player.battlefields[home_player])
		results.push_back(other_player.battlefields[home_player])
		return results
	
	return []

func get_active_formation():
	if initiative_battle_phases.has(phase):
		if initiative_player == get_self_player():
			return main.player_attack_formation
		else:
			return main.player_block_formation
	elif non_init_battle_phases.has(phase):
		if initiative_player == get_self_player():
			return main.player_block_formation
		else:
			return main.player_attack_formation
	
	return null

func is_in_battle() -> bool:
	return initiative_battle_phases.has(phase) or non_init_battle_phases.has(phase)

func is_in_battle_interactions() -> bool:
	return interaction_phase and is_in_battle()

func is_declaring_attackers() -> bool:
	return phase == GamePhase.ATTACK_TI and not interaction_phase

func is_in_mana_phase() -> bool:
	return phase == GamePhase.MANA_TI or phase == GamePhase.MANA_NTI
	
func is_in_main_phase() -> bool:
	return phase == GamePhase.MAIN_TI or phase == GamePhase.MAIN_NTI

func set_up_references(main_game) -> void:
	main = main_game

func save_game():
	var save_file := File.new()
	var _error = save_file.open("user://algomancy_save.save", File.WRITE)
	
	var serialized_state = main.serialize()
	
	save_file.store_string(serialized_state)
	save_file.close()
	
func load_game():
	print_debug("loading game")
	
	cancel_all_yields()
	var load_file := File.new()
	
	for key in SteamController.network_items_by_id:
		SteamController.network_items_by_id.erase(key)
	
	var _error = load_file.open("user://algomancy_save.save", File.READ)
	var content = load_file.get_as_text()
	load_file.close()
	
	action_cancelled = false
	main.deserialize_and_load(content)

func cancel_all_yields() -> void:
	action_cancelled = true
	emit_signal("cancel")

# return all the abilities that might trigger
func get_all_triggerable_abilities() -> Array:
	var result := []
	
	for battlefield in get_current_battlefields():
		for permanent in battlefield:
			result.append_array(permanent.abilities)
	
	if is_in_battle():
		for unit in get_active_formation().get_all_units():
			result.append_array(unit.abilities)
	
	return result

func peform_on_block_triggers() -> void:
	for ability in get_all_triggerable_abilities():
		ability.on_block()

func peform_on_attack_triggers() -> void:
	for ability in get_all_triggerable_abilities():
		ability.on_attack()

func perform_on_end_of_combat_triggers() -> void:
	for ability in get_all_triggerable_abilities():
		ability.on_end_of_combat()

func perform_on_end_of_turn_triggers() -> void: 
	for battlefield in get_current_battlefields():
		var index = 0
		for permanent in battlefield:
			for ability in permanent.abilities:
				ability.on_end_of_turn(index)
				index += 1
	
	if is_in_battle():
		for unit in get_active_formation().get_all_units():
			var index = 0
			for ability in unit.abilities:
				ability.on_end_of_turn(index)
				index += 1

func update_static_state() -> void:
	var all_units := []
	for player in main.players:
		for battlefield_player in player.battlefields:
			var battlefield = player.battlefields[battlefield_player]
			for permanent in battlefield:
				if permanent.toughness:
					all_units.push_back(permanent)
	
	if is_in_battle():
		for formation_unit in get_active_formation().get_all_units():
			if formation_unit.toughness:
					all_units.push_back(formation_unit)
	
	for unit in all_units:
		unit.update_power_toughness(unit.card.power, unit.card.toughness)
	
	for maybe_static_ability in get_all_triggerable_abilities():
		if maybe_static_ability.is_static:
			maybe_static_ability.apply_static_effect()
	
	for unit in all_units:
		if unit.damage >= unit.toughness:
			unit.die()
	

func get_player_for_id(player_id):
	for player in main.players:
		if player.player_id == player_id:
			return player
	
	return null

func get_ti_player():
	return initiative_player

func get_nti_player():
	for player in main.players:
		if player != initiative_player:
			return player
	return null

func get_self_player():
	for player in main.players:
		if player.player_id == SteamController.self_peer_id:
			return player
	return null

func get_opponent_player():
	for player in main.players:
		if player.player_id != SteamController.self_peer_id:
			return player
	return null

