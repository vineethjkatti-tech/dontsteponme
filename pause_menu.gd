extends CanvasLayer

@onready var control: Control = $Control
@onready var resume_button: Button = $Control/Dimmer/CenterContainer/VBoxContainer/ResumeButton
@onready var restart_button: Button = $Control/Dimmer/CenterContainer/VBoxContainer/RestartButton
@onready var menu_button: Button = $Control/Dimmer/CenterContainer/VBoxContainer/MenuButton

const MENU_SCENE_PATH: String = "res://control.tscn"

var is_paused = false

func _ready() -> void:
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	control.visible = false
	
	resume_button.pressed.connect(resume_game)
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		# don't toggle pause if player is already dead / game over screen is showing
		var game_over_ui = get_tree().get_first_node_in_group("game_over_ui")
		if game_over_ui and game_over_ui.menu_container.modulate.a > 0.0:
			return
			
		toggle_pause()
		
func toggle_pause() -> void:
	is_paused = true
	get_tree().paused = is_paused
	control.visible = is_paused
	
	if is_paused:
		resume_button.grab_focus()
		
func resume_game() -> void:
	is_paused = false
	get_tree().paused = false
	control.visible = false
	
func _on_restart_pressed() -> void:
	# always resume before changing scene
	get_tree().paused = false
	# unmute SFX bus incase it was muted
	var sfx_index = AudioServer.get_bus_index("SFX")
	if sfx_index != -1:
		AudioServer.set_bus_mute(sfx_index, false)
		
	get_tree().reload_current_scene()
	
func _on_menu_pressed() -> void:
	get_tree().paused = false
	
	var sfx_index = AudioServer.get_bus_index("SFX")
	if sfx_index != -1:
		AudioServer.set_bus_mute(sfx_index, false)
		
	get_tree().change_scene_to_file("res://control.tscn")
	


	
	
	
			
			

	
