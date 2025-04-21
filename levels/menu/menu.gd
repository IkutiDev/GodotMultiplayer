extends Node

@export var level_container : Node
@export var level_scene : PackedScene
@export var host_button : Button
@export var join_button : Button
@export var start_button : Button
@export var ip_line_edit : LineEdit
@export var status_label : Label

@export var not_connected_hbox : HBoxContainer
@export var host_hbox : HBoxContainer
@export var UI : Control

func _enter_tree() -> void:
	host_button.pressed.connect(_on_host_button_pressed)
	join_button.pressed.connect(_on_join_button_pressed)
	start_button.pressed.connect(_on_start_button_pressed)

func _ready() -> void:
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	
func _exit_tree() -> void:
	host_button.pressed.disconnect(_on_host_button_pressed)
	join_button.pressed.disconnect(_on_join_button_pressed)
	start_button.pressed.disconnect(_on_start_button_pressed)
	
func _on_host_button_pressed() -> void:
	not_connected_hbox.hide()
	host_hbox.show()
	status_label.text = "Hosting!"
	Lobby.create_game()
	
func _on_join_button_pressed() -> void:
	not_connected_hbox.hide()
	Lobby.join_game(ip_line_edit.text)
	status_label.text = "Connecting..."
	print("Trying to join the game")
	
func _on_start_button_pressed() -> void:
	hide_menu.rpc()
	change_level.call_deferred(level_scene)

func change_level(scene : PackedScene) -> void:
	for c in level_container.get_children():
		level_container.remove_child(c)
		c.level_complete.disconnect(_on_level_complete)
		c.queue_free()
	var new_level = scene.instantiate()
	level_container.add_child(new_level)
	new_level.level_complete.connect(_on_level_complete)

func _on_connection_failed() -> void:
	status_label.text = "Connection Failed"
	not_connected_hbox.show()

func _on_connected_to_server() -> void:
	status_label.text = "Connected!"

@rpc("call_local", "authority", "reliable")
func hide_menu() -> void:
	UI.hide()

func _on_level_complete():
	call_deferred("change_level", level_scene)
