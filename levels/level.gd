extends Node2D

signal level_complete()

@export var players_container : Node2D
@export var player_scenes : Array[PackedScene]
@export var spawn_points : Array[Node2D]
@export var key_door : KeyDoor

var next_spawn_point_index = 0
var next_character_index = 0

var player_instance : Node2D

func _ready() -> void:
	if not multiplayer.is_server():
		return
		
	multiplayer.peer_disconnected.connect(delete_player)
		
	for id in multiplayer.get_peers():
		add_player(id)
		
	add_player(1)
	
	key_door.all_players_finished.connect(_on_all_players_finished)


func _on_all_players_finished() -> void:
	key_door.all_players_finished.disconnect(_on_all_players_finished)
	level_complete.emit()

func _exit_tree() -> void:
	if multiplayer.multiplayer_peer == null:
		return
	if not multiplayer.is_server():
		return
	multiplayer.peer_disconnected.disconnect(delete_player)

func add_player(id : int) -> void:
	player_instance = player_scenes[next_character_index].instantiate()
	next_character_index += 1 
	if next_character_index >= len(player_scenes):
		next_character_index = 0
	player_instance.position = get_spawn_point()
	player_instance.name = str(id)
	players_container.add_child(player_instance)

func delete_player(id) -> void:
	if not players_container.has_node(str(id)):
		return
	players_container.get_node(str(id)).queue_free()

func get_spawn_point() -> Vector2:
	var spawn_point = spawn_points[next_spawn_point_index].position
	
	next_spawn_point_index += 1
	
	if next_spawn_point_index >= len(spawn_points):
		next_spawn_point_index = 0
	
	return spawn_point
