extends Area2D

@export var broken_texture: Texture2D = preload("res://chair-broken.png")
@export var normal_texture: Texture2D = preload("res://chair.png")
@export var snd_break: AudioStream = preload("res://hitHurt (1).wav")
@export var respawn_time: float = 6.0

@export var min_x: float = 60.0
@export var max_x: float = 420.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var is_broken: bool = false

func _ready() -> void:
	sprite.texture = normal_texture
	sprite.modulate.a = 1.0
	collision_shape.disabled = false

func break_chair() -> void:
	if is_broken:
		return
	is_broken = true
	
	# play shatter sound
	var sfx := AudioStreamPlayer2D.new()
	sfx.stream = snd_break
	sfx.finished.connect(sfx.queue_free)
	add_child(sfx)
	sfx.play()
	
	collision_shape.set_deferred("disabled", true)
	sprite.texture = broken_texture
	
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.8).set_delay(0.5)
	tween.tween_callback(respawn_chair)

func respawn_chair() -> void:
	await get_tree().create_timer(respawn_time).timeout
	
	var new_x := randf_range(min_x, max_x)
	global_position.x = new_x
	
	sprite.texture = normal_texture
	is_broken = false
	
	var respawn_tween := create_tween()
	respawn_tween.tween_property(sprite, "modulate:a", 1.0, 0.4)
	await respawn_tween.finished
	
	collision_shape.set_deferred("disabled", false)
	print("--- Chair respawned at X: ", new_x)
