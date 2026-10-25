extends CanvasLayer

@onready var overlay: ColorRect = $TransitionOverlay

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
