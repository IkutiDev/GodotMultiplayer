extends Node2D

@export var key_scene : PackedScene
@export var key_spawn : Node2D
@export var is_locked := true
@export var chest_locked : Sprite2D
@export var chest_unlocked : Sprite2D


func _on_interactable_interacted() -> void:
	if !multiplayer.is_server():
		return
	if !is_locked:
		return
	is_locked = false
	var key = key_scene.instantiate()
	key_spawn.add_child(key)
	set_chest_properties()
	
func set_chest_properties() -> void:
	chest_locked.visible = is_locked
	chest_unlocked.visible = !is_locked


func _on_multiplayer_synchronizer_delta_synchronized() -> void:
	set_chest_properties()
