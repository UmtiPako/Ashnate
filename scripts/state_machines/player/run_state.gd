class_name PlayerRunState
extends PlayerState

func physics_update(delta: float) -> void:
	if check_push_transition(): return

	if not character.is_on_floor():
		state_machine.transition_to("fall")
		return

	if character.requests_jump:
		state_machine.transition_to("jump")
		return
		
	if dash_component.can_dash and Input.is_action_just_pressed("dash"):
		state_machine.transition_to("dash")
		return		

	var direction := Input.get_axis("ui_left", "ui_right")

	if direction == 0.0:
		state_machine.transition_to("idle")
		return

	movement_component.apply_horizontal_movement(direction, delta)
