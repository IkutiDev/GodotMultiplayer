extends CharacterBody2D

@export var player_camera : PackedScene
@export var player_sprite : AnimatedSprite2D

@export var camera_height : float = 0.0

@export var movement_speed = 300
@export var gravity = 30
@export var jump_strength = 600
@export var max_jumps := 1

@onready var initial_sprite_scale = player_sprite.scale

var is_falling : bool
var is_jumping : bool
var is_jump_cancelled : bool
var is_idle : bool
var is_walking : bool
var is_double_jumping : bool
var jump_count : int = 0
var camera_instance

func _ready() -> void:
	set_up_camera()	
	player_sprite.animation_finished.connect(_on_animation_finished)

func _exit_tree() -> void:
	player_sprite.animation_finished.disconnect(_on_animation_finished)
func _physics_process(_delta: float) -> void:
	var horizontal_input = (Input.get_action_strength("move_right")
	 - Input.get_action_strength("move_left"))
	
	velocity.x  = horizontal_input * movement_speed
	velocity.y += gravity
	handle_movement_state()
	
	handle_jumping()
		
	move_and_slide()
	face_movement_direction(horizontal_input)

func handle_movement_state() -> void:
	is_falling = velocity.y > 0.0 and not is_on_floor()
	is_jumping = Input.is_action_just_pressed("jump") and is_on_floor()
	is_jump_cancelled = Input.is_action_just_released("jump") and velocity.y < 0.0
	is_idle = is_zero_approx(velocity.x) and is_on_floor()
	is_walking = not is_zero_approx(velocity.x) and is_on_floor()
	is_double_jumping = Input.is_action_just_pressed("jump") and is_falling

func handle_jumping() -> void:
	if is_jumping:
		velocity.y = -jump_strength
		jump_count += 1
	elif is_double_jumping:
		jump_count += 1
		if jump_count <= max_jumps:
			velocity.y = -jump_strength
	elif is_jump_cancelled:
		velocity.y = 0
	elif is_on_floor():
		jump_count = 0

func face_movement_direction(horizontal_input : float) -> void:
	if not is_zero_approx(horizontal_input):
		if horizontal_input <  0:
			player_sprite.scale = Vector2(-initial_sprite_scale.x, initial_sprite_scale.y)
		else:
			player_sprite.scale = initial_sprite_scale

func _process(_delta: float) -> void:
	update_cmaera_pos()
	update_animation()

func _on_animation_finished() -> void:
	player_sprite.play("jump")

func update_animation() -> void:
	if is_jumping:
		player_sprite.play("jump_start")
	elif is_double_jumping:
		player_sprite.play("double_jump_start")
	elif is_walking:
		player_sprite.play("walk")
	elif is_falling:
		player_sprite.play("fall")
	elif is_idle:
		player_sprite.play("idle")

func set_up_camera() -> void:
	camera_instance = player_camera.instantiate()
	camera_instance.global_position.y = camera_height
	get_tree().current_scene.add_child.call_deferred(camera_instance)

func update_cmaera_pos() -> void:
	camera_instance.global_position.x = global_position.x
