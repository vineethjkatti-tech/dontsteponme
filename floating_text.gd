extends Marker2D

@onready var label: Label = $Label

func setup(text_content = "Close Call", start_pos: Vector2 = Vector2.ZERO):
	global_position = start_pos
	z_index = 100 # appear on top
	
	label.text = text_content
	label.modulate = Color(1.0, 0.9, 0.2, 1.0)
	
	# anchors
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	label.position = -label.size / 2.0
	
	# for apparent visiblility issues..
	scale = Vector2(0.8, 0.8)

	# for classic floating text - pop in - retain - and fade
	scale = Vector2(0.5, 0.5)
	var t = create_tween().set_parallel(true)
	t.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)	.set_trans(Tween.TRANS_BACK)
	t.chain().tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	
	t.tween_property(self, "global_position:y", global_position.y - 24.0, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(label, "modulate:a", 0.0, 0.7).set_delay(0.2)
	
	t.chain().tween_callback(queue_free)
	
	
	
	
