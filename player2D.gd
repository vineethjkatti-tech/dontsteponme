extends CharacterBody2D


@export var speed = 140.0
@export var curl_friction = 6.0
@export var friction = 12.0

const HALF_WIDTH: float = 10.0
const SCREEN_WIDTH: float = 472.0

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var curl_timer: Timer = $CurlTimer
@onready var cooldown_timer: Timer = $CooldownTimer

var is_curled = false
var can_curl = true

func _ready() -> void:
	# .one_shot makes sure the timer doesn't loop
	curl_timer.one_shot = true
	cooldown_timer.one_shot = true
	
# testing what is wrong
	if not curl_timer.timeout.is_connected(curling_up_timeout):
		curl_timer.timeout.connect(curling_up_timeout)
	if not cooldown_timer.timeout.is_connected(cooldown_timer_timeout):
		cooldown_timer.timeout.connect(cooldown_timer_timeout)

func _physics_process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("curl") and can_curl and not is_curled:
		enter_curl()
	
	if is_curled:
		velocity.x = move_toward(velocity.x, 0.0, curl_friction)
	else:
		var direction := Input.get_axis("left", "right")
		
		
		if direction != 0.0:
			velocity.x = direction * speed
			sprite_2d.flip_h = (direction < 0.0)
			sprite_2d.play("Walking")
		else:
			velocity.x = move_toward(velocity.x, 0, friction)
			if velocity.x == 0.0:
				sprite_2d.play("default")
			
		# vertical velocity is zero as our sprite should only move horiontally
		velocity.y = 0.0
		move_and_slide()

		# clamping sprite to visible screen
		global_position.x = clampf(global_position.x, HALF_WIDTH, SCREEN_WIDTH - HALF_WIDTH)
	
		if Input.is_action_just_pressed("curl") and can_curl and not is_curled:
			enter_curl()
			
# function to perform a curl while space is presses
func enter_curl() -> void:
	print("Entered curl")
	can_curl = false
	is_curled = true 
	sprite_2d.play("Curling Up")
	curl_timer.start(1.5)
	
func curling_up_timeout() -> void:
	print("Curl finished! Starting 4s cooldown...")
	is_curled = false
	sprite_2d.play("default")
	modulate = Color(0.6, 0.6, 0.6)
	cooldown_timer.start(4.0)
	
func cooldown_timer_timeout() -> void:
	print("Cooldown over! Can curl again.")
	can_curl = true
	modulate = Color(1.0, 1.0, 1.0)
	
func take_hit(_hazard_x: float) -> void:
	if is_curled:
		# survived the stomp by being curled up!
		print("Armored! Survived the stomp.")
		# tiny camera shake or squash flash
		var tween := create_tween()
		tween.tween_property(sprite_2d, "modulate", Color(1.5, 1.5, 1.5), 0.08)
		tween.tween_property(sprite_2d, "modulate", Color(1.0, 1.0, 1.0), 0.08)
	else:
		# flattened / Game Over
		print("Squashed! Game Over.")
		set_physics_process(false)
		
		# squish visual
		var death_tween := create_tween()
		death_tween.tween_property(sprite_2d, "scale:y", 0.1, 0.1)
		death_tween.tween_callback(func():
			# Reload scene after 1 second
			await get_tree().create_timer(1.0).timeout
			get_tree().reload_current_scene()
		)
