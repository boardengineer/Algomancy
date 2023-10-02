extends Node

signal draft_complete_or_cancelled
signal activated_ability_or_passed_or_cancelled
signal formation_accepted

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

var tracked_players = {}

# Tracks players that have send status updates saying they're in game, ensures
# players are loaded before they get the initial game state so they can load
# in properly.
var players_in_game = {}

func _ready():
	var _init_status = Steam.steamInit()
	self_peer_id = str(Steam.getSteamID())
	
	var _unused = GameController.connect("cancel", self, "_on_cancelled")
	_unused = Steam.connect("lobby_joined", self, "_on_Lobby_Joined")
	_unused = Steam.connect("p2p_session_request", self, "_on_P2P_Session_Request")
	_unused = Steam.connect("lobby_chat_update", self, "_on_Lobby_Chat_Update")

func _process(_delta):
	Steam.run_callbacks()

func _on_P2P_Session_Request(remote_id: int) -> void:
	var _error = Steam.acceptP2PSessionWithUser(remote_id)

	# Make the initial handshake
	send_handshakes()

func start_game(f_is_host = true) -> void:
	var old_main = get_tree().get_current_scene()
	var main_scene = load("res://main.tscn").instance()
	
	is_host = f_is_host
	
	main_scene.call_deferred("init", is_host, tracked_players)
	
	get_tree().get_root().add_child(main_scene)
	get_tree().set_current_scene(main_scene)
	get_tree().get_root().remove_child(old_main)
	
	if is_host:
		start_tracking_players_in_game()
		send_start_game()
		start_first_phase_when_all_ready()

func start_first_phase_when_all_ready() -> void:
	for player_id in tracked_players:
		if player_id == self_peer_id:
			continue
		
		if not players_in_game.has(player_id) or not players_in_game[player_id]:
			print_debug("not starting because player ", player_id, " has not reported ready")
			return
	
	print_debug("all players reported ready, starting game")
	GameController.initiative_player = GameController.main.players[0]
	GameController.main.do_untap_phase()

func start_tracking_players_in_game() -> void:
	players_in_game = {}
	
	for player_id in tracked_players:
		if player_id == self_peer_id:
			continue
		
		players_in_game[player_id] = false

func receive_game_started_status(sender_id) -> void:
	players_in_game[sender_id] = true
	
	start_first_phase_when_all_ready()

func get_next_network_id() -> int:
	var result = latest_network_id
	latest_network_id += 1
	return result

func start_draft() -> void:
	waiting_for_draft = true
	draft_selection_by_player_id = {}
	
	send_game_state()

func complete_draft() -> void:
	waiting_for_draft = false
	emit_signal("draft_complete_or_cancelled")

func receive_draft_selection(player_id, selected_network_ids) -> void:
	if not waiting_for_draft:
		return
	
	var deindexed_card_list = []
	for id_selected in selected_network_ids:
		deindexed_card_list.push_back(network_items_by_id[int(id_selected)])
	draft_selection_by_player_id[player_id] = deindexed_card_list
	
	if draft_selection_by_player_id.size() == network_players_by_id.size():
		complete_draft()

func submit_ability_or_passed(command) -> void:
	if is_host:
		receive_ability_or_pass(self_peer_id, command)
	else:
		send_ability_or_passed(command)
	
func send_ability_or_passed(command) -> void:
	var state = GameController.main.serialize()
	var send_data = {}
	send_data["type"] = "command"
	send_data["command"] = command
	send_data_to_all(send_data)

func receive_ability_or_pass(player_id, command) -> void:
	if GameController.priority_player.player_id != player_id:
		return
	
	var is_pass = command.type != "ability"
	
	GameController.emit_signal("activated_ability_or_passed", is_pass)
	
	print_debug("player doing command ", player_id, " " , command)
	
	if not is_pass:
		network_items_by_id[str(int(command.source))].activate_ability(command.index, command.effects)

func submit_draft_selection(draft_selection) -> void:
	var selected_card_ids = []
	for card in draft_selection:
		selected_card_ids.push_back(card.network_id)
	
	if is_host:
		receive_draft_selection(self_peer_id, selected_card_ids)
	else:
		send_draft_selection(selected_card_ids)

func send_draft_selection(selected_card_ids) -> void:
	var state = GameController.main.serialize()
	var send_data = {}
	send_data["type"] = "draft_selection"
	send_data["draft_selection"] = selected_card_ids
	send_data_to_all(send_data)

func submit_formation(formation_dict:Dictionary) -> void:
	if is_host:
		receive_formation(self_peer_id, formation_dict)
	else:
		send_formation(formation_dict)
 
func receive_formation(player_id, formation_dict:Dictionary) -> void:
	emit_signal("formation_accepted")

func send_formation(formation_dict) -> void:
	var send_data = {}
	send_data["type"] = "formation"
	send_data["formation"] = formation_dict
	send_data_to_all(send_data)

func _on_cancelled():
	emit_signal("draft_complete_or_cancelled")

func send_game_state() -> void:
	var state = GameController.main.serialize()
	var send_data = {}
	send_data["type"] = "game_state"
	send_data["state"] = state
	send_data_to_all(send_data)

func receive_game_state(game_state) -> void:
	if is_host:
		print_debug("you're the host, why are you getting states?")
		return
	
	GameController.main.deserialize_and_load(game_state)

func send_handshakes() -> void:
	var send_data = {}
	send_data["type"] = "handshake"
	send_data_to_all(send_data)

func send_start_game() -> void:
	var send_data = {}
	send_data["type"] = "start_game"
	send_data_to_all(send_data)

func send_game_started_status() -> void:
	var send_data = {}
	send_data["type"] = "status_started_game"
	send_data_to_all(send_data)

func send_data_to_all(packet_data: Dictionary) -> void:
	for player_id in tracked_players:
		if player_id == self_peer_id:
			continue
		send_data(packet_data, player_id)

func send_data(packet_data: Dictionary, target: int, channel:int = 0) -> void:
	# TODO actually compress
	var compressed_data = var2bytes(packet_data).compress(File.COMPRESSION_GZIP)
	
	# Just use channel 0 for everything for now
	print_debug("sending message")
	var _error = Steam.sendP2PPacket(target, compressed_data, Steam.P2P_SEND_RELIABLE, channel)

# clears tracked_players and resets tracked players based  
func update_tracked_players() -> void:
	# Clear your previous lobby list
	tracked_players.clear()

	# Get the number of members from this lobby from Steam
	var num_members = Steam.getNumLobbyMembers(lobby_id)
#	var all_players_ready = true

	# Get the data of these players from Steam
	for member_index in range(num_members):
		var member_steam_id = Steam.getLobbyMemberByIndex(lobby_id, member_index)
		var member_username: String = Steam.getFriendPersonaName(member_steam_id)
		
#		if not established_p2p_connections.has(member_steam_id) or not established_p2p_connections[member_steam_id]:
#			if member_steam_id != parent.self_peer_id:
#				all_players_ready = false
#				if parent.is_host:
#					member_username = member_username + " (loading)"
		
		tracked_players[member_steam_id] = {"username": member_username}


func _on_Lobby_Joined(joined_lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	print_debug("on lobby joined")
	if response == 1:
		SteamController.lobby_id = joined_lobby_id
		var _scene_error = get_tree().change_scene("res://multiplayer_lobby.tscn")
		update_tracked_players()
		send_handshakes()
		
#		if not parent.is_host:
#			request_lobby_update()

func _on_Lobby_Chat_Update(_update_lobby_id: int, change_id: int, _making_change_id: int, chat_state: int) -> void:
	var username = Steam.getFriendPersonaName(change_id)
	update_tracked_players()
