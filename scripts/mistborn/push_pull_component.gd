class_name PushPullComponent extends Node

@export var body: CharacterBody2D
@export var pp_area: Area2D
@export var char_impact_point: Marker2D
@export var cooldown: Timer 

@export var user_mass: float = 76
@export var push_pull_force: float = 600

var metals_in_area: Array = []
var consecutive: int = 2

var pp_velocity: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	handle_input()

func handle_input() -> void:
	if Input.is_action_just_pressed("push"):
		apply_push_pull(1)
	elif Input.is_action_just_pressed("pull"):
		apply_push_pull(-1)
				
func apply_push_pull(is_push: int) -> void:	
	if consecutive == 0:
		return

	consecutive -= 1
	if cooldown.is_stopped():
		cooldown.start()

	if not metals_in_area.is_empty():
		var metal = metals_in_area[0]
		
		if metal.is_in_group("BigMetal"):
			push_pull_big_metal(metal, is_push)
		elif metal.is_in_group("LilMetal"):
			push_pull_lil_metal(metal, is_push)
		else:
			push_pull_def_metal(metal, is_push)
			
func push_pull_def_metal(metal: DefaultMetal, is_push: float):
	var metal_mass: float = metal.get_meta("mass")

	var metal_impact_direction = (body.global_position - metal.global_position).normalized()

	var char_impact_direction = (body.global_position - char_impact_point.global_position).normalized()

	var mass_sum = (metal_mass + user_mass)

	pp_velocity += is_push * char_impact_direction * (push_pull_force * metal_mass / mass_sum)
	metal.push_velocity -= is_push * (metal_impact_direction * push_pull_force * user_mass / mass_sum)		
	

func push_pull_big_metal(metal: Node2D, is_push: float):
	var force_to_apply: float = metal.get_meta("force")
	
	var char_impact_direction = (body.global_position - char_impact_point.global_position).normalized()
	
	pp_velocity += is_push * char_impact_direction * force_to_apply
	
func push_pull_lil_metal(metal: DefaultMetal, is_push: float):
	var force_to_apply: float = metal.get_meta("force")
	
	var metal_impact_direction = (body.global_position - metal.global_position).normalized()
	
	metal.push_velocity -= is_push * (metal_impact_direction * force_to_apply)	
		

func resolve_pp_collisions() -> void:	
	for i in body.get_slide_collision_count():
		var col := body.get_slide_collision(i)
		var normal := col.get_normal()
		var dot := pp_velocity.dot(normal)
		if dot < 0:
			pp_velocity -= normal * dot

#region signals

func _on_metal_entered(body: Node2D) -> void:
	if not body.is_in_group("Metal"):
		return

	metals_in_area.push_front(body)

func _on_metal_exited(body: Node2D) -> void:
	if not body.is_in_group("Metal"):
		return

	metals_in_area.erase(body)

func _on_pushpull_cooldown_timeout() -> void:
	consecutive = 2

#endregion 
