extends Camera2D

# default shake 
@export var base_intensity: float = 2.5

# maximum shake
@export var max_intensity: float = 9.0

# extra shake added per second survived
@export var time_scale_factor: float = 0.08

var shake_tween: Tween

func _ready() -> void:
	add_to_group("camera")

func trigger_shoe_shake(survival_time: float = 0.0) -> void:
# calculating intensity that ramps up over game time	
	var calculated_intensity: float = base_intensity + (survival_time * time_scale_factor)
	var final_intensity: float = clampf(calculated_intensity, base_intensity, max_intensity)
	
# duration also increases with time
	var duration: float = clampf(0.12 + (survival_time * 0.0015), 0.12, 0.25)
	
# cancel any active shake tween to avoid conflict
	if shake_tween and shake_tween.is_valid():
		shake_tween.kill()
		
	shake_tween = create_tween()
	
	var steps: int = 4
	for i in range(steps):
		var step_decay: float = 1.0 - (float(i) / float(steps)) # Shake diminishes per step
		var rand_offset := Vector2(
			randf_range(-final_intensity, final_intensity) * step_decay,
			randf_range(-final_intensity, final_intensity) * step_decay
		)
		shake_tween.tween_property(self, "offset", rand_offset, duration / steps)
	shake_tween.tween_property(self, "offset", Vector2.ZERO, 0.04)
			
			
