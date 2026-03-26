class_name PlayerDashState
extends PlayerState

@export var after_per_second_gravity_multiplier: float = 0.2
var fallback_done: bool = false  

func enter() -> void:
	dash_component.can_dash = false			

	fallback_done = false
	after_per_second_gravity_multiplier = 0.2
	
	character.velocity = Vector2.ZERO
	
	var dir := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	).normalized()	
		
	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT 
	
	await dash_component.apply_dash(dir) 
	gravity_fallback()

func physics_update(delta: float) -> void:
	if check_push_transition(): return
	
	if dash_component.is_dashing: return

	gravity_component.apply_gravity(delta, after_per_second_gravity_multiplier)		

	var dir := Input.get_axis("ui_left", "ui_right")
	movement_component.apply_horizontal_movement(dir, delta, true, 2200)

	if character.is_on_floor():		
		state_machine.transition_to("run" if dir != 0.0 else "idle")
	elif fallback_done:
		if character.velocity.y >= 0:
			state_machine.transition_to("fall")
		else:
			state_machine.transition_to("jump")		


func gravity_fallback() -> void:
	var tween = create_tween()
	tween.tween_property(self, "after_per_second_gravity_multiplier", 1.0, 0.1)\
		 .set_ease(Tween.EASE_IN_OUT)
	await tween.finished

	fallback_done = true  
