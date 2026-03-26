class_name MovementComponent extends Node

@export var body: CharacterBody2D

@export var max_speed: float
@export var default_acceleration: float
@export var default_deceleration: float
@export var default_air_acceleration: float
@export var default_air_deceleration: float
@export var turnaround_multiplier: float
@export var jump_velocity: float = -600

func apply_horizontal_movement(direction: float, delta: float, is_airborne: bool = false, accel: float = 0.0, decel: float = 0.0) -> void:
	var a := accel if accel != 0.0 else (default_air_acceleration if is_airborne else default_acceleration)
	var d := decel if decel != 0.0 else (default_air_deceleration if is_airborne else default_deceleration)
	
	if direction != 0.0:
		var turning = sign(direction) != sign(body.velocity.x) and body.velocity.x != 0.0
		var effective_accel := a * (turnaround_multiplier if turning else 1.0)
		body.velocity.x = move_toward(body.velocity.x, direction * max_speed, effective_accel * delta)
	else:
		body.velocity.x = move_toward(body.velocity.x, 0.0, d * delta)

func apply_jump(jump_v: float = 0.0) -> void:
	body.velocity.y = jump_velocity if jump_v == 0.0 else jump_v
