extends Area2D

signal hazard_finished

@export var telegraph_time = 1.5
@export var slam_duration = 0.08

# to preload the two boot frames
var tex_falling: Texture2D = preload("res://boot2.png")
var tex_slam: Texture2D = preload("res://boot1.png")

@onready var shadow: Sprite2D = $ShadowSprite
@onready var boot: Sprite2D = $BootSprite
@onready var hitbox: CollisionShape2D = $HitBox


var has_hit_chair: bool = false

func _ready() -> void:
	hitbox.disabled = true
	
	# place the boot way high before the slam
	boot.texture = tex_falling
	boot.position.y = -220.0
	
	# starting the shadow small and increasing its size
	shadow.scale = Vector2(0.15, 0.15)
	shadow.modulate.a = 0.1
	
func start_telegraph() -> void:
	var tween := create_tween().set_parallel(true)
	# expand shadow to full scale and darken it over telegraph_time
	tween.tween_property(shadow, "scale", Vector2(1.0, 1.0), telegraph_time)
	tween.tween_property(shadow, "modulate:a", 0.85, telegraph_time)
	tween.chain().tween_callback(slam_down)
	
func slam_down() -> void:
	var drop_tween := create_tween()
	# drop rapidly down to impact the ground (y = 0 relative to FootHazard)
	drop_tween.tween_property(boot, "position:y", 0.0, slam_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	drop_tween.tween_callback(trigger_impact)
	
func trigger_impact() -> void:
	boot.texture = tex_slam
	hitbox.disabled = false
	
	var overlapping_areas: Array[Area2D] = get_overlapping_areas()
	var overlapping_bodies: Array[Node2D] = get_overlapping_bodies()

	for area in overlapping_areas:
		if area.is_in_group("chair"):
			has_hit_chair = true
			if area.has_method("break_chair"):
				area.break_chair()
			break

	if not has_hit_chair:
		for body in overlapping_bodies:
			if body.is_in_group("player"):
				if body.has_method("take_hit"):
					body.take_hit(global_position.x)

	await get_tree().create_timer(0.35).timeout
	hitbox.disabled = true
	
	boot.texture = tex_falling
	var lift_tween := create_tween()
	lift_tween.tween_property(boot, "position:y", -240.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	lift_tween.tween_callback(_on_hazard_complete)

func _on_hazard_complete() -> void:
	hazard_finished.emit()
	queue_free()

			
			
