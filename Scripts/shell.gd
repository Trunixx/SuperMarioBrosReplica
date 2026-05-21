extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var hitbox: Area2D = $Hitbox
@onready var ray: RayCast2D = $AnimatedSprite2D/RayCast2D

const SPEED : float = 200.0
var direction : float = -1
var is_moving : bool = false

func _ready() -> void:
	add_to_group("Shell")
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if is_moving:
		velocity.x = SPEED * direction
	else:
		velocity.x = 0
	if ray.is_colliding():
		flip_ray_and_direction()
	if is_moving:
		add_to_group("Enemy")
	if not is_moving:
		remove_from_group("Enemy")
	move_and_slide()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	var body : Node2D = area.get_parent()
	
	if body.is_in_group("Player"):
		is_moving = not is_moving
		
		var flipped : bool = body.get_node("AnimatedSprite2D").flip_h
		if flipped == sprite.flip_h: # I don't get why this works, but it does; I basically did it by fucking around and finding out daa
			flip_ray_and_direction()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	
func flip_ray_and_direction() -> void:
	direction = direction * -1
	sprite.flip_h = not sprite.flip_h
	ray.scale.x *= -1

func _on_hitbox_area_entered(area: Area2D) -> void:
	var body : Node2D = area.get_parent()
	
	var flipped : bool = body.get_node("AnimatedSprite2D").flip_h
	if flipped == sprite.flip_h and body.is_in_group("Player") and not is_moving: # I don't get why this works again
		flip_ray_and_direction()
		
	if not is_moving and body.is_in_group("Player"):
		is_moving = true
