extends HBoxContainer

var players := []
var deck := []

var ability_stack := []

const NUM_PLAYERS := 2
const ResourceContainer = preload("res://resource_container.tscn")

signal activated_or_passed_or_cancelled
signal targeted_player
signal formation_accepted

var first_turn = true

const STARTING_DRAFT_PACK_SIZE = 16
const RESOURCE_PLAYS_PER_TURN = 2

onready var game_log = $GameLog
onready var draft_container = $DraftContainerPopup/PanelContainer/DraftContainer
onready var player_list = $Players

onready var opponent_field = $GameFields/OpponentField
onready var player_field = $GameFields/PlayerField
onready var hand_container = $GameFields/HandContainer
onready var discard_container = $DiscardHolder/Discard
onready var stack_container = $Stack
onready var basic_resource_container = $BasicResourcePopup/ResourceContainer/HBoxContainer
onready var basic_resource_dialog = $BasicResourcePopup/ResourceContainer
onready var pass_button = $Controls/PassButton

onready var player_formation = $Formations/PanelContainer/PlayerFormation
onready var accept_formation_button = $Formations/PanelContainer/AcceptFormation

onready var player_target_self = $PlayerTargets/SelfPlayerButton
onready var player_target_opponent = $PlayerTargets/OppPlayerButton

onready var target_image = $TargetContainer/TargetIcon

var current_player_passed

# Called when the node enters the scene tree for the first time.
func _ready():
	TargetHelper.set_up_references(self)
	GameController.set_up_references(self)
	
	var _unused = GameController.connect("activated_ability_or_passed", self, "on_activated_ability_or_passed")
	_unused = GameController.connect("cancel", self, "_on_cancelled")
	
	_unused = player_target_self.connect("gui_input", self, "player_self_gui_event")
	_unused = player_target_opponent.connect("gui_input", self, "player_opponent_gui_event")
	_unused = connect("targeted_player", TargetHelper, "on_target_selected")
	
	randomize()
	init()
	
# Do init stuff in this function for easier modding
func init():
	set_up_basic_resource_container()
	
	reset_all_visuals()
	set_up_battlefields()
	target_image.hide()
	
	players = []
	
	# init players
	for n in NUM_PLAYERS:
		var new_player
		if n == 0:
			new_player = Player.new(self, SteamController.self_peer_id)
		else:
			new_player = Player.new(self)
		
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
	
	do_untap_phase()

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
	fire_container.resource_card = Fire.new()
	basic_resource_container.add_child(fire_container)
	
	var wood_container = ResourceContainer.instance()
	wood_container.text = "wood"
	wood_container.set_name("Wood")
	wood_container.resource_card = Wood.new()
	basic_resource_container.add_child(wood_container)
	
func do_untap_phase():
	log_message("starting untap phase")
	
	GameController.phase = GameController.GamePhase.UNTAP
	for player in players:
		for battlefield_players in player.battlefields:
			for permanent in player.battlefields[battlefield_players]:
				permanent.untap()
				
	do_draw_phase()
	
func do_draw_phase():
	log_message("starting draw phase")
	
	GameController.phase = GameController.GamePhase.DRAW
	
	if not first_turn:
		for player in players:
			player.draw(2)
	else:
		log_message("skipping draw phase in the first turn")
		
	do_draft_phase()
	
func do_draft_phase():
	log_message("starting draft phase")
	
	GameController.phase = GameController.GamePhase.DRAFT
	
	# Done in parallel across machines, just show one at a time for now  
	for player in players:
		player.draft()
		if player.player_id == SteamController.self_peer_id:
			yield(player, "draft_complete_or_cancelled")
		
	if not GameController.action_cancelled:
		do_mana_ti_phase()

func do_mana_ti_phase():
	log_message("starting mana phase")
	
	if first_turn:
		players[0].resource_plays_remaining = 0
	else:
		players[0].resource_plays_remaining = RESOURCE_PLAYS_PER_TURN
	
	GameController.phase = GameController.GamePhase.MANA_TI
	current_player_passed = false
	
	while not current_player_passed and not GameController.action_cancelled:
		yield(self, "activated_or_passed_or_cancelled")
		
		if not ability_stack.empty():
			var ability = ability_stack.pop_front()
			ability.resolve()
			remove_ability_from_stack_gui(ability)
	
	if not GameController.action_cancelled:
		do_mana_nti_phase()

func do_mana_nti_phase():
	log_message("starting opp mana phase")
	GameController.phase = GameController.GamePhase.MANA_NTI
	
	log_message("(skipping phase)")
#	players[1].do_mana_phase()
	
	do_attack_ti_phase()

func do_attack_ti_phase():
	log_message("starting ti atk phase")
	
	GameController.phase = GameController.GamePhase.ATTACK_TI
	player_formation.init_empty_formation()
	player_formation.show()
	accept_formation_button.show()
	
	yield(self,"formation_accepted")
	
#	player_formation.hide()
	accept_formation_button.hide()
	
	GameController.interaction_phase = true
	current_player_passed = false
	while not current_player_passed and not GameController.action_cancelled:
		yield(self, "activated_or_passed_or_cancelled")
		
		if not ability_stack.empty():
			var ability = ability_stack.pop_front()
			ability.resolve()
			remove_ability_from_stack_gui(ability)
	
	GameController.interaction_phase = false
	
	if not GameController.action_cancelled:
		do_block_ti_phase()

func do_block_ti_phase():
	log_message("starting ti blk phase")
	
	GameController.phase = GameController.GamePhase.BLOCK_TI
	
#	players[1].declare_ti_blockers()3
	
	log_message("(skipping phase)")
	do_damage_ti_phase()

func do_damage_ti_phase():
	log_message("starting ti dmg phase")
	
	GameController.phase = GameController.GamePhase.DAMAGE_TI
	
	# Damage calculations go here
	
	log_message("(skipping phase)")
	do_post_combat_ti()

func do_post_combat_ti():
	log_message("starting ti post phase")
	
	GameController.phase = GameController.GamePhase.POST_COMBAT_TI
	
	# Triggers should go here
#	interaction_phase()

	log_message("(skipping phase)")
	do_attack_nti_phase()
	
func do_attack_nti_phase():
	log_message("starting nti atk phase")
	
	GameController.phase = GameController.GamePhase.ATTACK_NTI
	
	log_message("(skipping phase)")
	do_block_nti_phase()

func do_block_nti_phase():
	log_message("starting nti blk phase")
	
	log_message("(skipping phase)")
	GameController.phase = GameController.GamePhase.BLOCK_NTI
	
	do_damage_nti_phase()
	
func do_damage_nti_phase():
	log_message("starting nti dmg phase")
	
	log_message("(skipping phase)")
	GameController.phase = GameController.GamePhase.DAMAGE_NTI
	
	do_post_combat_nti_phase()

func do_post_combat_nti_phase():
	log_message("starting nti post phase")
	
	log_message("(skipping phase)")
	GameController.phase = GameController.GamePhase.POST_COMBAT_NTI
	do_regroup()
	
func do_regroup():
	log_message("starting regroup phase")
	GameController.phase = GameController.GamePhase.REGROUP
	
	player_formation.return_all_units()
	player_formation.hide()

	do_main_ti()
	
func do_main_ti():
	log_message("starting ti main phase")
	
	GameController.phase = GameController.GamePhase.MAIN_TI
	
	current_player_passed = false
	while not current_player_passed and not GameController.action_cancelled:
		yield(self, "activated_or_passed_or_cancelled")
		
		if current_player_passed and not ability_stack.empty():
			var ability = ability_stack.pop_front()
			ability.resolve()
			remove_ability_from_stack_gui(ability)
			current_player_passed = false
			GameController.update_static_state()
	
	do_main_nti()
	
func do_main_nti():
	log_message("starting nti main phase")
	
	GameController.phase = GameController.GamePhase.MAIN_NTI
	
	log_message("(skipping phase)")
	first_turn = false
	do_untap_phase()

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

# For transmitting and for saves
func serialize():
	var state_dict := {}
	
	var state_players = []
	
	for player in players:
		state_players.push_back(player.serialize())
	
	state_dict.players = state_players
	
	state_dict.first_turn = first_turn
	state_dict.phase = GameController.phase
	
	return JSON.print(state_dict)

func deserialize_and_load(serialized_state):
	var loaded_dict = JSON.parse(serialized_state).result
	
	GameController.phase = loaded_dict.phase
	first_turn = loaded_dict.first_turn
	
	reset_all_visuals()
	
	for player_child in player_list.get_children():
		player_list.remove_child(player_child)
	
	for player in players:
		player.queue_free()

	players.clear()
	
	var player_data_map = {}
	SteamController.network_players_by_id.clear()
	
	# Players have to first be initiated, then all their battlefields created
	# And then finally all their properties and permanents can be assigned
	for player in loaded_dict.players:
		var player_to_add = Player.new(self, int(player.player_id))
		players.push_back(player_to_add)
		player_data_map[player_to_add] = player
	
	for player in players:
		player.init_after_player_creation()
	
	for player in players:
		player.load_data(player_data_map[player])
		player_list.add_child(player)
	
	# If the game is in draft phase all players are drafting
	if GameController.phase == GameController.GamePhase.DRAFT:
		SteamController.network_players_by_id[str(SteamController.self_peer_id)].draft()
		
	resume_phase()

func resume_phase() -> void:
	if GameController.phase == GameController.GamePhase.DRAFT:
		do_draft_phase()
		return
		
	if GameController.phase == GameController.GamePhase.MANA_TI:
		do_mana_ti_phase()
		return
	
	if GameController.phase == GameController.GamePhase.ATTACK_TI:
		do_attack_ti_phase()
		return
	
	if GameController.phase == GameController.GamePhase.MAIN_TI:
		do_main_ti()
		return

func add_to_ability_stack(ability) -> void:
	ability_stack.push_front(ability)
	
	stack_container.add_child(StackAbilityContainer.new(ability))

func remove_ability_from_stack_gui(ability) -> void:
	for stack_ability in stack_container.get_children():
		if stack_ability.ability == ability:
			stack_container.remove_child(stack_ability)
			break

func on_activated_ability_or_passed(has_passed):
	current_player_passed = has_passed
	emit_signal("activated_or_passed_or_cancelled")

func _on_PassButton_pressed():
	GameController.emit_signal("activated_ability_or_passed", true)

func reset_all_visuals() -> void:
	# Logical elements will be created from scratch so we only need to
	# reset visuals
	draft_container.hide()
	draft_container.remove_all_cards()
	
	set_up_battlefields()
	clear_hand_container()
	clear_stack_container()
	clear_discard_container()

func clear_hand_container():
	for child in hand_container.get_children():
		hand_container.remove_child(child)

func clear_discard_container():
	for child in discard_container.get_children():
		discard_container.remove_child(child)

func set_up_battlefields():
	for child in player_field.get_children():
		player_field.remove_child(child)
	
	for child in opponent_field.get_children():
		opponent_field.remove_child(child)

func _on_SaveButton_pressed():
	GameController.save_game()

func _on_LoadButton_pressed():
	GameController.load_game()

func _on_cancelled():
	emit_signal("activated_or_passed_or_cancelled")

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
	if not GameController.is_targeting:
		if player_formation.is_formation_valid():
			emit_signal("formation_accepted")
