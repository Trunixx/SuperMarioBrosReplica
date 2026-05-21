extends CharacterBody2D

const SPEED = 150
const JUMP_VELOCITY = -350
const ACCELERATION = 2
const FRICTION = 15

var speed = SPEED
var jump_velocity = JUMP_VELOCITY
var acceleration = ACCELERATION
var friction = FRICTION

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_timer: Timer = $DeathTimer
@onready var hurtbox: Area2D = $Hurtbox
@onready var hitbox: Area2D = $Hitbox

var is_jumping : bool = false
var is_dying : bool = false
var is_dead : bool = false

func _ready() -> void:
	add_to_group("Player")
	get_tree().paused = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() and not is_dying:
		velocity += get_gravity() * delta
	else:
		is_jumping = false
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_dying:
		velocity.y = jump_velocity
		is_jumping = true
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = move_toward(velocity.y, 0, 100)
	
	if Input.is_action_just_pressed("sprint") and is_on_floor() and not is_dying:
		acceleration = ACCELERATION + 2
		speed = SPEED + 50
	if Input.is_action_just_released("sprint") and not is_dying:
		acceleration = ACCELERATION 
		speed = SPEED
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if not is_dying and not is_dead:
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * speed, acceleration)
		else:
			velocity.x = move_toward(velocity.x, 0, friction)
			
	update_animation(direction)
	move_and_slide()
	
func update_animation(direction: float) -> void:
	if is_dying or is_dead:
		return
	if is_jumping:
		sprite.play("jump")
	elif direction != 0:
		sprite.flip_h = (direction < 0)
		sprite.play("run")
	else:
		sprite.play("idle")

func die() -> void:
	is_dying=true
	velocity.x=0
	velocity.y=0
	sprite.play("death")
	death_timer.start(0)    
	get_tree().paused = true
	await get_tree().create_timer(0.3).timeout
	velocity.y = jump_velocity
	is_dying = false
	is_dead = true
	self.set_collision_mask_value(1,false)
	hurtbox.set_collision_mask_value(3, false)
	hitbox.set_collision_mask_value(3, false)
	
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("Enemy"):
		die()
		
func _on_hitbox_area_entered(_area: Area2D) -> void:
	velocity.y = -200
	
func _on_death_timer_timeout() -> void:
	get_tree().reload_current_scene() #TODO: # this should send a signal to the world script for SRP 

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.name == "BottomKillzone": # not cool but it works
		die()
