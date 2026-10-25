extends Area2D

@export var broken_texture: Texture2D = preload("res://chair-broken.png")

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var is_broken: bool = false

func break_chair() -> void:
	if is_broken:
		return
	is_broken = true
	
	# disable collision so it can't absorb a second hit
	collision_shape.set_deferred("disabled", true)
	
	# swap to broken chair sprite
	sprite.texture = broken_texture
	
	# slight splinter shake and fade away for cinemtaic effect!!
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 1.2).set_delay(0.4)
	tween.tween_callback(queue_free)
