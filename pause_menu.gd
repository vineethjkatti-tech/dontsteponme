extends CanvasLayer

# node references to containers, buttons, and the cursor label
@onready var control: Control = $Control
@onready var resume_button: Button = $Control/Dimmer/CenterContainer/VBoxContainer/ResumeButton
@onready var restart_button: Button = $Control/Dimmer/CenterContainer/VBoxContainer/RestartButton
@onready var menu_button: Button = $Control/Dimmer/CenterContainer/VBoxContainer/MenuButton
@onready var cursor: Label = $Cursor

# button array for index tracking
@onready var buttons: Array[Button] = [
	resume_button,
	restart_button,
	menu_button
]

const MENU_SCENE_PATH: String = "res://control.tscn"

var is_paused: bool = false
var active_index: int = 0
var bob_tween: Tween

func _ready() -> void:
	# keep this UI processing while the gameplay world physics and timers are frozen
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	control.visible = false
	if cursor:
		cursor.visible = false
	
	# connect button click actions
	resume_button.pressed.connect(resume_game)
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	
	# connect hover (mouse) and focus (keyboard/gamepad) to move the cursor
	for i in range(buttons.size()):
		var btn = buttons[i]
		btn.mouse_entered.connect(_on_button_hovered.bind(i))
		btn.focus_entered.connect(_on_button_hovered.bind(i))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		# prevent pausing if bug is squished and Game Over is already active
		var game_over_ui = get_tree().get_first_node_in_group("game_over_ui")
		if game_over_ui and game_over_ui.menu_container.modulate.a > 0.0:
			return
			
		toggle_pause()

func toggle_pause() -> void:
	is_paused = !is_paused
	get_tree().paused = is_paused
	control.visible = is_paused
	
	if is_paused:
		# Reset selection to 'Resume'
		active_index = 0
		resume_button.grab_focus()
		if cursor:
			cursor.visible = true
		
		# Wait one frame for the layout containers to finish calculating coordinates
		await get_tree().process_frame
		
		# Teleport cursor to initial button and start floating animation
		_update_cursor_position(false)
		_start_cursor_bob()
	else:
		if cursor:
			cursor.visible = false
		if bob_tween:
			bob_tween.kill()

func resume_game() -> void:
	is_paused = false
	get_tree().paused = false
	control.visible = false
	if cursor:
		cursor.visible = false
	if bob_tween:
		bob_tween.kill()

func _on_restart_pressed() -> void:
	resume_game()
	var sfx_index = AudioServer.get_bus_index("SFX")
	if sfx_index != -1:
		AudioServer.set_bus_mute(sfx_index, false)
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	resume_game()
	var sfx_index = AudioServer.get_bus_index("SFX")
	if sfx_index != -1:
		AudioServer.set_bus_mute(sfx_index, false)
	get_tree().change_scene_to_file(MENU_SCENE_PATH)

func _on_button_hovered(index: int) -> void:
	# Only update when navigating to a new button while paused
	if is_paused and active_index != index:
		active_index = index
		_update_cursor_position(true)

func _update_cursor_position(animated: bool) -> void:
	if not cursor or not cursor.visible or buttons.is_empty():
		return
		
	var target_btn = buttons[active_index]
	
	# Position 20px to the left of the button edge
	var target_x: float = target_btn.global_position.x - 20.0
	
	# Vertically align the '>' arrow to the button center
	var target_y: float = target_btn.global_position.y + (target_btn.size.y / 2.0) - (cursor.size.y / 2.0)
	
	if animated:
		# Stop existing bobbing so it doesn't fight the movement tween
		if bob_tween:
			bob_tween.kill()
		
		# .set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) ensures the animation runs while paused
		var t := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.tween_property(cursor, "global_position:y", target_y, 0.12)
		t.parallel().tween_property(cursor, "global_position:x", target_x, 0.12)
		
		# Resume bobbing once the cursor arrives at the new button
		t.tween_callback(_start_cursor_bob)
	else:
		# Direct teleport without transition on opening frame
		cursor.global_position = Vector2(target_x, target_y)

func _start_cursor_bob() -> void:
	if bob_tween:
		bob_tween.kill()
		
	if not cursor or not cursor.visible:
		return
		
	var base_x: float = cursor.global_position.x
	
	# Infinite horizontal floating sine wave that processes through pause
	bob_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_loops()
	bob_tween.tween_property(cursor, "global_position:x", base_x - 4.0, 0.35).set_trans(Tween.TRANS_SINE)
	bob_tween.tween_property(cursor, "global_position:x", base_x, 0.35).set_trans(Tween.TRANS_SINE)
