class_name PlayerStateMachine
extends StateMachine

@export var char: Player 

func _ready() -> void:
	super._ready()
	for state in states.values():
		state.character = char
		state.movement_component = char.get_node("MovementComponent")
		state.gravity_component = char.get_node("GravityComponent")
		state.dash_component = char.get_node("DashComponent")
		state.push_pull_component = char.get_node("PushPullComponent")

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	char.move_and_slide()
	char.push_pull_component.resolve_pp_collisions()
