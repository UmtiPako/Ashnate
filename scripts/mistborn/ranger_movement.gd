extends Area2D


func _process(delta: float) -> void:
	front_or_back()
	
	var mouse_pos = get_global_mouse_position()
	
	var vector = mouse_pos - self.global_position
	
	global_rotation = vector.angle()
	
func front_or_back() -> void:
	if Input.is_action_just_pressed("pushpull direction changer"):
		self.scale = Vector2(-self.scale.x, -self.scale.y)
