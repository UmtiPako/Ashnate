class_name GravityComponent extends Node

@export var body: CharacterBody2D

@export var gravity: float = 1800    

func apply_gravity(delta: float, multiplier: float = 1.0) -> void:
	var g = gravity * multiplier
	body.velocity.y += g * delta
