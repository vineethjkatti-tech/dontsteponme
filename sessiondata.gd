extends Node

# stores high score for that particular session
var session_best = 0.0

func try_update_record(time_survived: float) -> bool:
	if time_survived > session_best:
		session_best = time_survived
		return true
	return false
	
func format_time(seconds: float) -> String:
	var total_sec := int(seconds)
	var mins := total_sec / 60
	var secs := total_sec % 60
	var tenths := int(fmod(seconds, 1.0) * 10.0)
	return "%02d:%02d.%d" % [mins, secs, tenths]
