extends Node

const SAVE_PATH: String = "user://highscore.save"

# stores high score for that particular session
var session_best = 0.0

func _ready() -> void:
	load_record()

func try_update_record(time_survived: float) -> bool:
	if time_survived > session_best:
		session_best = time_survived
		save_record()
		return true
	return false
	
func save_record() -> void:
	var config := ConfigFile.new()
	config.set_value("Records", "best_time", session_best)
	var err := config.save(SAVE_PATH)
	if err == OK:
		print("------------Local High Score Saved!: %s ---" % format_time(session_best))	
	else:
		push_error("Failed to save high score! Error: %d" % err)
		
func load_record() -> void:
	var config := ConfigFile.new()
	var err := config.load(SAVE_PATH)
	if err == OK:
		session_best = config.get_value("Records", "best_time", 0.0)
		print("----------Loaded High Score: %s----" % format_time(session_best))
	else:
		session_best = 0.0		
		
func format_time(seconds: float) -> String:
	var total_sec := int(seconds)
	var mins := total_sec / 60
	var secs := total_sec % 60
	var tenths := int(fmod(seconds, 1.0) * 10.0)
	return "%02d:%02d.%d" % [mins, secs, tenths]
