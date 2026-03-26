class_name DashComponent extends Node

@export var body: CharacterBody2D

@export var dash_speed: float = 700

var can_dash: bool = true
var is_dashing: bool = false

func _physics_process(delta: float) -> void:
	if body.is_on_floor():
		can_dash = true

func apply_dash(dir: Vector2) -> void:
	is_dashing = true
	
	body.velocity = dash_speed * dir
		
	await get_tree().create_timer(0.15).timeout	
		
	is_dashing = false
		
	# if body.velocity.y < 0 and dir.y < 0:
	body.velocity.y *= 0.1
	body.velocity.x *= 0.8           
	
