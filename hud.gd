extends Control

@onready var score_label: Label = $MarginContainer/BannerPanel/MarginContainer/ScoreLabel
@onready var high_score_label: Label = $TopRightMargin/HighScorePanel/MarginContainer/HighScoreLabel

var elapsed_time: float = 0.0
var is_active: bool = true

func ready() -> void:
	add_to_group("hud")
	high_score_label.text = "Best: %s" % Sessiondata.format_time(Sessiondata.session_best)

func _process(delta: float) -> void:
	if not is_active:
		return
	
	elapsed_time += delta
	score_label.text = "SURVIVED: %s" % format_time(elapsed_time)
	
	if elapsed_time > Sessiondata.session_best:
		high_score_label.text = "BEST: %s" % Sessiondata.format_time(elapsed_time)
		high_score_label.modulate = Color(1.4, 1.2, 0.4) # Subtle gold glow
		

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
