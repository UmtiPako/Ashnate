extends Camera2D

@onready var mistborn: CharacterBody2D = $"../.."

const DEFAULT_ZOOM: Vector2 = Vector2(1, 1)
const AIR_ZOOM: Vector2 = Vector2(0.6, 0.6)
const ZOOM_SPEED: float = 0.2
const HEIGHT_THRESHOLD: float = 200.0
const FALL_OFFSET_MAX: float = 300.0 
const OFFSET_SPEED: float = 3.0

var ground_y: float = 0.0

func _process(delta: float) -> void:
	if mistborn.is_on_floor():
		ground_y = mistborn.global_position.y
		if zoom != DEFAULT_ZOOM:
			zoom.x = move_toward(zoom.x, DEFAULT_ZOOM.x, ZOOM_SPEED * delta)
			zoom.y = move_toward(zoom.y, DEFAULT_ZOOM.y, ZOOM_SPEED * delta)		

	var height = ground_y - mistborn.global_position.y
	
	if mistborn.velocity.y > 0 and height > -100:
		zoom.x = move_toward(zoom.x, DEFAULT_ZOOM.x, ZOOM_SPEED / 2 * delta)
		zoom.y = move_toward(zoom.y, DEFAULT_ZOOM.y, ZOOM_SPEED / 2 * delta)		
	else:
		var t = clamp(height / HEIGHT_THRESHOLD, 0.0, 1.0)
		var target_zoom = DEFAULT_ZOOM.lerp(AIR_ZOOM, t)
		zoom.x = move_toward(zoom.x, target_zoom.x, ZOOM_SPEED * delta)
		zoom.y = move_toward(zoom.y, target_zoom.y, ZOOM_SPEED * delta)

	var fall_t = clamp(mistborn.velocity.y / 600.0, 0.0, 1.0)  
	var target_offset_y = FALL_OFFSET_MAX * fall_t
	offset.y = lerp(offset.y, target_offset_y, OFFSET_SPEED * delta)
