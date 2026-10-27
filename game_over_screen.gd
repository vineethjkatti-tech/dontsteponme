extends CanvasLayer

@onready var dimmer: ColorRect = $Dimmer
@onready var menu_container: CenterContainer = $CenterContainer
@onready var retry_button: Button = $CenterContainer/VBoxContainer/RetryButton
@onready var menu_button: Button = $CenterContainer/VBoxContainer/MenuButton

func _ready() -> void:
	# Guarantee the group is registered by code
	add_to_group("game_over_ui")
	
	dimmer.modulate.a = 0.0
	menu_container.modulate.a = 0.0
	menu_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func show_game_over() -> void:
	# mute all sfx audio when game is over
	var sfx_index := AudioServer.get_bus_index("SFX")
	if sfx_index != -1:
		AudioServer.set_bus_mute(sfx_index, true)
	
	print("--- show_game_over() CALLED! ---")
	menu_container.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# dim the background
	var dim_tween := create_tween()
	dim_tween.tween_property(dimmer, "modulate:a", 0.75, 0.8).set_trans(Tween.TRANS_SINE)
	
	# fade in the menu
	var fade_tween := create_tween()
	fade_tween.tween_property(menu_container, "modulate:a", 1.0, 0.6).set_delay(0.2).set_trans(Tween.TRANS_CUBIC)
	
	await fade_tween.finished
	retry_button.grab_focus()

func _on_retry_pressed() -> void:
	# unmute all SFX audio before restarting the game
	var sfx_index = AudioServer.get_bus_index("SFX")
	if sfx_index != -1:
		AudioServer.set_bus_mute(sfx_index, false)
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	# unmute sfx bus when going to main menu
	var sfx_index = AudioServer.get_bus_index("SFX")
	if sfx_index != -1:
		AudioServer.set_bus_mute(sfx_index, false) 
	get_tree().change_scene_to_file("res://control.tscn")

func set_final_score(time_survived: float) -> void:
	var total_sec := int(time_survived)
	var mins := total_sec / 60
	var secs := total_sec % 60
	var tenths := int(fmod(time_survived, 1.0) * 10.0)
	var time_str := "%02d:%02d.%d" % [mins, secs, tenths]
	
	# If you add a ScoreResult label inside GameOverScreen's VBoxContainer:
	var result_lbl = get_node_or_null("CenterContainer/VBoxContainer/ScoreResult")
	if result_lbl:
		var current_str = Sessiondata.format_time(time_survived)
		var best_str = Sessiondata.format_time(Sessiondata.session_best)
		
		if time_survived >= Sessiondata.session_best:
			result_lbl.text = "NEW SESSION RECORD!\n%s" % current_str
		else:
			result_lbl.text = "TIME: %s\nBEST: %s" % [current_str, best_str]
