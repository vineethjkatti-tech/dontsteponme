extends Sprite2D


@export var speed = 140.0

const HALF_WIDTH: float = 12.0
const SCREEN_WIDTH: float = 480.0

@onready var sprite_2d: Sprite2D = $"."
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
		
		if direction < 0:
			sprite_2d.flip_h = false
		elif direction > 0:
			sprite_2d.flip_h = true
	
