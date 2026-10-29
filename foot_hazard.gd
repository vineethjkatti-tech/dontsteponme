extends Area2D

signal hazard_finished

@export var telegraph_time = 1.5
@export var slam_duration = 0.08

# to preload the two boot frames
var snd_stomp: AudioStream = preload("res://hitHurt.wav")
var tex_falling: Texture2D = preload("res://boot2.png")
var tex_slam: Texture2D = preload("res://boot1.png")

@onready var shadow: Sprite2D = $ShadowSprite
@onready var boot: Sprite2D = $BootSprite
@onready var hitbox: CollisionShape2D = $HitBox


var has_hit_chair: bool = false

func _ready() -> void:
	hitbox.disabled = true
	
	boot.texture = tex_falling
	boot.position.y = -220.0
	boot.visible = false 
	
	shadow.scale = Vector2(0.15, 0.15)
	shadow.modulate.a = 0.1
	
	start_telegraph()
	
	start_telegraph()
	
func start_telegraph() -> void:
	# 1. Expand and darken shadow
	var t := create_tween()
	t.set_parallel(true)
	t.tween_property(shadow, "scale", Vector2(1.0, 1.0), telegraph_time)
	t.tween_property(shadow, "modulate:a", 0.9, telegraph_time)
	
	# Wait for telegraph to complete, then slam down
	await t.finished
	slam_down()

func slam_down() -> void:
	boot.visible = true 
	var drop_tween := create_tween()
	drop_tween.tween_property(boot, "position:y", 0.0, slam_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await drop_tween.finished
	
	trigger_impact()

func trigger_impact() -> void:
	# fetch current survival_time from the HUD
	var current_time: float = 0.0
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and "elapsed_time" in hud:
		current_time = hud.elapsed_time
		
	# trigger the camera shake
	var cam = get_tree().get_first_node_in_group("camera")
	if cam and cam.has_method("trigger_shoe_shake"):
		cam.trigger_shoe_shake(current_time)
		
	# play stomp sound
	var player := AudioStreamPlayer2D.new()
	player.stream = snd_stomp
	player.bus = "SFX"
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()
	
	boot.texture = tex_slam
	hitbox.disabled = false
	
	# Wait 2 physics frames so Godot registers the newly enabled hitbox
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	var overlapping_areas: Array[Area2D] = get_overlapping_areas()
	var overlapping_bodies: Array[Node2D] = get_overlapping_bodies()

	# 1. Check for chair shelter
	for area in overlapping_areas:
		if area.is_in_group("chair") or area.has_method("break_chair"):
			has_hit_chair = true
			if area.has_method("break_chair"):
				area.break_chair()
			print("--- Chair smashed and absorbed impact!")
			break

	# 2. Check for player hit (only if chair didn't absorb it)
	if not has_hit_chair:
		for body in overlapping_bodies:
			if body.is_in_group("player") or body.has_method("take_hit"):
				print("--- Boot hit bug!")
				body.take_hit(global_position.x)
				break

	# Linger on ground
	await get_tree().create_timer(0.35).timeout
	hitbox.disabled = true
	
	# Retract back up
	boot.texture = tex_falling
	var lift_tween := create_tween()
	lift_tween.tween_property(boot, "position:y", -240.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await lift_tween.finished
	
	hazard_finished.emit()
	queue_free()
