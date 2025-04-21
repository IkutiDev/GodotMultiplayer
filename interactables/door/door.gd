extends Node2D

@export var is_door_open := false
@export var door_open : Sprite2D
@export var door_closed : Sprite2D
@export var collider : CollisionShape2D

func activate(state : bool) -> void:
	if not multiplayer.is_server():
		return
	is_door_open = state
	set_door_properties()

func set_door_properties():
	door_open.visible = is_door_open
	door_closed.visible = !is_door_open
	collider.set_deferred("disabled", is_door_open)


func _on_multiplayer_synchronizer_delta_synchronized() -> void:
	set_door_properties()
