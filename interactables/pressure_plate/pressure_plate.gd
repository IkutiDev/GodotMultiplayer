extends Node2D

signal toggle(state)

@export var is_down := false
@export var plate_up : Sprite2D
@export var plate_down : Sprite2D
@export var area_2d : Area2D

var bodies_on_plate := 0

func _ready() -> void:
	area_2d.body_entered.connect(_on_area_2d_body_entered)
	area_2d.body_exited.connect(_on_area_2d_body_exited)
	
func _on_area_2d_body_entered(_body : Node2D) -> void:
	if not multiplayer.is_server():
		return
	bodies_on_plate+=1
	update_plate_state()

func _on_area_2d_body_exited(_body : Node2D) -> void:
	if multiplayer.multiplayer_peer == null:
		return
	if not multiplayer.is_server():
		return
	bodies_on_plate-=1
	update_plate_state()

func update_plate_state() -> void:
	is_down = bodies_on_plate > 0
	toggle.emit(is_down)
	set_plate_properties()

func set_plate_properties() -> void:
	plate_down.visible = is_down
	plate_up.visible = !is_down
	
func _on_multiplayer_synchronizer_delta_synchronized() -> void:
	set_plate_properties()
