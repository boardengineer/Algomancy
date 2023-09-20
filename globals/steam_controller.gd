extends Node

signal draft_complete_or_cancelled
signal activated_ability_or_passed_or_cancelled

enum LobbyAvailability {PRIVATE, FRIENDS, PUBLIC, INVISIBLE}
var lobby_id = 0
var self_peer_id = -1
var is_host = true

var latest_network_id = 0

var network_items_by_id = {}
var network_players_by_id = {}

# If true then the game state wants the current player to take some action.
var has_priority = true

var waiting_for_draft = false

var draft_selection_by_player_id = {}

func _ready():
	var _unused = GameController.connect("cancel", self, "_on_cancelled")
	var _init_status = Steam.steamInit()
	self_peer_id = Steam.getSteamID()

func _process(_delta):
	Steam.run_callbacks()

func get_next_network_id() -> int:
	var result = latest_network_id
	latest_network_id += 1
	return result

func start_draft() -> void:
	waiting_for_draft = true
	draft_selection_by_player_id = {}

func complete_draft() -> void:
	waiting_for_draft = false
	emit_signal("draft_complete_or_cancelled")

func receive_draft_selection(player_id, selected_network_ids) -> void:
	if not waiting_for_draft:
		return
	
	var deindexed_card_list = []
	for id_selected in selected_network_ids:
		deindexed_card_list.push_back(network_items_by_id[id_selected])
	draft_selection_by_player_id[player_id] = deindexed_card_list
	
	if draft_selection_by_player_id.size() == network_players_by_id.size():
		complete_draft()

func submit_ability_or_passed(command) -> void:
	if is_host:
		receive_ability_or_pass(command)
	pass

func receive_ability_or_pass(command) -> void:
	network_items_by_id[command.source].activate_ability(command.index, command.effects)

func submit_draft_selection(draft_selection) -> void:
	var selected_card_ids = []
	for card in draft_selection:
		selected_card_ids.push_back(card.network_id)
	if is_host:
		receive_draft_selection(self_peer_id, selected_card_ids)
	else:
		# Send draft selection to host
		pass
	pass

func mock_send_message(message) -> void:
	print_debug("would be sending a message: ", message)

func _on_cancelled():
	emit_signal("draft_complete_or_cancelled")
