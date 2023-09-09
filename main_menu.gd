extends Node2D


func _ready():
	print_debug("connected?")
	var _unused = Steam.connect("lobby_created", self, "_on_Lobby_Created")

func _on_Button_pressed():
	var _scene_change_error = get_tree().change_scene("res://main.tscn")
	
func _on_CreateLobby_pressed():
	if SteamController.lobby_id == 0:
		Steam.createLobby(SteamController.LobbyAvailability.PUBLIC, 2)

func _on_ShowLobbies_pressed():
	print_debug("pressed show lobbies")
	
func _on_Lobby_Created(connect: int, lobby_id: int) -> void:
	if connect == 1:
		SteamController.lobby_id = lobby_id
		
		var _unused = Steam.setLobbyJoinable(lobby_id, true)
		
		_unused = Steam.setLobbyData(lobby_id, "game", "Algomancy")
		_unused = Steam.setLobbyData(lobby_id, "host", Steam.getPersonaName())
		
		var _scene_change_error = get_tree().change_scene("res://multiplayer_lobby.tscn")
