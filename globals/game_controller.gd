extends Node

signal activated_ability_or_passed

var is_targeting = false
var main

var phase = GamePhase.UNTAP
var current_battlefields = []
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

func is_in_mana_phase() -> bool:
	return phase == GamePhase.MANA_TI or phase == GamePhase.MANA_NTI
	
func is_in_main_phase() -> bool:
	return phase == GamePhase.MAIN_TI or phase == GamePhase.MAIN_NTI

func set_up_references(main_game) -> void:
	main = main_game

func save_game():
	var save_file := File.new()
	save_file.open("user://algomancy_save.save", File.WRITE)
	
	save_file.store_string(main.serialize())
	save_file.close()
	
func load_game():
	var load_file := File.new()
	
	load_file.open("user://algomancy_save.save", File.READ)
	var content = load_file.get_as_text()
	load_file.close()
	
	main.deserialize_and_load(content)
