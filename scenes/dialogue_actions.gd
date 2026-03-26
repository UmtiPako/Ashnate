class_name DialogueActions extends Node

@onready var dsr: DialogueSettingsRepo = %DialogueSettingsRepo

signal advance_requested

func _process(delta: float) -> void:
	if Input.is_action_just_pressed(dsr.advance_action) and dsr.is_advance_active:
		advance_requested.emit()
