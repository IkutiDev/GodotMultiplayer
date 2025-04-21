class_name KeyDoor 
extends Node2D

signal all_players_finished

@export var is_door_open := false
@export var door_open : Sprite2D
@export var door_closed : Sprite2D
@export var exit_area : Area2D

var finished_players := 0

func open_door(body : Node2D) -> void:
	if not multiplayer.is_server():
		return
	if is_door_open:
		return
	is_door_open = true
	body.get_parent().call_deferred("queue_free")
	exit_area.monitoring = true
	set_door_properties()

func set_door_properties():
	door_open.visible = is_door_open
	door_closed.visible = !is_door_open

func _on_multiplayer_synchronizer_delta_synchronized() -> void:
	set_door_properties()


func _on_exit_area_2d_body_entered(body: Node2D) -> void:
	finished_players += 1
	body.queue_free()
	
	if finished_players > len(multiplayer.get_peers()):
		all_players_finished.emit()
