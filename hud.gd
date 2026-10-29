extends Control

@onready var score_label: Label = $MarginContainer/BannerPanel/MarginContainer/ScoreLabel
@onready var high_score_label: Label = $TopRightMargin/HighScorePanel/MarginContainer/HighScoreLabel
@onready var curl_bar: ProgressBar = $BottomLeftMargin/VBoxContainer/CurlBar
@onready var curl_status_label: Label = $BottomLeftMargin/VBoxContainer/CurlStatusLabel

var elapsed_time: float = 0.0
var is_active: bool = true
var player_ref: CharacterBody2D = null
var was_cooldown_active: bool = false

func _ready() -> void:
	add_to_group("hud")
	high_score_label.text = "Best: %s" % Sessiondata.format_time(Sessiondata.session_best)
	
# config progress bar
	curl_bar.show_percentage = false
	curl_bar.min_value = 0.0
	curl_bar.max_value = 4.0
	curl_bar.value = 4.0
	
# locating player node in active scene
	player_ref = get_tree().get_first_node_in_group("player")
	if not player_ref and get_parent():
		player_ref = get_parent().get_node_or_null("player2D")

func _process(delta: float) -> void:
	if not is_active:
		return
	
	elapsed_time += delta
	score_label.text = "SURVIVED: %s" % format_time(elapsed_time)
	
	if elapsed_time > Sessiondata.session_best:
		high_score_label.text = "BEST: %s" % Sessiondata.format_time(elapsed_time)
		high_score_label.modulate = Color(1.4, 1.2, 0.4)
		
	_update_ability_cooldown()

func _update_ability_cooldown() -> void:
	if not is_instance_valid(player_ref):
		return
	
# bug is curled
	if player_ref.is_curled:
		curl_bar.value = 0.0
		curl_status_label.text = "Curled"
		curl_status_label.modulate = Color(1.0, 0.9, 0.2)
		was_cooldown_active = true
		return
		
# cooldown timer has started
	if not player_ref.can_curl:
		var cd_timer: Timer = player_ref.get_node_or_null("CooldownTimer")
		if cd_timer and cd_timer.time_left > 0.0:
			var time_spent: float = cd_timer.wait_time - cd_timer.time_left
			curl_bar.value = time_spent
			curl_status_label.text = "RECHARGING: %0.1fs" % cd_timer.time_left
			curl_status_label.modulate = Color(0.7, 0.7, 0.7)
			was_cooldown_active = true
		return
	
# curl is ready
	curl_bar.value = curl_bar.max_value
	curl_status_label.text = "CURL: READY"
	curl_status_label.modulate = Color(0.3, 1.0, 0.5)
	
	if was_cooldown_active:
		was_cooldown_active = false
		_play_ready_flash()

func _play_ready_flash() -> void:
	# centering the pivot so the bar pops uniformnly
	curl_bar.pivot_offset = curl_bar.size / 2.0
	
	var tween := create_tween().set_parallel(true)
	
	#quick pop effect and return to normal
	var scale_tween := create_tween()
	scale_tween.tween_property(curl_bar, "scale", Vector2(1.15, 1.15), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(curl_bar, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_SINE)
	
	# flahs white then restore
	var flash_tween := create_tween()
	flash_tween.tween_property(curl_bar, "modulate", Color(2.2, 2.2, 2.2), 0.08)
	flash_tween.tween_property(curl_bar, "modulate", Color(1.0, 1.0, 1.0), 0.12)
	
func stop_timer() -> float:
	is_active = false
	var is_record := Sessiondata.try_update_record(elapsed_time)
	if is_record:
		print("-----New Session Best!!", elapsed_time)
	return elapsed_time

func format_time(seconds: float) -> String:
	var total_sec := int(seconds)
	var mins := total_sec / 60
	var secs := total_sec % 60
	var tenths := int(fmod(seconds, 1.0) * 10.0)
	return "%02d:%02d.%d" % [mins, secs, tenths]
