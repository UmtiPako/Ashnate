class_name DialogueSettingsRepo extends Node

@export var text_settings_resources: Array[Resource]
@export var gibberish_audio_resources: Array[Resource]

@export var advance_action: String

var is_advance_active: bool = true

var text_settings: Dictionary[String, Resource]
var gibberish_audios: Dictionary[String, Resource]

func _ready() -> void:
	for resource in text_settings_resources:
		pass
