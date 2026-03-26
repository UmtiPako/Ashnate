extends Node

@onready var mistborn: CharacterBody2D = $".."
@onready var mistborn_a: AnimatedSprite2D = $"../AnimatedSprite2D"

func _process(delta: float) -> void:
	if mistborn.velocity.x != 0:
		mistborn_a.flip_h = true if sign(mistborn.velocity.x) < 0 else false 	
		mistborn_a.play("run")
	else:
		mistborn_a.play("idle")
		
