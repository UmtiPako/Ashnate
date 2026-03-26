class_name DefaultMetal extends CharacterBody2D

@export var GRAVITY: float = 1200

@export var deceleration: float = 1800.0
@export var bounciness: float = 0.0  
@export var volatility: float = 0.0 

var push_velocity: Vector2 

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		if velocity.x != 0.0:
			velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)

	velocity += push_velocity
	push_velocity = Vector2.ZERO

	var collision = move_and_slide()
