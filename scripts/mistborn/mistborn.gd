class_name Player
extends CharacterBody2D

@export var movement_component: MovementComponent 
@export var gravity_component: GravityComponent 
@export var dash_component: DashComponent
@export var push_pull_component: PushPullComponent 

# player input specific
@onready var jump_buffer_timer: Timer = %JumpBufferTimer
var requests_jump: bool = false

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		requests_jump = true
		jump_buffer_timer.start()	
		
func _on_jump_buffer_timer_timeout() -> void:
	requests_jump = false
