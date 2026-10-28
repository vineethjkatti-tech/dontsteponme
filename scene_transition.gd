extends CanvasLayer

@onready var overlay: ColorRect = $TransitionOverlay

func _ready() -> void:
	# always process even when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS 

func transition_to_scene(target_scene_path: String) -> void:
	var mat := overlay.material as ShaderMaterial
	
	# Wipe in (dots expand to black)
	var t := create_tween()
	t.tween_property(mat, "shader_parameter/progress", 1.0, 0.45).set_trans(Tween.TRANS_SINE)
	await t.finished
	
	# Change scene
	get_tree().change_scene_to_file(target_scene_path)
	
	# Wipe out (dots shrink away)
	var t_out := create_tween()
	t_out.tween_property(mat, "shader_parameter/progress", 0.0, 0.45).set_trans(Tween.TRANS_SINE)
	
func reload_current_scene() -> void:
	var mat := overlay.material as ShaderMaterial
	var t := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(mat, "shader_parameter/progress", 1.0, 0.4).set_trans(Tween.TRANS_SINE)
	await t.finished
	
	get_tree().paused = false
	get_tree().reload_current_scene()
	
	var t_out = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t_out.tween_property(mat, "shader_parameter/process", 0.0, 0.4).set_trans(Tween.TRANS_SINE)
	
		
		
