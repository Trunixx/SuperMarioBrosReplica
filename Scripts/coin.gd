extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.play("default")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_interactable_area_entered(area: Area2D) -> void:
	var parent : Node2D = area.get_parent()
	if parent.is_in_group("Player"):
		queue_free()
