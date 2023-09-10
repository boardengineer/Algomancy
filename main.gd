extends HBoxContainer

var players := []
var deck := []

var ability_stack := []

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

const NUM_PLAYERS := 2
const ResourceContainer = preload("res://resource_container.tscn")

signal activated_or_passed

var first_turn = true

const STARTING_DRAFT_PACK_SIZE = 16

onready var game_log = $GameLog
onready var draft_container = $DraftContainerPopup/PanelContainer/DraftContainer
onready var player_list = $Players

onready var opponent_field = $GameFields/OpponentField
onready var player_field = $GameFields/PlayerField
onready var hand_container = $GameFields/HandContainer
onready var stack_container = $Stack
onready var basic_resource_container = $BasicResourcePopup/ResourceContainer/HBoxContainer
onready var basic_resource_dialog = $BasicResourcePopup/ResourceContainer
onready var pass_button = $Controls/PassButton

var current_player_passed

# Called when the node enters the scene tree for the first time.
func _ready():
	TargetHelper.set_up_references(self)
	
	GameController.connect("activated_ability_or_passed", self, "on_activated_ability_or_passed")
	
	randomize()
	init()
	
# Do init stuff in this function for easier modding
func init():
	set_up_basic_resource_container()
	
	set_up_stack()
	set_up_battlefields()
	
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
		player_list.add_child(player)
		player.call_deferred("add_starting_mana_converters")
	
	# init deck, this will probably be a resource file
	for n in 50:
		var card = Card.new()
		card.card_name = str(n)
		deck.push_back(card)
		
	deck.shuffle()
		
	for player in players:
		for _n in STARTING_DRAFT_PACK_SIZE:
			var top_card = deck.pop_front()
#			log_message(str("adding ", top_card.card_name))
			player.draft_pack.push_back(top_card)
	
	first_turn = true
	
	# TODO remove when not debugging
	players[0].player_id = SteamController.self_peer_id
	
	print_debug(players[0].player_id)
	
	do_untap_phase()

func set_up_stack() -> void:
	for child in stack_container.get_children():
		stack_container.remove_child(child)

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
	
	phase = GamePhase.UNTAP
	for player in players:
		for battlefield_players in player.battlefields:
			for permanent in player.battlefields[battlefield_players]:
				permanent.tapped = false
				
	do_draw_phase()
	
func do_draw_phase():
	log_message("starting draw phase")
	
	phase = GamePhase.DRAW
	
	if not first_turn:
		for player in players:
			player.draw(2)
	else:
		log_message("skipping draw phase in the first turn")
		
	do_draft_phase()
	
func do_draft_phase():
	log_message("starting draft phase")
	
	phase = GamePhase.DRAFT
	
	# done in parallel across machines, just show one at a time for now  
	for player in players:
		player.draft()
		if player.player_id == SteamController.self_peer_id:
			yield(player, "draft_complete")
		
	do_mana_ti_phase()

func do_mana_ti_phase():
	log_message("starting mana phase")
	
	phase = GamePhase.MANA_TI
	current_player_passed = false
	
	while not current_player_passed:
		print_debug("waiting for mana effect...")
		yield(self, "activated_or_passed")
		
		if not ability_stack.empty():
			var ability = ability_stack.pop_front()
			ability.resolve()
			remove_ability_from_stack_gui(ability)
	
	players[0].do_mana_phase()

func do_mana_nti_phase():
	phase = GamePhase.MANA_NTI
	
	players[1].do_mana_phase()
	
	do_attack_ti_phase()

func do_attack_ti_phase():
	phase = GamePhase.ATTACK_TI
	
	players[0].declare_ti_attackers()
	interaction_phase()
	
	do_block_ti_phase()

func do_block_ti_phase():
	phase = GamePhase.BLOCK_TI
	
	players[1].declare_ti_blockers()
	interaction_phase()
	
	do_damage_ti_phase()

func do_damage_ti_phase():
	phase = GamePhase.DAMAGE_TI
	
	# Damage calculations go here
	
	do_post_combat_ti()

func do_post_combat_ti():
	phase = GamePhase.POST_COMBAT_TI
	
	# Triggers should go here
	interaction_phase()
	
func do_attack_nti_phase():
	pass

func do_block_nti_phase():
	pass
	
func do_damage_nti_phase():
	pass

func do_post_combat_nti_phase():
	pass
	
func do_regroup():
	pass
	
func do_main_ti():
	pass
	
func do_main_nti():
	pass

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
		state_players.push_back(player.serliaze())
		
	state_dict.players = state_players
	
	state_dict.first_turn = first_turn
	state_dict.phase = phase
	
	return str(state_dict)

func add_to_ability_stack(ability) -> void:
	ability_stack.push_front(ability)
	
	stack_container.add_child(StackAbilityContainer.new(ability))
#	stack_container.pu

func remove_ability_from_stack_gui(ability) -> void:
	for stack_ability in stack_container.get_children():
		if stack_ability.ability == ability:
			stack_container.remove_child(stack_ability)
			break

func on_activated_ability_or_passed(has_passed):
	current_player_passed = has_passed
	emit_signal("activated_or_passed")

func _on_PassButton_pressed():
	GameController.emit_signal("activated_ability_or_passed", true)

func set_up_battlefields():
	for child in player_field.get_children():
		player_field.remove_child(child)
	
	for child in opponent_field.get_children():
		opponent_field.remove_child(child)
