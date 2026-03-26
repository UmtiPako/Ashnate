extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await Dialog.play_dialogue(["Because you [shake=3]deserve[/shake] this."])
	await Dialog.play_dialogue(["ppopoko."])
