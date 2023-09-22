extends Node2D

onready var lobbies_list = $Lobbies

func _ready():
	var _unused = Steam.connect("lobby_created", self, "_on_Lobby_Created")
	_unused = Steam.connect("lobby_match_list", self, "_on_Lobby_Match_List")

func _on_Button_pressed():
	var old_main = get_tree().get_current_scene()
	var main_scene = load("res://main.tscn").instance()
	
	main_scene.call_deferred("init", true, {})
	
	get_tree().get_root().add_child(main_scene)
	get_tree().set_current_scene(main_scene)
	get_tree().get_root().remove_child(old_main)

func _on_CreateLobby_pressed():
	if SteamController.lobby_id == 0:
		Steam.createLobby(SteamController.LobbyAvailability.PUBLIC, 2)

func _on_ShowLobbies_pressed():
	Steam.addRequestLobbyListDistanceFilter(3)
	Steam.addRequestLobbyListStringFilter("game", "Algomancy", 0)
	Steam.requestLobbyList()

func _on_Lobby_Created(connect: int, lobby_id: int) -> void:
	if connect == 1:
		SteamController.lobby_id = lobby_id
		
		var _unused = Steam.setLobbyJoinable(lobby_id, true)
		
		_unused = Steam.setLobbyData(lobby_id, "game", "Algomancy")
		_unused = Steam.setLobbyData(lobby_id, "host", Steam.getPersonaName())
		
		var _scene_change_error = get_tree().change_scene("res://multiplayer_lobby.tscn")

func _on_Lobby_Match_List(lobbies: Array) -> void:
	for found_lobby_id in lobbies:
		var join_button = Button.new()
		var host_name = Steam.getLobbyData(found_lobby_id, "host")
		join_button.text = str(host_name)
		lobbies_list.add_child(join_button)
		join_button.connect("pressed", self, "join_button_pressed", [found_lobby_id])

func join_button_pressed(joining_lobby_id: int) -> void:
	Steam.joinLobby(joining_lobby_id)
