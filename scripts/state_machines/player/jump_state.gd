class_name PlayerJumpState
extends PlayerState

@export var jump_cut_multiplier: float = 2.5

func enter() -> void:
	movement_component.apply_jump()

func physics_update(delta: float) -> void:
	if check_push_transition(): return

	if not Input.is_action_pressed("ui_accept") and character.velocity.y < 0:
		gravity_component.apply_gravity(delta, jump_cut_multiplier)
	else:
		gravity_component.apply_gravity(delta)

	var direction := Input.get_axis("ui_left", "ui_right")
	movement_component.apply_horizontal_movement(direction, delta, true)

	if dash_component.can_dash and Input.is_action_just_pressed("dash"):
		state_machine.transition_to("dash")
		return

	if character.velocity.y >= 0:
		state_machine.transition_to("fall")
