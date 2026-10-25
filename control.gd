extends Control

@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton
@onready var cursor: Label = $Cursor
@onready var buttons: Array[Button] = [
	$CenterContainer/VBoxContainer/PlayButton,
	$CenterContainer/VBoxContainer/QuitButton
]

var active_index: int = 0
var bob_tween: Tween

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Connect hover & focus signals for keyboard, controller, and mouse
	for i in range(buttons.size()):
		var btn = buttons[i]
		btn.mouse_entered.connect(_on_button_hovered.bind(i))
		btn.focus_entered.connect(_on_button_hovered.bind(i))

	play_button.grab_focus()

	# Wait until UI containers finish centering everything on screen
	await get_tree().process_frame
	_update_cursor_position(false)
	_start_cursor_bob()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_button_hovered(index: int) -> void:
	if active_index != index:
		active_index = index
		_update_cursor_position(true)

func _update_cursor_position(animated: bool) -> void:
	var target_btn = buttons[active_index]
	var target_x = target_btn.global_position.x - 20.0
	var target_y = target_btn.global_position.y + (target_btn.size.y / 2.0) - (cursor.size.y / 2.0)

	if animated:
		# Restart the bob tween after moving so it doesn't fight position
		if bob_tween:
			bob_tween.kill()

		var t := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.tween_property(cursor, "global_position:y", target_y, 0.12)
		t.parallel().tween_property(cursor, "global_position:x", target_x, 0.12)
		t.tween_callback(_start_cursor_bob)
	else:
		cursor.global_position = Vector2(target_x, target_y)

func _start_cursor_bob() -> void:
	if bob_tween:
		bob_tween.kill()
	
	var base_x = cursor.global_position.x
	bob_tween = create_tween().set_loops()
	bob_tween.tween_property(cursor, "global_position:x", base_x - 4.0, 0.35).set_trans(Tween.TRANS_SINE)
	bob_tween.tween_property(cursor, "global_position:x", base_x, 0.35).set_trans(Tween.TRANS_SINE)
