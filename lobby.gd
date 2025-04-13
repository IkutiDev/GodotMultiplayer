extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = 7000
const MAX_CONNECTION = 2

var players = {}

var player_info = {"name": "Name"}

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func create_game() -> void:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTION)
	if error:
		printerr(error)
		return
	multiplayer.multiplayer_peer = peer
	
	players[1] = player_info
	
	player_connected.emit(1, player_info)

func join_game(adress : String) -> void:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(adress, PORT)
	
	if error:
		printerr(error)
		return
		
	multiplayer.multiplayer_peer = peer

func _on_player_connected(id : int) -> void:
	_register_player.rpc_id(id, player_info)
	

@rpc("any_peer","reliable")
func _register_player(new_player_info) -> void:
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)

func _on_player_disconnected(id : int) -> void:
	players.erase(id)
	player_disconnected.emit(id)

func _on_connected_to_server() -> void:
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)
	
func _on_connection_failed() -> void:
	multiplayer.multiplayer_peer = null
	
func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
