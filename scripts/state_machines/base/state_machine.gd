class_name StateMachine extends Node

@export var initial_state: String
@export var state_list: Array[State]

var current_state: State
var previous_state: State

var states: Dictionary = {}

func _ready() -> void:
	for state in state_list:
		state.state_machine = self
		states[state.state_id] = state
	
	if self is StateMachine:
		transition_to(initial_state)

func _process(delta: float) -> void:
	if current_state == null:
		return	
	
	if current_state.has_method("update"):
		current_state.update(delta)
		
func _physics_process(delta: float) -> void:
	if current_state == null:
		return
	
	if current_state.has_method("physics_update"):
		current_state.physics_update(delta)	

func transition_to(state_name: String) -> void:
	if not states.has(state_name):
		return
	
	if current_state:
		previous_state = current_state		
		current_state.exit()
		
	current_state = states[state_name]
	current_state.enter()
