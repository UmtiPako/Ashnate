extends Node

@onready var pp_area: Area2D = $"../PushpullRanger"
@onready var char_impact_point: Marker2D = $"../PushpullRanger/CharImpactPoint"
@onready var mistborn: CharacterBody2D = $".."

var player_mass: float = 76
var push_pull_force: float = 600
var metals_in_area: Array = []

var consecutive: int = 2

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("push"):
		apply_push_pull(1, delta)
	elif Input.is_action_just_pressed("pull"):
		apply_push_pull(-1, delta)
				
func apply_push_pull(is_push: int, delta: float) -> void:
	if consecutive == 0:
		return

	consecutive -= 1
	if $"../PushpullCooldown".is_stopped():
		$"../PushpullCooldown".start()

	if not metals_in_area.is_empty():
		var metal = metals_in_area[0]
		var metal_mass: float = metal.get_meta("mass")

		var metal_impact_direction = (mistborn.global_position - metal.global_position).normalized()

		var char_impact_direction = (mistborn.global_position - char_impact_point.global_position).normalized()

		var mass_sum = (metal_mass + player_mass)

		mistborn.push_velocity += is_push * char_impact_direction * (push_pull_force * metal_mass / mass_sum)
		metal.push_velocity -= is_push * (metal_impact_direction * push_pull_force * player_mass / mass_sum)		


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
