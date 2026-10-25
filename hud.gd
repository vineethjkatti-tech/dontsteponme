extends Control

@onready var score_label: Label = $MarginContainer/BannerPanel/MarginContainer/ScoreLabel

var elapsed_time: float = 0.0
var is_active: bool = true

func _process(delta: float) -> void:
	if not is_active:
		return
	
	elapsed_time += delta
	score_label.text = "SURVIVED: %s" % format_time(elapsed_time)

func stop_timer() -> float:
	is_active = false
	return elapsed_time

func format_time(seconds: float) -> String:
	var total_sec := int(seconds)
	var mins := total_sec / 60
	var secs := total_sec % 60
	var tenths := int(fmod(seconds, 1.0) * 10.0)
	return "%02d:%02d.%d" % [mins, secs, tenths]
