extends CanvasLayer

func _ready() -> void:
	# keep visible in editor or if testing
	if OS.has_feature("mobile") or DisplayServer.is_touchscreen_available():
		visible = true
	elif OS.is_debug_build():
		visible = true
	else:
		visible = false
