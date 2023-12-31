extends Node

func _process(_delta):
	if SteamController.lobby_id > 0:
		while read_p2p_packet():
			pass

func read_p2p_packet() -> bool:
	var packet_size = Steam.getAvailableP2PPacketSize(0)
	
	if packet_size > 0:
		var packet = Steam.readP2PPacket(packet_size, 0)
		var data = bytes2var(packet["data"].decompress_dynamic(-1, File.COMPRESSION_GZIP))
		var sender = packet["steam_id_remote"]
		
		print_debug("received message from ", packet["steam_id_remote"], " ", data)
		
		if data.type == "start_game":
			SteamController.start_game(false)
		if data.type == "status_started_game":
			SteamController.receive_game_started_status(sender)
		if data.type == "game_state":
			SteamController.receive_game_state(data.state)
		if data.type == "draft_selection":
			SteamController.receive_draft_selection(sender, data.draft_selection)
		if data.type == "command":
			SteamController.receive_ability_or_pass(sender, data.command)
		return true
	
	return false
