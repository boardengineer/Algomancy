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
		print_debug("received message from ", packet["steam_id_remote"], " ", data)
		return true
	
	return false