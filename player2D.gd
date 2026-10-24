extends CharacterBody2D


@export var speed = 140.0

const HALF_WIDTH: float = 10.0
const SCREEN_WIDTH: float = 472.0

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var curl_timer: Timer = $"../CurlTimer"
@onready var cooldown_timer: Timer = $"../CooldownTimer"

var is_curled = false
var can_curl = false

func _physics_process(delta: float) -> void:
	
	var direction := Input.get_axis("left", "right")
	
	if is_curled:
		velocity.x = 0.0
	else:
		velocity.x = direction * speed 
		

			
		# vertical velocity is zero as our sprite should only move horiontally
		velocity.y = 0.0
		
		move_and_slide()
		
		# clamping sprite to visible screen
		global_position.x = clampf(global_position.x, HALF_WIDTH, SCREEN_WIDTH - HALF_WIDTH)
		
		
		if direction < 0:
			sprite_2d.flip_h = true
		elif direction > 0:
			sprite_2d.flip_h = false
		

		if Input.is_action_just_pressed("curl") and can_curl and not is_curled:
			enter_curl()
			
			
# function to perform a curl while space is presses
func enter_curl() -> void:
	can_curl = false
	is_curled = true 
	# Call the animation here
	curl_timer.start(1.5)
	
