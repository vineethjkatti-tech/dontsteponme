extends CanvasLayer

@onready var flash_rect: ColorRect = $FlashRect

var flash_tween: Tween

func _ready() -> void:
	add_to_group("hazard_warning")
	flash_rect.modulate.a = 0.0
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
func trigger_vuln_flash() -> void:
	# interrupt existing flashs so rapid telegraps don't stack opacity
	if flash_tween and flash_tween.is_valid():
		flash_tween.kill()
		
	# jump to 0.25 alpha and revert to 0.0 alpha over 0.2s for the cooldown
	flash_rect.modulate.a = 0.25
	flash_tween = create_tween()
	flash_tween.tween_property(flash_rect, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
