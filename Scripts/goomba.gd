extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $Hurtbox

@onready var ray: RayCast2D = $AnimatedSprite2D/RayCast2D

const SPEED : float = 30.0
var direction : float = -1
var is_dead : bool = false
var is_on_screen : bool = false

func _ready() -> void:
	add_to_group("Enemy")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if is_on_screen:
		if not is_on_floor():
			velocity += get_gravity() * delta
		if not is_dead:
			sprite.play("run")
			velocity.x = SPEED * direction
			move_and_slide()
		else:
			die()
		if ray.is_colliding():
			flip_sprite_and_direction()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	var body : Node2D = area.get_parent()
	if body.is_in_group("Player") or body.is_in_group("Shell"):
		is_dead = true

func die() -> void:
	sprite.play("death")
	hurtbox.set_collision_layer_value(3, false)
	hurtbox.set_collision_mask_value(4, false)
	await get_tree().create_timer(1.0).timeout
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	is_on_screen = true
	
func flip_sprite_and_direction() -> void:
	direction = direction * -1
	sprite.flip_h = not sprite.flip_h
	ray.scale.x *= -1
