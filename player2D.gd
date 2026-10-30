extends CharacterBody2D

var snd_curl: AudioStream = preload("res://jump.wav")
var snd_squish: AudioStream = preload("res://random.wav")
 
@export var speed = 140.0
@export var curl_friction = 6.0
@export var friction = 12.0
@export var boost_multiplier: float = 1.5

const HALF_WIDTH: float = 10.0
const SCREEN_WIDTH: float = 472.0

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var curl_timer: Timer = $CurlTimer
@onready var cooldown_timer: Timer = $CooldownTimer

var is_curled = false
var can_curl = true
var is_boosted: bool = false
var boost_timer: SceneTreeTimer = null

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
			# if the player gets a near miss the pseed is multiplied by the multiplier value
			var current_speed: float = speed * (boost_multiplier if is_boosted else 1.0)
			velocity.x = direction * current_speed  # <-- FIXED
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
	
	# play armor/curl sound
	var sfx := AudioStreamPlayer2D.new()
	sfx.stream = snd_curl
	sfx.bus = "SFX"
	sfx.finished.connect(sfx.queue_free)
	add_child(sfx)
	sfx.play()
	
	# squash wide, then snap into ball:
	var t := create_tween()
	t.tween_property(sprite_2d, "scale", Vector2(1.3, 0.7), 0.06).set_trans(Tween.TRANS_QUAD)
	t.tween_property(sprite_2d, "scale", Vector2(0.9, 1.1), 0.08)
	t.tween_property(sprite_2d, "scale", Vector2(1.0, 1.0), 0.06)
	
	curl_timer.start(1.5)
	
func curling_up_timeout() -> void:
	print("Curl finished! Starting 4s cooldown...")
	is_curled = false
	sprite_2d.play("default")
	modulate = Color(0.6, 0.6, 0.6)
	cooldown_timer.start(4.0)
	
	var t := create_tween()
	t.tween_property(sprite_2d, "scale", Vector2(0.8, 1.3), 0.08)
	t.tween_property(sprite_2d, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_BOUNCE)
	
func cooldown_timer_timeout() -> void:
	print("Cooldown over! Can curl again.")
	can_curl = true
	modulate = Color(1.0, 1.0, 1.0)
	
func take_hit(_hazard_x: float) -> void:
	if is_curled:
		print("Armored! Survived the stomp.")
		var flash := create_tween()
		flash.tween_property(sprite_2d, "modulate", Color(1.8, 1.8, 1.8), 0.08)
		flash.tween_property(sprite_2d, "modulate", Color(1.0, 1.0, 1.0), 0.08)
	else:
		print("Squashed! Game Over.")
		set_physics_process(false)
		
		# play splat sound
		var sfx := AudioStreamPlayer.new()
		sfx.stream = snd_squish
		sfx.bus = "SFX"
		sfx.finished.connect(sfx.queue_free)
		get_tree().root.add_child(sfx)
		sfx.play()
		
		# squish bug visual
		var death_tween := create_tween()
		death_tween.tween_property(sprite_2d, "scale:y", 0.12, 0.08)
		death_tween.tween_property(sprite_2d, "scale:x", 1.4, 0.08)
		
		# stop HUD timer and grab final survival time
		var final_score := 0.0
		var hud = get_tree().get_first_node_in_group("hud")
		if not hud:
			hud = get_parent().get_node_or_null("HUD")
		if hud and hud.has_method("stop_timer"):
			final_score = hud.stop_timer()
		
		# pass time to GameOverScreen and trigger sequence
		var game_over_ui = get_tree().get_first_node_in_group("game_over_ui")
		if game_over_ui and game_over_ui.has_method("show_game_over"):
			if game_over_ui.has_method("set_final_score"):
				game_over_ui.set_final_score(final_score)
			game_over_ui.show_game_over()
			
func trigger_adrenaline_boost(duration: float = 1.5) -> void:
	is_boosted = true
	
	# visual effects that flash bright yellow
	var flash_tween = create_tween()
	flash_tween.tween_property(sprite_2d, "modulate", Color(0.2, 1.8, 1.8), 0.08)
	flash_tween.tween_property(sprite_2d, "modulate", Color(1.0, 1.0, 1.0), 0.15)
	
	# reset the timer so that the boost stacks
	boost_timer = get_tree(). create_timer(duration)
	boost_timer.timeout.connect(func():
		is_boosted = false
	)
