extends CharacterBody2D

var snd_curl: AudioStream = preload("res://jump.wav")
var snd_squish: AudioStream = preload("res://random.wav")
 
# variable exposed to the inspector panel
@export var speed = 140.0
@export var curl_friction = 6.0
@export var friction = 12.0
@export var boost_multiplier: float = 1.5
@export var pinball_speed: float = 400.0
@export var bounce_friction: float = 1.2 # light friction for the bounce so that it is smoooooth
@export var max_bonus_pinball_time: float = 2.0
@export var base_pinball_time: float = 1.5
@export var def_cooldown: float = 4.0 # the default cooldown
@export var min_cooldown: float = 1.2 # the minimum cooldown it will go to as the play time increases
@export var cooldown_decay_rate: float = 0.04 # reduces colldown by 0.04 secs every second survived


# constants---------
const HALF_WIDTH: float = 10.0
const SCREEN_WIDTH: float = 472.0

# scene elements--------
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var curl_timer: Timer = $CurlTimer
@onready var cooldown_timer: Timer = $CooldownTimer

# variables--------
var is_curled = false
var can_curl = true
var is_boosted: bool = false
var is_pinballing: bool = false
var boost_timer: SceneTreeTimer = null
var survival_time: float = 0.0

func _process(delta: float) -> void:
	survival_time += delta		
	
	
# calculating current cooldown based on play time
func get_current_cooldown() -> float:
	# subing decay over time and clamping to min_cooldown
	return maxf(min_cooldown, def_cooldown - (survival_time * cooldown_decay_rate))

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
	
# curl when space is pressed ----------
	if Input.is_action_just_pressed("curl") and can_curl and not is_curled:
		enter_curl()
#--------------------------------------		
		
# movement and velocity parameters set----------
	if is_pinballing: 
		
		# spin rapidly after bouncing
		sprite_2d.rotation += 25.0 * _delta * signf(velocity.x)
		# slowly fade into normal spped just like for walking..
		velocity.x = move_toward(velocity.x, 0.0, bounce_friction)
		
	elif is_curled:
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
				
#-----------			
	# vertical velocity is zero as our sprite should only move horiontally
	velocity.y = 0.0
	move_and_slide()
#-----------		

# check if the bug has hit any solid objects while pinballing
	if is_pinballing and get_slide_collision_count() > 0:
		var collision := get_slide_collision(0)
		# when collides with wall, bounce opposite direction
		if abs(collision.get_normal().x) > 0.5:
			velocity.x = -velocity.x
			_spawn_bounce_effect()
#-----------							
	_handle_screen_bounce()

func _handle_screen_bounce() -> void:
	var min_x = HALF_WIDTH
	var max_x = SCREEN_WIDTH - HALF_WIDTH
	
	if is_pinballing:
		# when the bug hits the left wall bounce to right
		if global_position.x <= min_x and velocity.x < 0.0:
			global_position.x = min_x
			velocity.x = abs(velocity.x)
			_spawn_bounce_effect()
			# when the bug hits right wall
		elif global_position.x >= max_x and velocity.x > 0.0:
			global_position.x = max_x
			velocity.x = -abs(velocity.x)
			_spawn_bounce_effect()
	
	# clamping sprite to visible screen
	global_position.x = clampf(global_position.x, min_x, max_x	)
	
	
func _spawn_bounce_effect() -> void:
	var t = create_tween()
	# make a slight pull in and push animation to sell the bounce
	t.tween_property(sprite_2d, "scale", Vector2(0.7, 1.3), 0.04)
	t.tween_property(sprite_2d, "scale", Vector2(1.0, 1.0), 0.06)
	
	
	
	
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
	is_pinballing = false
	sprite_2d.rotation = 0.0
	is_curled = false
	sprite_2d.play("default")
	modulate = Color(0.6, 0.6, 0.6)
	
	# start cooldown timer using dynamic cooldown instead of 4.0
	var current_cd: float = get_current_cooldown()
	cooldown_timer.start(current_cd)
	
	var t := create_tween()
	t.tween_property(sprite_2d, "scale", Vector2(0.8, 1.3), 0.08)
	t.tween_property(sprite_2d, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_BOUNCE)
	
func cooldown_timer_timeout() -> void:
	print("Cooldown over! Can curl again.")
	can_curl = true
	modulate = Color(1.0, 1.0, 1.0)
	
func take_hit(_hazard_x: float) -> void:
	if is_curled:
		
		is_pinballing = true
		
		# calculate the distance between the foot and the bug (curled)
		var offset_x: float = global_position.x - _hazard_x
		var launch_dir: float = signf(offset_x)
		
		# if the bug lands at the very center than choose a random side to launch
		if launch_dir == 0.0:
			launch_dir = 1.0 if randi() > 0.5 else -1.0
			
		velocity.x = launch_dir * pinball_speed

#----------

		
		# give bonus pinball time which increases as the distance between a given shoe center and bug decreases
		var distance: float = abs(offset_x)
		
		# mnormalize closeness - 1.0 as dead center and 0.0 a edge
		# assume the lethal shoe half - width is approx.. 35.0 pxs
		var closeness: float = clampf(1.0 - (distance / 35.0), 0.0, 1.0)
		
		# if the bug is in dead center then the bonus of 2.0 applies 
		var dynamic_duration: float = base_pinball_time + (max_bonus_pinball_time * closeness)
		
		# restart the timer with extended duration
		curl_timer.start(dynamic_duration)				
		
#---------
		 
			
		# flash effect
		var flash = create_tween()
		flash.tween_property(sprite_2d, "modulate", Color(2.0, 2.0, 2.0), 0.06)
		flash.tween_property(sprite_2d, "modulate", Color(1.0, 1.0, 1.0), 0.08)
			
	else:
# when the bug dies -------------
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

# -----------------
			
func trigger_adrenaline_boost(duration: float = 1.5) -> void:
	is_boosted = true
	
	# visual effects that flash cyan
	var flash_tween = create_tween()
	flash_tween.tween_property(sprite_2d, "modulate", Color(0.23, 1.053, 1.041, 1.0), 0.08)
	flash_tween.tween_property(sprite_2d, "modulate", Color(1.0, 1.0, 1.0), 0.15)
	
	# reset the timer so that the boost stacks
	boost_timer = get_tree(). create_timer(duration)
	boost_timer.timeout.connect(func():
		is_boosted = false
	)
