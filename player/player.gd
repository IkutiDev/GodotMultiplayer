extends CharacterBody2D

@export var player_camera : PackedScene
@export var player_sprite : AnimatedSprite2D

@export var camera_height : float = 0.0

@export var movement_speed = 300
@export var gravity = 30
@export var jump_strength = 600
@export var max_jumps := 1

@export var push_force := 10

@onready var initial_sprite_scale = player_sprite.scale

var jump_count : int = 0
var camera_instance
var owner_id := 1
var state = PlayerState.IDLE
var current_interactable = null

enum PlayerState {
	IDLE,
	WALKING,
	JUMP_STARTED,
	JUMPING,
	DOUBLE_JUMPING,
	FALLING
}

func _enter_tree() -> void:
	owner_id = name.to_int()
	set_multiplayer_authority(owner_id)
	if owner_id != multiplayer.get_unique_id():
		return
	set_up_camera()
	player_sprite.animation_finished.connect(_on_animation_finished)

func _exit_tree() -> void:
	player_sprite.animation_finished.disconnect(_on_animation_finished)
func _physics_process(_delta: float) -> void:
	if owner_id != multiplayer.get_unique_id():
		return
	var horizontal_input = (Input.get_action_strength("move_right")
	 - Input.get_action_strength("move_left"))
	
	velocity.x  = horizontal_input * movement_speed
	velocity.y += gravity
	
	if Input.is_action_just_pressed("interact"):
		if current_interactable != null:
			current_interactable.interact.rpc_id(1)
	
	handle_movement_state()
		
	move_and_slide()
	face_movement_direction(horizontal_input)
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var pushable = collision.get_collider() as PushableObject
		if pushable == null:
			return
		var point = collision.get_position() - pushable.global_position
		pushable.push(-collision.get_normal() * push_force, collision.get_position())
	
	

func handle_movement_state() -> void:
	# Decide State
	if Input.is_action_just_pressed("jump") and is_on_floor():
		state = PlayerState.JUMP_STARTED
	elif is_zero_approx(velocity.x) and is_on_floor():
		state = PlayerState.IDLE
	elif not is_zero_approx(velocity.x) and is_on_floor():
		state = PlayerState.WALKING
	else:
		state = PlayerState.JUMPING
		
	if velocity.y > 0.0 and not is_on_floor():
		if Input.is_action_just_pressed("jump"):
			state = PlayerState.DOUBLE_JUMPING 
		else:
			state = PlayerState.FALLING
			
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y = 0

func face_movement_direction(horizontal_input : float) -> void:
	if not is_zero_approx(horizontal_input):
		if horizontal_input <  0:
			player_sprite.scale = Vector2(-initial_sprite_scale.x, initial_sprite_scale.y)
		else:
			player_sprite.scale = initial_sprite_scale

func _process(_delta: float) -> void:
	if multiplayer.multiplayer_peer == null:
		return
	if owner_id != multiplayer.get_unique_id():
		return
	update_cmaera_pos()
	update_animation_and_jump_state()

func _on_animation_finished() -> void:
	if state == PlayerState.JUMPING:
		player_sprite.play("jump")

func update_animation_and_jump_state() -> void:
	
	match state:
		PlayerState.IDLE:
			player_sprite.play("idle")
			jump_count = 0
		PlayerState.WALKING:
			player_sprite.play("walk")
			jump_count = 0
		PlayerState.JUMP_STARTED:
			player_sprite.play("jump_start")
			velocity.y = -jump_strength
			jump_count += 1
		PlayerState.JUMPING:
			pass
		PlayerState.DOUBLE_JUMPING:
			player_sprite.play("double_jump_start")
			jump_count += 1
			if jump_count <= max_jumps:
				velocity.y = -jump_strength
		PlayerState.FALLING:
			player_sprite.play("fall")

func set_up_camera() -> void:
	camera_instance = player_camera.instantiate()
	camera_instance.global_position.y = camera_height
	get_tree().current_scene.add_child.call_deferred(camera_instance)

func update_cmaera_pos() -> void:
	camera_instance.global_position.x = global_position.x


func _on_interaction_area_2d_area_entered(area: Area2D) -> void:
	current_interactable = area


func _on_interaction_area_2d_area_exited(area: Area2D) -> void:
	if current_interactable == area:
		current_interactable = null
