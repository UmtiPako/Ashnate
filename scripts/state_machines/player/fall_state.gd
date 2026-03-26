class_name PlayerFallState
extends PlayerState

@export var fall_gravity_multiplier: float = 2

@export var min_fall_velocity: float = 600
@export var fall_damp: float = 5.0     
  
@onready var coyote_timer: Timer = %CoyoteTimer

func enter() -> void:
	if state_machine.previous_state is PlayerRunState:
		coyote_timer.start()

func exit() -> void:
	coyote_timer.stop()

func physics_update(delta: float) -> void:
	if check_push_transition(): return
	
	if not coyote_timer.is_stopped() and character.requests_jump:
		state_machine.transition_to("jump")
		return

	gravity_component.apply_gravity(delta, fall_gravity_multiplier)

	if character.velocity.y > min_fall_velocity:
		character.velocity.y = lerp(character.velocity.y, min_fall_velocity, fall_damp * delta)

	var dir := Input.get_axis("ui_left", "ui_right")
	movement_component.apply_horizontal_movement(dir, delta, true)
	
	if dash_component.can_dash and Input.is_action_just_pressed("dash"):
		state_machine.transition_to("dash")
		return

	if character.is_on_floor():
		state_machine.transition_to("run" if dir != 0.0 else "idle")
