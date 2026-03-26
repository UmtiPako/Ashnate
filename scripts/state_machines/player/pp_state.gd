class_name PlayerPPState
extends PlayerState

@export var justPPdTimer: Timer
var wait_for_gravity: float = 0.07

func enter() -> void:
	wait_for_gravity = 0.07

	if character.velocity.y > 300:
		character.velocity.y = 200

	character.velocity += push_pull_component.pp_velocity
	push_pull_component.pp_velocity = Vector2.ZERO

	justPPdTimer.start()

func physics_update(delta: float) -> void:	
	if push_pull_component.pp_velocity != Vector2.ZERO:
		character.velocity += push_pull_component.pp_velocity
		push_pull_component.pp_velocity = Vector2.ZERO
		if character.velocity.y < -850:
			character.velocity.y = -850
		if abs(character.velocity.x) > 850:
			character.velocity.x = sign(character.velocity.x) * 850			
		wait_for_gravity = 0.07
		return

	wait_for_gravity -= delta

	if not character.is_on_floor() and wait_for_gravity <= 0:
		gravity_component.apply_gravity(delta)

	if dash_component.can_dash and Input.is_action_just_pressed("dash"):
		state_machine.transition_to("dash")
		return

	var direction := Input.get_axis("ui_left", "ui_right")
	if character.is_on_floor():
		movement_component.apply_horizontal_movement(direction, delta, false, movement_component.default_acceleration * 3)
	else:
		movement_component.apply_horizontal_movement(direction, delta, true, movement_component.default_air_acceleration, movement_component.default_air_deceleration * 1.5)

func _change_state() -> void:
	if character.is_on_floor():
		var dir := Input.get_axis("ui_left", "ui_right")
		state_machine.transition_to("run" if dir != 0.0 else "idle")
	else:
		state_machine.transition_to("fall")

func _on_just_pp_cooldown_timeout() -> void:
	if state_machine.current_state == self:
		_change_state()
