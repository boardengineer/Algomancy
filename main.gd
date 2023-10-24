extends HBoxContainer

var players := []
var deck := []

var ability_stack := []

const NUM_PLAYERS := 2
const ResourceContainer = preload("res://resource_container.tscn")

signal activated_or_passed_or_cancelled
signal targeted_player
signal phase_completed

var first_turn = true

const STARTING_DRAFT_PACK_SIZE = 16
const RESOURCE_PLAYS_PER_TURN = 2
const DUMMY_PLAYER_ID = -1

onready var game_log = $GameLog
onready var draft_container = $DraftContainerPopup/PanelContainer/DraftContainer
onready var player_list = $Players

onready var opponent_field = $GameFields/OpponentField
onready var player_field = $GameFields/PlayerField
onready var player_away_field = $GameFields/PlayerAwayField

onready var hand_container = $GameFields/HandContainer

onready var player_discard_container = $PlayerDiscardHolder/Discard
onready var opponent_discard_container = $OpponentDiscardHolder/Discard

onready var stack_container = $Stack

onready var opponent_hand_container = $GameFields/OpponentHandCotainer

onready var basic_resource_container = $BasicResourcePopup/ResourceContainer/HBoxContainer
onready var basic_resource_dialog = $BasicResourcePopup/ResourceContainer
onready var pass_button = $Controls/PassButton

onready var player_attack_formation = $Formations/PlayerAttackFormationPanelContainer/PlayerAttackFormation
onready var accept_attack_formation_button = $Formations/PlayerAttackFormationPanelContainer/AcceptFormation

#onready var player_block_formation = $Formations/PlayerBlockFormationPanelContainer/PlayerBlockFormation
#onready var accept_block_formation_button = $Formations/PlayerBlockFormationPanelContainer/AcceptFormation

#onready var opponent_attack_formation = $Formations/OpponentAttackFormationPanelContainer/OpponentAttackFormation
#onready var opponent_block_formation = $Formations/OpponentBlockFormationPanelContainer/OpponentBlockFormation

onready var player_target_self = $PlayerTargets/SelfPlayerButton
onready var player_target_opponent = $PlayerTargets/OppPlayerButton

onready var target_image = $TargetContainer/TargetIcon

var current_player_passed

var use_dummy_opponent = true

# Called when the node enters the scene tree for the first time.
func _ready():
	TargetHelper.set_up_references(self)
	GameController.set_up_references(self)
	
	var _unused = SteamController.connect("activated_ability_or_passed", self, "on_activated_ability_or_passed")
	
	_unused = player_target_self.connect("gui_input", self, "player_self_gui_event")
	_unused = player_target_opponent.connect("gui_input", self, "player_opponent_gui_event")
	_unused = connect("targeted_player", TargetHelper, "on_target_selected")
	_unused = GameController.connect("cancel", self, "on_cancelled")
	
# Do init stuff in this function for easier modding
func init(is_host := true, f_tracked_players := {}) -> void:
	set_up_basic_resource_container()
	
	reset_all_visuals()
	set_up_battlefields()
	target_image.hide()
	
	if not is_host:
		print_debug("client sending started game")
		SteamController.send_game_started_status()
		return
	
	randomize()
	if f_tracked_players.size() < 2:
		players = []
		
		# init players
		for n in NUM_PLAYERS:
			var new_player
			if n == 0:
				new_player = Player.new(self, SteamController.self_peer_id)
			else:
				new_player = Player.new(self, DUMMY_PLAYER_ID)
			
			players.push_back(new_player)
	else:
		for player_id in f_tracked_players:
			var new_player = Player.new(self, player_id)
			players.push_back(new_player)
		
	for player in players:
		player.init_after_player_creation()
		player_list.add_child(player)
		
		player.call_deferred("add_starting_mana_converters")
	
	# init deck, this will probably be a resource file
	for card_script in CardLibrary.all_card_scripts:
		var card = card_script.new()
		deck.push_back(card)
		
	deck.shuffle()
		
	for player in players:
		for _n in STARTING_DRAFT_PACK_SIZE:
			var top_card = deck.pop_front()
#			log_message(s tr("adding ", top_card.card_name))
			player.draft_pack.push_back(top_card)
	
	first_turn = true
	
	# TODO remove when not debugging
	players[0].player_id = SteamController.self_peer_id
	
	SteamController.start_first_phase_when_all_ready()

func clear_stack_container() -> void:
	for child in stack_container.get_children():
		stack_container.remove_child(child)

func recycle_card(card) -> void:
	deck.push_back(card)

func set_up_basic_resource_container() -> void:
	for child in basic_resource_container.get_children():
		basic_resource_container.remove_child(child)
	
	var fire_container = ResourceContainer.instance()
	fire_container.text = "fire"
	fire_container.set_name("Fire")
	fire_container.set_network_id(-1000)
	fire_container.resource_card = Fire.new()
	basic_resource_container.add_child(fire_container)
	
	var wood_container = ResourceContainer.instance()
	wood_container.text = "wood"
	wood_container.set_name("Wood")
	wood_container.set_network_id(-1001)
	wood_container.resource_card = Wood.new()
	basic_resource_container.add_child(wood_container)
	
func init_untap_phase():
	log_message("Starting Untap Phase")
	
	# This shouldn't be here, move it to an init
	GameController.phase = GameController.GamePhase.UNTAP
	
func do_untap_phase():
	log_message("In Untap Phase")
	
	for player in players:
		for battlefield_players in player.battlefields:
			for permanent in player.battlefields[battlefield_players]:
				permanent.untap()
				
	init_draw_phase()
	emit_signal("phase_completed")

func init_draw_phase():
	log_message("Starting Draw Phase")
	GameController.phase = GameController.GamePhase.DRAW

func do_draw_phase():
	log_message("In Draw Step")
	
	GameController.phase = GameController.GamePhase.DRAW
	
	if not first_turn:
		for player in players:
			player.draw(2)
	else:
		log_message("skipping draw phase in the first turn")
		
	init_draft_phase()
	emit_signal("phase_completed")

func init_draft_phase():
	log_message("Starting Draft Phase")
	GameController.phase = GameController.GamePhase.DRAFT

func do_draft_phase():
	log_message("In Draft Phase")
	
	SteamController.start_draft()
	
	for player in players:
		player.draft()
	
	if use_dummy_opponent:
#		Fake receiving a message from the opponent
		var dummy_selections = []
		var opponent = SteamController.network_players_by_id[str(DUMMY_PLAYER_ID)]
		
		var num_to_draft = opponent.draft_pack.size() - 10
		for i in num_to_draft:
			dummy_selections.push_back(opponent.draft_pack[i].network_id)
		
#		var cards_to_select = opponent.
		SteamController.receive_draft_selection(DUMMY_PLAYER_ID, dummy_selections)
	
	
	draft_container.display_draft_pack(GameController.get_player_for_id(SteamController.self_peer_id).draft_pack)
	
	print_debug("waiting on draft yield")
	yield(SteamController, "draft_complete_or_cancelled")
	
	if not GameController.action_cancelled:
		for player in players:
			var selected_cards = SteamController.draft_selection_by_player_id[player.player_id]
			for card in selected_cards:
				player.draft_pack.erase(card)
				player.add_to_hand(card)
		
		draft_container.hide()
	
	init_mana_ti_phase()
	emit_signal("phase_completed")

func init_mana_ti_phase():
	log_message("Starting Mana TI phase")
	GameController.phase = GameController.GamePhase.MANA_TI

func do_mana_ti_phase():
	log_message("In Mana TI Phase")
	
	var active_player = GameController.get_ti_player()
	
	GameController.priority_player = active_player
	
	if first_turn:
		active_player.resource_plays_remaining = 0
	else:
		active_player.resource_plays_remaining = RESOURCE_PLAYS_PER_TURN
	
	
	current_player_passed = false
	
	while not current_player_passed and not GameController.action_cancelled:
		yield(self, "activated_or_passed_or_cancelled")
		
		if not ability_stack.empty():
			var ability = ability_stack.pop_front()
			ability.resolve()
			remove_ability_from_stack_gui(ability)
	
	init_mana_nti_phase()
	emit_signal("phase_completed")

func init_mana_nti_phase():
	log_message("Starting Mana NTI phase")
	GameController.phase = GameController.GamePhase.MANA_NTI

func do_mana_nti_phase():
	log_message("In Mana NTI phase")
	
	GameController.phase = GameController.GamePhase.MANA_NTI
	
	var active_player = GameController.get_nti_player()
	
	GameController.priority_player = active_player
	
	if first_turn:
		active_player.resource_plays_remaining = 0
	else:
		active_player.resource_plays_remaining = RESOURCE_PLAYS_PER_TURN
	
	current_player_passed = false
	
	if active_player.is_dummy():
#		uncomment for first turn commands
#		var command_dict = {}
#		command_dict.type = "ability"
#
#		command_dict.effects = []
#		var effects_dict = {}
#		effects_dict.targets = []
#		effects_dict.targets.push_back(-1000)
#		command_dict.effects.push_back(effects_dict)
#
#		command_dict.source = "114"
#		command_dict.index = 0
#
#		SteamController.receive_ability_or_pass(DUMMY_PLAYER_ID, command_dict)
#
#		var second_command_dict = {}
#		second_command_dict.type = "ability"
#
#		second_command_dict.effects = []
#		var second_effects_dict = {}
#		second_effects_dict.targets = []
#		second_effects_dict.targets.push_back(-1000)
#		second_command_dict.effects.push_back(second_effects_dict)
#
#		second_command_dict.source = "116"
#		second_command_dict.index = 0
#
#		SteamController.receive_ability_or_pass(DUMMY_PLAYER_ID, second_command_dict)
		
		init_attack_ti_phase()
		return
#		SteamController.submit_ability_or_passed()
#		print_debug("skipping")
	
	while not current_player_passed and not GameController.action_cancelled:
		yield(self, "activated_or_passed_or_cancelled")
		
		if not ability_stack.empty():
			var ability = ability_stack.pop_front()
			ability.resolve()
			remove_ability_from_stack_gui(ability)
	
	init_attack_ti_phase()
	emit_signal("phase_completed")
		

func init_attack_ti_phase():
	log_message("Starting TI Attack Phase")
	
	player_attack_formation.init_empty_formation()
	accept_attack_formation_button.show()
	
	GameController.num_nontoken_spells_this_skrimish = 0
	GameController.num_units_died_this_skrimish = 0
	
	GameController.phase = GameController.GamePhase.ATTACK_TI
	GameController.priority_player = GameController.get_ti_player()
	GameController.interaction_phase = false

func do_attack_ti_phase():
	log_message("In TI Attack Phase")
	
	player_attack_formation.show()
	
	if not GameController.interaction_phase:
		yield(SteamController,"formation_accepted")
	
	log_message("In TI Attack Interaction Phase")
	
	accept_attack_formation_button.hide()
	
	GameController.interaction_phase = true
	current_player_passed = false
	
#	TODO players should have a chance to do things in each interaction phase
	while not current_player_passed and not GameController.action_cancelled:
		log_message("waiting for interaction ti attack")
		yield(self, "activated_or_passed_or_cancelled")
		
		if not ability_stack.empty():
			var ability = ability_stack.pop_front()
			print_debug("resolving ability ", ability.serialize())
			ability.resolve()
			remove_ability_from_stack_gui(ability)
			current_player_passed = false
			GameController.update_static_state()
	
	GameController.interaction_phase = false
	
	init_block_ti_phase()
	emit_signal("phase_completed")

func init_block_ti_phase():
	log_message("Starting TI Block Phase")
	GameController.interaction_phase = false
	GameController.phase = GameController.GamePhase.BLOCK_TI
	GameController.priority_player = GameController.get_nti_player()

func do_block_ti_phase():
	log_message("In TI Block Phase")
	
	if not GameController.interaction_phase:
#		if GameController.priority_player.is_dummy():
#			log_message("Dummy Player making with the blocks")
#
#			var command_dict := {}
#
#			var formation_dict := {}
#
#			var clumn_array = []
#			clumn_array.push_back(str(120))
#			formation_dict[str(141)] = clumn_array
##			print_debug("the thing is ", SteamController.network_items_by_id[str(142)])
#			command_dict.formation = formation_dict
#
#			SteamController.receive_formation(str(DUMMY_PLAYER_ID), command_dict)
#		else:
#			yield(SteamController,"formation_accepted")
		GameController.interaction_phase = true
		current_player_passed = false
	
	log_message("Block TI interaction phase")
	
	GameController.priority_player = GameController.get_ti_player()

#	TODO players should have a chance to do things in each interaction phase
	while not current_player_passed and not GameController.action_cancelled:
		yield(self, "activated_or_passed_or_cancelled")
		
		if GameController.action_cancelled:
			return
		
		if current_player_passed and not ability_stack.empty():
			var ability = ability_stack.pop_front()
			ability.resolve()
			remove_ability_from_stack_gui(ability)
			current_player_passed = false
			GameController.update_static_state()
	
	init_damage_ti_phase()
	emit_signal("phase_completed")

func init_damage_ti_phase():
	log_message("Starting TI Damage Phase")
	GameController.phase = GameController.GamePhase.DAMAGE_TI

func do_damage_ti_phase():
	log_message("In TI Damage Phase")
	# Damage calculations go here
	
	log_message("(skipping phase)")
	init_post_combat_ti()
	emit_signal("phase_completed")

func init_post_combat_ti():
	log_message("Starting TI Post Combat Phase")
	GameController.perform_on_end_of_combat_triggers()
	GameController.phase = GameController.GamePhase.POST_COMBAT_TI

func do_post_combat_ti():
	log_message("In TI Post Combat Phase")
	
	# Triggers should go here
	GameController.priority_player = GameController.get_ti_player()
	GameController.interaction_phase = true
	current_player_passed = false

	while not current_player_passed and not GameController.action_cancelled:
		yield(self, "activated_or_passed_or_cancelled")
		
		if GameController.action_cancelled:
			print_debug("cancelled, quitting...")
			return

		if current_player_passed and not ability_stack.empty():
			print_debug("resolving")
			var ability = ability_stack.pop_front()
			ability.resolve()
			remove_ability_from_stack_gui(ability)
			current_player_passed = false
			GameController.update_static_state()
	
#	interaction_phase()

#	log_message("(skipping phase)")
	init_attack_nti_phase()
	emit_signal("phase_completed")

func init_attack_nti_phase():
	log_message("Starting NIT Attack Phase")
	GameController.phase = GameController.GamePhase.ATTACK_NTI

func do_attack_nti_phase():
	log_message("Do NIT Attack Phase")
	
	GameController.phase = GameController.GamePhase.ATTACK_NTI
	
	log_message("(skipping phase)")
	init_block_nti_phase()
	emit_signal("phase_completed")

func init_block_nti_phase():
	log_message("Starting NTI Block Phase")
	GameController.phase = GameController.GamePhase.BLOCK_NTI

func do_block_nti_phase():
	log_message("starting nti blk phase")
	
	log_message("(skipping phase)")
	GameController.phase = GameController.GamePhase.BLOCK_NTI
	
	init_damage_nti_phase()
	emit_signal("phase_completed")

func init_damage_nti_phase():
	log_message("Starting NTI Damage Phase")
	GameController.phase = GameController.GamePhase.DAMAGE_NTI
	
func do_damage_nti_phase():
	log_message("In NTI Damage Phase")
	
	init_post_combat_nti_phase()
	emit_signal("phase_completed")

func init_post_combat_nti_phase():
	log_message("Starting NTI Post Combat Phase")
	GameController.phase = GameController.GamePhase.POST_COMBAT_NTI

func do_post_combat_nti_phase():
	log_message("In NTI Post Combat Phase")
	
	log_message("(skipping phase)")
	GameController.phase = GameController.GamePhase.POST_COMBAT_NTI
	init_regroup()
	emit_signal("phase_completed")
	
func init_regroup():
	log_message("Starting Regroup Phase")
	GameController.phase = GameController.GamePhase.REGROUP
	
func do_regroup():
	log_message("In Regroup Phase")
	player_attack_formation.return_all_player_units()
	player_attack_formation.return_all_opponent_units()
	player_attack_formation.hide()
	init_main_ti()
	emit_signal("phase_completed")
	
func init_main_ti():
	log_message("Starting TI Main Phase")
	GameController.phase = GameController.GamePhase.MAIN_TI
	GameController.priority_player = GameController.get_ti_player()
	
func do_main_ti():
	log_message("In TI Main Phase")
	
	current_player_passed = false
	while not current_player_passed and not GameController.action_cancelled:
		yield(self, "activated_or_passed_or_cancelled")
		
		if current_player_passed and not ability_stack.empty():
			var ability = ability_stack.pop_front()
			ability.resolve()
			remove_ability_from_stack_gui(ability)
			current_player_passed = false
			GameController.update_static_state()
	
	init_main_nti()
	emit_signal("phase_completed")
	
func init_main_nti():
	log_message("Starting NTI Main Phase")
	GameController.phase = GameController.GamePhase.MAIN_NTI
	GameController.priority_player = GameController.get_nti_player()
	
func do_main_nti():
	log_message("In NTI Main Phase")
	
	first_turn = false
	if GameController.priority_player.is_dummy():
		var command_dict = {}
		command_dict.type = "ability"
		
		command_dict.effects = []
#		var effects_dict = {}
#		effects_dict.targets = []
#		effects_dict.targets.push_back(-1000)
#		command_dict.effects.push_back(effects_dict)
		
		command_dict.source = "108"
		command_dict.index = 0
		
		print_debug("doing command?")
#		SteamController.receive_ability_or_pass(DUMMY_PLAYER_ID, command_dict)
		
		# Clear the stack
		if not ability_stack.empty():
			var ability = ability_stack.pop_front()
			ability.resolve()
			remove_ability_from_stack_gui(ability)
			current_player_passed = false
			GameController.update_static_state()
		
		var second_command_dict = {}
		second_command_dict.type = "pass"

#		second_command_dict.effects = []
#		var second_effects_dict = {}
#		second_effects_dict.targets = []
#		second_effects_dict.targets.push_back(-1000)
#		second_command_dict.effects.push_back(second_effects_dict)
#
#		second_command_dict.source = "116"
#		second_command_dict.index = 0
#
		SteamController.receive_ability_or_pass(DUMMY_PLAYER_ID, second_command_dict)
		
		init_untap_phase()
		emit_signal("phase_completed")
		return
	
	
	current_player_passed = false
	while not current_player_passed and not GameController.action_cancelled:
		yield(self, "activated_or_passed_or_cancelled")
		
		if current_player_passed and not ability_stack.empty():
			var ability = ability_stack.pop_front()
			ability.resolve()
			remove_ability_from_stack_gui(ability)
			current_player_passed = false
			GameController.update_static_state()
	
	init_untap_phase()
	emit_signal("phase_completed")

func interaction_phase():
	var all_passed = false
	while (not ability_stack.empty()) or (not all_passed):
		if all_passed:
			var ability = ability_stack.pop_back()
			ability.resolve()
		
		all_passed = true 
		for player in players:
			if player.take_action_or_pass():
				all_passed = false
				break

func log_message(message):
	var to_add = Label.new()
	to_add.text = message
	 
	game_log.add_child(to_add)
	game_log.move_child(to_add, 0)

# For transmitting and for saves
func serialize():
	var state_dict := {}
	
	# TODO encode resource container ids
	
	var state_players = []
	
	for player in players:
		state_players.push_back(player.serialize())
	
	state_dict.players = state_players
	
	state_dict.first_turn = first_turn
	state_dict.phase = GameController.phase
	state_dict.interaction_phase = GameController.interaction_phase
	
	state_dict.num_nontoken_spells_this_skrimish = GameController.num_nontoken_spells_this_skrimish
	state_dict.num_units_died_this_skrimish = GameController.num_units_died_this_skrimish
	
	state_dict.initiative_player_id = GameController.initiative_player.player_id
	if GameController.priority_player:
		state_dict.priority_player_id = GameController.priority_player.player_id
	
	if GameController.is_in_battle():
		state_dict.host_attack_formation = player_attack_formation.serialize()
	
	var serialized_stack = []
	for stacked_ability in ability_stack:
		serialized_stack.push_back(stacked_ability.serialize())
	state_dict.stack = serialized_stack
	
	return JSON.print(state_dict)

func deserialize_and_load(serialized_state):
	var loaded_dict = JSON.parse(serialized_state).result
	
	GameController.phase = int(loaded_dict.phase)
	GameController.interaction_phase = loaded_dict.interaction_phase
	
	GameController.num_nontoken_spells_this_skrimish = loaded_dict.num_nontoken_spells_this_skrimish
	GameController.num_units_died_this_skrimish = loaded_dict.num_units_died_this_skrimish
	
	first_turn = loaded_dict.first_turn
	
	SteamController.network_players_by_id.clear()
	
	reset_all_visuals()
	
	for player_child in player_list.get_children():
		player_list.remove_child(player_child)
	
	for player in players:
		player.queue_free()

	players.clear()
	
	var player_data_map = {}
	
	# Players have to first be initiated, then all their battlefields created
	# And then finally all their properties and permanents can be assigned
	for player in loaded_dict.players:
		var player_to_add = Player.new(self, int(player.player_id))
		players.push_back(player_to_add)
		player_list.add_child(player_to_add)
		player_data_map[player_to_add] = player
	
	for player in players:
		player.init_after_player_creation()
		player.load_data(player_data_map[player])
		
	for player in players:
		if player.player_id == str(loaded_dict.initiative_player_id):
			GameController.initiative_player = player
		if loaded_dict.has("priority_player_id"):
			if player.player_id == str(loaded_dict.priority_player_id):
				GameController.priority_player = player
	
	# If the game is in draft phase all players are drafting
	if GameController.phase == GameController.GamePhase.DRAFT:
		SteamController.network_players_by_id[str(SteamController.self_peer_id)].draft()
	
	if GameController.is_in_battle():
		var host_attack_columns = loaded_dict.host_attack_formation
		player_attack_formation.load_data(host_attack_columns)
		player_attack_formation.show()
		
		if not GameController.interaction_phase:
			accept_attack_formation_button.show()
		else:
			accept_attack_formation_button.hide()
	
	clear_stack_container()
	ability_stack.clear()
	
	if loaded_dict.has("stack"):
		for serialized_ability in loaded_dict.stack:
			call_deferred("add_to_ability_stack", EffectLibrary.load_ability(serialized_ability))
	
	run_game()


func run_game():
	while not GameController.game_over and not GameController.action_cancelled:
		var current_phase = GameController.phase
		resume_phase()
		if GameController.should_yield_for_phase(current_phase):
			yield(self, "phase_completed")

func resume_phase() -> void:
	if GameController.phase == GameController.GamePhase.UNTAP:
		do_untap_phase()
	elif GameController.phase == GameController.GamePhase.DRAW:
		do_draw_phase()
	elif GameController.phase == GameController.GamePhase.DRAFT:
		do_draft_phase()
	elif GameController.phase == GameController.GamePhase.MANA_TI:
		do_mana_ti_phase()
	elif GameController.phase == GameController.GamePhase.MANA_NTI:
		do_mana_nti_phase() 
	elif GameController.phase == GameController.GamePhase.ATTACK_TI:
		do_attack_ti_phase()
	elif GameController.phase == GameController.GamePhase.BLOCK_TI:
		do_block_ti_phase()
	elif GameController.phase == GameController.GamePhase.DAMAGE_TI:
		do_damage_ti_phase()
	elif GameController.phase == GameController.GamePhase.POST_COMBAT_TI:
		do_post_combat_ti()
	elif GameController.phase == GameController.GamePhase.ATTACK_NTI:
		do_attack_nti_phase()
	elif GameController.phase == GameController.GamePhase.BLOCK_NTI:
		do_block_nti_phase()
	elif GameController.phase == GameController.GamePhase.DAMAGE_NTI:
		do_damage_nti_phase()
	elif GameController.phase == GameController.GamePhase.POST_COMBAT_NTI:
		do_post_combat_nti_phase()
	elif GameController.phase == GameController.GamePhase.REGROUP:
		do_regroup()
	elif GameController.phase == GameController.GamePhase.MAIN_TI:
		do_main_ti()
	elif GameController.phase == GameController.GamePhase.MAIN_NTI:
		do_main_nti()

func add_to_ability_stack(ability) -> void:
	ability_stack.push_front(ability)
	
	stack_container.add_child(StackAbilityContainer.new(ability))

func remove_ability_from_stack_gui(ability) -> void:
	for stack_ability in stack_container.get_children():
		if stack_ability.ability == ability:
			stack_container.remove_child(stack_ability)

func on_activated_ability_or_passed(has_passed):
	current_player_passed = has_passed
	emit_signal("activated_or_passed_or_cancelled")

func on_cancelled():
	emit_signal("activated_or_passed_or_cancelled")

func _on_PassButton_pressed():
	var command_dict = {}
	command_dict.type = "pass"
	SteamController.submit_ability_or_passed(command_dict)
#	GameController.emit_signal("activated_ability_or_passed", true)

func reset_all_visuals() -> void:
	# Logical elements will be created from scratch so we only need to
	# reset visuals
	draft_container.hide()
	draft_container.remove_all_cards()
	
	player_attack_formation.hide()
#	player_block_formation.hide()
#	opponent_attack_formation.hide()
#	opponent_block_formation.hide()
	
	set_up_battlefields()
	clear_hand_container()
	clear_stack_container()
	clear_discard_containers()
	set_up_basic_resource_container()

func clear_hand_container():
	for child in hand_container.get_children():
		hand_container.remove_child(child)

func clear_discard_containers():
	for child in player_discard_container.get_children():
		player_discard_container.remove_child(child)
		
	for child in opponent_discard_container.get_children():
		opponent_discard_container.remove_child(child)

func set_up_battlefields():
	for child in player_field.get_children():
		player_field.remove_child(child)
	
	for child in opponent_field.get_children():
		opponent_field.remove_child(child)
	
	for child in player_away_field.get_children():
		player_away_field.remove_child(child)

func _on_SaveButton_pressed():
	GameController.save_game()

func _on_LoadButton_pressed():
	GameController.load_game()

func player_self_gui_event(event):
	if event.is_pressed():
		if not SteamController.has_priority:
			return
			
		if GameController.is_targeting:
			var player
			for q_player in players:
				if q_player.player_id == SteamController.self_peer_id:
					player = q_player
			
			emit_signal("targeted_player", player)

func player_opponent_gui_event(event):
	if event.is_pressed():
		if not SteamController.has_priority:
			return
			
		if GameController.is_targeting:
			var player
			for q_player in players:
				if q_player.player_id != SteamController.self_peer_id:
					player = q_player
			
			emit_signal("targeted_player", player)

func _on_AcceptFormation_pressed():
	if GameController.is_targeting:
		return
	
	if player_attack_formation.is_formation_valid():
		var command_dict = player_attack_formation.get_formation_command_dict()
		print_debug("submit formation")
		SteamController.submit_formation(command_dict)
