class_name PlayerState
extends State

var character: Player

var movement_component: MovementComponent 
var gravity_component: GravityComponent 
var dash_component: DashComponent
var push_pull_component: PushPullComponent 

func physics_update(_delta: float) -> void: pass

func check_push_transition() -> bool:		
	if push_pull_component.pp_velocity != Vector2.ZERO:
		state_machine.transition_to("pp")
		return true
	return false
